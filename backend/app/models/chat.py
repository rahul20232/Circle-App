# Update your chat model (app/models/chat.py)

from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class Chat(Base):
    __tablename__ = "chats"
    
    id = Column(Integer, primary_key=True, index=True)
    user1_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    user2_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    dinner_id = Column(Integer, ForeignKey("dinners.id", ondelete="SET NULL"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    
    # Relationships
    user1 = relationship("User", foreign_keys=[user1_id], passive_deletes=True, overlaps="chats_as_user1")
    user2 = relationship("User", foreign_keys=[user2_id], passive_deletes=True, overlaps="chats_as_user2")
    messages = relationship("Message", back_populates="chat", cascade="all, delete-orphan", passive_deletes=True)
    
    def get_other_user_id(self, current_user_id: int) -> int:
        """Get the other user's ID in this chat"""
        return self.user2_id if self.user1_id == current_user_id else self.user1_id


class Message(Base):
    __tablename__ = "messages"
    
    id = Column(Integer, primary_key=True, index=True)
    chat_id = Column(Integer, ForeignKey("chats.id", ondelete="CASCADE"), nullable=False)
    sender_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    content = Column(Text, nullable=False)
    message_type = Column(String(20), default="text", nullable=False)
    sent_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    is_read = Column(Boolean, default=False, nullable=False)
    
    # Relationships
    chat = relationship("Chat", back_populates="messages")
    sender = relationship("User")