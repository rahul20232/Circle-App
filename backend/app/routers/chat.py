from app.core.security import get_current_user
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.services.chat_service import ChatService
from app.schemas.chat import ChatResponse, ChatDetailResponse, ChatCreate, MessageResponse
from app.models.user import User
from app.models.chat import Message, Chat
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/chat", tags=["chat"])

@router.post("/start", response_model=ChatResponse)
async def start_chat(
    chat_data: ChatCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Start a new chat or get existing chat between two users"""
    try:
        # Verify the other user exists
        other_user = db.query(User).filter(User.id == chat_data.other_user_id).first()
        if not other_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Create or get existing chat
        chat = ChatService.get_or_create_chat(
            db=db,
            user1_id=current_user.id,
            user2_id=chat_data.other_user_id,
            dinner_id=chat_data.dinner_id
        )
        
        # Get other user info
        other_user_id = chat.get_other_user_id(current_user.id)
        other_user = db.query(User).filter(User.id == other_user_id).first()
        
        # Get last message
        last_message = db.query(Message).filter(
            Message.chat_id == chat.id
        ).order_by(Message.sent_at.desc()).first()
        
        return ChatResponse(
            id=chat.id,
            created_at=chat.created_at,
            updated_at=chat.updated_at,
            is_active=chat.is_active,
            dinner_id=chat.dinner_id,
            other_user={
                "id": other_user.id,
                "display_name": other_user.display_name,
                "profile_picture_url": other_user.profile_picture_url
            },
            last_message=MessageResponse(
                id=last_message.id,
                content=last_message.content,
                message_type=last_message.message_type,
                chat_id=last_message.chat_id,
                sender_id=last_message.sender_id,
                sent_at=last_message.sent_at,
                is_read=last_message.is_read
            ) if last_message else None,
            unread_count=0  # Calculate if needed
        )
        
    except Exception as e:
        logger.error(f"Error starting chat: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not start chat"
        )

@router.delete("/{chat_id}")
async def delete_chat(
    chat_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a chat and all its messages for both users"""
    try:
        # Verify user is part of this chat
        chat = ChatService.get_chat_by_id(db, chat_id, current_user.id)
        if not chat:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Chat not found"
            )
        
        # Delete all messages in this chat
        db.query(Message).filter(Message.chat_id == chat_id).delete()
        
        # Delete the chat itself
        db.query(Chat).filter(Chat.id == chat_id).delete()
        
        db.commit()
        
        return {"message": "Chat deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting chat: {e}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not delete chat"
        )
    
@router.get("/", response_model=List[ChatResponse])
async def get_user_chats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all chats for the current user"""
    try:
        chats = ChatService.get_user_chats(db, current_user.id)
        
        chat_responses = []
        for chat in chats:
            # FIX: Handle None values for updated_at
            if chat.updated_at is None:
                chat.updated_at = chat.created_at
                db.commit()
            
            # Get other user info
            other_user_id = chat.get_other_user_id(current_user.id)
            other_user = db.query(User).filter(User.id == other_user_id).first()
            
            # Get last message
            last_message = db.query(Message).filter(
                Message.chat_id == chat.id
            ).order_by(Message.sent_at.desc()).first()
            
            # Get unread count
            unread_count = db.query(Message).filter(
                Message.chat_id == chat.id,
                Message.sender_id != current_user.id,
                Message.is_read == False
            ).count()
            
            chat_responses.append(ChatResponse(
                id=chat.id,
                created_at=chat.created_at,
                updated_at=chat.updated_at,
                is_active=chat.is_active,
                dinner_id=chat.dinner_id,
                other_user={
                    "id": other_user.id,
                    "display_name": other_user.display_name,
                    "profile_picture_url": other_user.profile_picture_url
                } if other_user else {
                    "id": other_user_id,
                    "display_name": "Unknown User",
                    "profile_picture_url": None
                },
                last_message=MessageResponse(
                    id=last_message.id,
                    content=last_message.content,
                    message_type=last_message.message_type,
                    chat_id=last_message.chat_id,
                    sender_id=last_message.sender_id,
                    sent_at=last_message.sent_at,
                    is_read=last_message.is_read,
                    sender_name=other_user.display_name if other_user and last_message.sender_id == other_user.id else "You"
                ) if last_message else None,
                unread_count=unread_count
            ))
        
        return chat_responses
        
    except Exception as e:
        logger.error(f"Error getting user chats: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not retrieve chats"
        )

@router.get("/{chat_id}", response_model=ChatDetailResponse)
async def get_chat_detail(
    chat_id: int,
    limit: int = 50,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get chat details with messages"""
    try:
        chat = ChatService.get_chat_by_id(db, chat_id, current_user.id)
        if not chat:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Chat not found"
            )
        
        # Get messages
        messages = ChatService.get_chat_messages(db, chat_id, current_user.id, limit, offset)
        
        # Get other user info
        other_user_id = chat.get_other_user_id(current_user.id)
        other_user = db.query(User).filter(User.id == other_user_id).first()
        
        # Convert messages to response format
        message_responses = []
        for message in messages:
            sender = db.query(User).filter(User.id == message.sender_id).first()
            message_responses.append(MessageResponse(
                id=message.id,
                content=message.content,
                message_type=message.message_type,
                chat_id=message.chat_id,
                sender_id=message.sender_id,
                sent_at=message.sent_at,
                is_read=message.is_read,
                sender_name=sender.display_name if sender else "Unknown",
                sender_profile_picture=sender.profile_picture_url if sender else None
            ))
        
        # Mark messages as read
        ChatService.mark_messages_as_read(db, chat_id, current_user.id)
        
        return ChatDetailResponse(
            id=chat.id,
            created_at=chat.created_at,
            updated_at=chat.updated_at,
            is_active=chat.is_active,
            dinner_id=chat.dinner_id,
            other_user={
                "id": other_user.id,
                "display_name": other_user.display_name,
                "profile_picture_url": other_user.profile_picture_url
            } if other_user else {
                "id": other_user_id,
                "display_name": "Unknown User",
                "profile_picture_url": None
            },
            messages=message_responses,
            unread_count=0  # Now 0 since we marked as read
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting chat detail: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not retrieve chat details"
        )