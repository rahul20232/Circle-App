from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.websocket_service import manager
from app.services.chat_service import ChatService
from app.schemas.chat import WebSocketMessage, WebSocketMessageSend, WebSocketTyping
from app.core.security import verify_token  # Add this import
from app.models.user import User
import json
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

async def get_user_from_token(token: str, db: Session) -> User:
    """Validate token and return user"""
    try:
        logger.info(f"Attempting to validate token: {token[:20]}...")
        
        # Use your existing verify_token function (returns None on error)
        payload = verify_token(token)
        if payload is None:
            logger.error("Token verification returned None - invalid token")
            raise HTTPException(status_code=401, detail="Invalid or expired token")
        
        logger.info(f"Token payload: {payload}")
        
        user_id_str = payload.get("sub")
        if user_id_str is None:
            logger.error("No 'sub' field in token payload")
            raise HTTPException(status_code=401, detail="Invalid token - no user ID")
        
        # Convert to int since your token stores user_id as string
        user_id = int(user_id_str)
        logger.info(f"Extracted user_id: {user_id}")
        
        user = db.query(User).filter(User.id == user_id).first()
        if user is None:
            logger.error(f"User {user_id} not found in database")
            raise HTTPException(status_code=401, detail="User not found")
        
        logger.info(f"Successfully validated user: {user.id}")
        return user
        
    except HTTPException:
        raise
    except ValueError as e:
        logger.error(f"Error converting user_id to int: {e}")
        raise HTTPException(status_code=401, detail="Invalid user ID format")
    except Exception as e:
        logger.error(f"Unexpected token validation error: {e}")
        raise HTTPException(status_code=401, detail="Token validation failed")

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(
    websocket: WebSocket, 
    user_id: int,
    token: str = Query(...),  # Get token from query parameter
):
    """WebSocket endpoint for real-time chat"""
    db = None
    try:
        logger.info(f"=== WebSocket connection attempt ===")
        logger.info(f"User ID: {user_id}")
        logger.info(f"Token received: {token[:50]}...")
        
        # Get database session
        db = next(get_db())
        logger.info("Database session created")
        
        # Validate token and user
        user = await get_user_from_token(token, db)
        logger.info(f"Token validation successful for user: {user.id}")
        
        # Verify that the user_id matches the token
        if user.id != user_id:
            logger.warning(f"User ID mismatch: token has {user.id}, URL has {user_id}")
            await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
            return
        
        # Accept the connection
        await manager.connect(websocket, user_id)
        logger.info(f"WebSocket connected successfully for user {user_id}")
        
        try:
            while True:
                # Receive message from client
                data = await websocket.receive_text()
                
                try:
                    message_data = json.loads(data)
                    message_type = message_data.get("type")
                    
                    if message_type == "message":
                        await handle_message(message_data.get("data"), user_id)
                    elif message_type == "typing":
                        await handle_typing(message_data.get("data"), user_id)
                    elif message_type == "read":
                        await handle_read_receipt(message_data.get("data"), user_id)
                    elif message_type == "ping":
                        # Heartbeat response
                        await manager.send_personal_message(
                            {"type": "pong", "data": {}}, user_id
                        )
                    
                except json.JSONDecodeError:
                    logger.error(f"Invalid JSON received from user {user_id}: {data}")
                except Exception as e:
                    logger.error(f"Error handling WebSocket message from user {user_id}: {e}")
                    
        except WebSocketDisconnect:
            manager.disconnect(user_id)
            logger.info(f"User {user_id} disconnected")
        except Exception as e:
            logger.error(f"Unexpected error in WebSocket connection for user {user_id}: {e}")
            manager.disconnect(user_id)
            
    except HTTPException as e:
        # Authentication failed
        logger.error(f"❌ WebSocket authentication failed for user {user_id}: {e.detail}")
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
    except Exception as e:
        logger.error(f"❌ Unexpected error during WebSocket authentication: {e}")
        await websocket.close(code=status.WS_1011_INTERNAL_ERROR)
    finally:
        if db:
            db.close()
            logger.info("Database session closed")

async def handle_message(data: dict, sender_id: int):
    """Handle incoming chat message"""
    try:
        db = next(get_db())
        message_data = WebSocketMessageSend(**data)
        
        logger.info(f"Attempting to save message: chat_id={message_data.chat_id}, sender_id={sender_id}, content='{message_data.content}'")
        
        message = ChatService.send_message(
            db=db,
            chat_id=message_data.chat_id,
            sender_id=sender_id,
            content=message_data.content,
            message_type=message_data.message_type
        )
        
        if message:
            # Get chat to find recipient
            logger.info(f"Message saved successfully: id={message.id}")
            chat = ChatService.get_chat_by_id(db, message_data.chat_id, sender_id)
            if chat:
                recipient_id = chat.get_other_user_id(sender_id)
                
                # Get sender info
                sender = db.query(User).filter(User.id == sender_id).first()
                
                # Prepare message for WebSocket
                ws_message = {
                    "type": "message",
                    "data": {
                        "id": message.id,
                        "chat_id": message.chat_id,
                        "sender_id": message.sender_id,
                        "content": message.content,
                        "message_type": message.message_type,
                        "sent_at": message.sent_at.isoformat(),
                        "is_read": message.is_read,
                        "sender_name": sender.display_name if sender else "Unknown",
                        "sender_profile_picture": sender.profile_picture_url if sender else None
                    }
                }
                
                # Send to recipient
                await manager.send_personal_message(ws_message, recipient_id)
        else:
            logger.error(f"Failed to save message for chat_id={message_data.chat_id}, sender_id={sender_id}")
            
             
        db.close()
        
    except Exception as e:
        logger.error(f"Error handling message: {e}")

async def handle_typing(data: dict, sender_id: int):
    """Handle typing indicator"""
    try:
        db = next(get_db())
        
        typing_data = WebSocketTyping(**data)
        
        # Get chat to find recipient
        chat = ChatService.get_chat_by_id(db, typing_data.chat_id, sender_id)
        if chat:
            recipient_id = chat.get_other_user_id(sender_id)
            
            # Send typing indicator to recipient
            ws_message = {
                "type": "typing",
                "data": {
                    "chat_id": typing_data.chat_id,
                    "user_id": sender_id,
                    "is_typing": typing_data.is_typing
                }
            }
            
            await manager.send_personal_message(ws_message, recipient_id)
        
        db.close()
        
    except Exception as e:
        logger.error(f"Error handling typing indicator: {e}")

async def handle_read_receipt(data: dict, user_id: int):
    """Handle message read receipt"""
    try:
        db = next(get_db())
        
        chat_id = data.get("chat_id")
        if chat_id:
            # Mark messages as read
            ChatService.mark_messages_as_read(db, chat_id, user_id)
            
            # Get chat to find other user
            chat = ChatService.get_chat_by_id(db, chat_id, user_id)
            if chat:
                other_user_id = chat.get_other_user_id(user_id)
                
                # Send read receipt to other user
                ws_message = {
                    "type": "read_receipt",
                    "data": {
                        "chat_id": chat_id,
                        "reader_id": user_id
                    }
                }
                
                await manager.send_personal_message(ws_message, other_user_id)
        
        db.close()
        
    except Exception as e:
        logger.error(f"Error handling read receipt: {e}")