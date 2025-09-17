from sqlalchemy.orm import Session
from sqlalchemy import or_, and_, desc
from app.models.chat import Chat, Message
from app.models.user import User
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)

class ChatService:
    
    @staticmethod
    def get_or_create_chat(db: Session, user1_id: int, user2_id: int, dinner_id: Optional[int] = None) -> Chat:
        """Get existing chat between two users or create a new one"""
        # Ensure consistent ordering (smaller ID first)
        if user1_id > user2_id:
            user1_id, user2_id = user2_id, user1_id
        
        # Check if chat already exists
        existing_chat = db.query(Chat).filter(
            and_(
                Chat.user1_id == user1_id,
                Chat.user2_id == user2_id,
                Chat.is_active == True
            )
        ).first()
        
        if existing_chat:
            return existing_chat
        
        # Create new chat
        new_chat = Chat(
            user1_id=user1_id,
            user2_id=user2_id,
            dinner_id=dinner_id,
            is_active=True
        )
        db.add(new_chat)
        db.commit()
        db.refresh(new_chat)
        
        logger.info(f"Created new chat between users {user1_id} and {user2_id}")
        return new_chat
    
    @staticmethod
    def get_user_chats(db: Session, user_id: int) -> List[Chat]:
        """Get all active chats for a user"""
        chats = db.query(Chat).filter(
            and_(
                or_(Chat.user1_id == user_id, Chat.user2_id == user_id),
                Chat.is_active == True
            )
        ).order_by(desc(Chat.updated_at)).all()
        
        return chats
    
    @staticmethod
    def get_chat_by_id(db: Session, chat_id: int, user_id: int) -> Optional[Chat]:
        """Get a specific chat if user is participant"""
        chat = db.query(Chat).filter(
            and_(
                Chat.id == chat_id,
                or_(Chat.user1_id == user_id, Chat.user2_id == user_id),
                Chat.is_active == True
            )
        ).first()
        
        return chat
    
    @staticmethod
    def send_message(db: Session, chat_id: int, sender_id: int, content: str, message_type: str = "text") -> Optional[Message]:
        """Send a message in a chat"""
        # Verify user is part of this chat
        chat = db.query(Chat).filter(
            and_(
                Chat.id == chat_id,
                or_(Chat.user1_id == sender_id, Chat.user2_id == sender_id),
                Chat.is_active == True
            )
        ).first()
        
        if not chat:
            return None
        
        # Create message
        message = Message(
            chat_id=chat_id,
            sender_id=sender_id,
            content=content,
            message_type=message_type
        )
        
        db.add(message)
        
        # Update chat's updated_at timestamp to current time
        from datetime import datetime
        chat.updated_at = datetime.utcnow()  # Use current time instead of message.sent_at
        
        db.commit()
        db.refresh(message)
        
        return message
    
    @staticmethod
    def get_chat_messages(db: Session, chat_id: int, user_id: int, limit: int = 50, offset: int = 0) -> List[Message]:
        """Get messages from a chat"""
        # Verify user is part of this chat
        chat = ChatService.get_chat_by_id(db, chat_id, user_id)
        if not chat:
            return []
        
        messages = db.query(Message).filter(
            Message.chat_id == chat_id
        ).order_by(desc(Message.sent_at)).offset(offset).limit(limit).all()
        
        return list(reversed(messages))  # Return in chronological order
    
    @staticmethod
    def mark_messages_as_read(db: Session, chat_id: int, user_id: int):
        """Mark all unread messages in a chat as read for a user"""
        # Verify user is part of this chat
        chat = ChatService.get_chat_by_id(db, chat_id, user_id)
        if not chat:
            return
        
        # Mark all unread messages from the other user as read
        db.query(Message).filter(
            and_(
                Message.chat_id == chat_id,
                Message.sender_id != user_id,
                Message.is_read == False
            )
        ).update({"is_read": True})
        
        db.commit()
    
    @staticmethod
    def get_unread_message_count(db: Session, user_id: int) -> int:
        """Get total unread message count for a user"""
        user_chats = ChatService.get_user_chats(db, user_id)
        chat_ids = [chat.id for chat in user_chats]
        
        unread_count = db.query(Message).filter(
            and_(
                Message.chat_id.in_(chat_ids),
                Message.sender_id != user_id,
                Message.is_read == False
            )
        ).count()
        
        return unread_count