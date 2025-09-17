from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

# Message Schemas
class MessageBase(BaseModel):
    content: str
    message_type: str = "text"

class MessageCreate(MessageBase):
    chat_id: int

class MessageResponse(MessageBase):
    id: int
    chat_id: int
    sender_id: int
    sent_at: datetime
    is_read: bool
    
    # Sender info
    sender_name: Optional[str] = None
    sender_profile_picture: Optional[str] = None
    
    class Config:
        from_attributes = True

# Chat Schemas
class ChatBase(BaseModel):
    pass

class ChatCreate(BaseModel):
    other_user_id: int
    dinner_id: Optional[int] = None

class ChatParticipant(BaseModel):
    id: int
    display_name: str
    profile_picture_url: Optional[str] = None

class ChatResponse(BaseModel):
    id: int
    created_at: datetime
    updated_at: datetime
    is_active: bool
    dinner_id: Optional[int] = None
    
    # Other participant info
    other_user: ChatParticipant
    
    # Last message info
    last_message: Optional[MessageResponse] = None
    unread_count: int = 0
    
    class Config:
        from_attributes = True

class ChatDetailResponse(ChatResponse):
    messages: List[MessageResponse] = []

# WebSocket Message Schemas
class WebSocketMessage(BaseModel):
    type: str  # "message", "typing", "read", "user_status"
    data: dict

class WebSocketMessageSend(BaseModel):
    chat_id: int
    content: str
    message_type: str = "text"

class WebSocketTyping(BaseModel):
    chat_id: int
    is_typing: bool