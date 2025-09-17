from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from enum import Enum

class NotificationTypeEnum(str, Enum):
    BOOKING_CONFIRMED = "BOOKING_CONFIRMED"  # uppercase to match DB
    BOOKING_CANCELLED = "BOOKING_CANCELLED"  # uppercase to match DB
    DINNER_REMINDER = "DINNER_REMINDER"      # uppercase to match DB
    DINNER_UPDATED = "DINNER_UPDATED"        # uppercase to match DB
    DINNER_CANCELLED = "DINNER_CANCELLED"    # uppercase to match DB
    LAST_MINUTE_SPOT = "LAST_MINUTE_SPOT"    # uppercase to match DB
    CONNECTION_REQUEST = "connection_request"  # lowercase to match DB
    CONNECTION_ACCEPTED = "connection_accepted"

class NotificationCreate(BaseModel):
    user_id: int
    dinner_id: Optional[int] = None
    booking_id: Optional[int] = None
    type: NotificationTypeEnum
    title: str
    message: str

class NotificationResponse(BaseModel):
    id: int
    user_id: int
    dinner_id: Optional[int]
    booking_id: Optional[int]
    connection_id: Optional[int] = None
    type: str
    title: str
    message: str
    is_read: bool
    created_at: datetime
    read_at: Optional[datetime]

    class Config:
        from_attributes = True

class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = None

# NEW: Schemas for connection requests
class ConnectionRequestData(BaseModel):
    sender_id: int
    sender_name: str
    dinner_id: Optional[int] = None

class ConnectionActionRequest(BaseModel):
    action: str  # "accept" or "decline"