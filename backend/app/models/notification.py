# backend/app/models/notification.py
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean, Text
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime, timezone, timedelta
import enum

IST = timezone(timedelta(hours=5, minutes=30))

class NotificationType(enum.Enum):
    BOOKING_CONFIRMED = "BOOKING_CONFIRMED"
    BOOKING_CANCELLED = "BOOKING_CANCELLED" 
    DINNER_REMINDER = "DINNER_REMINDER"
    DINNER_UPDATED = "DINNER_UPDATED"
    DINNER_CANCELLED = "DINNER_CANCELLED"
    LAST_MINUTE_SPOT = "LAST_MINUTE_SPOT"
    CONNECTION_REQUEST = "connection_request"
    CONNECTION_ACCEPTED = "connection_accepted"

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    dinner_id = Column(Integer, ForeignKey("dinners.id", ondelete="CASCADE"), nullable=True)
    booking_id = Column(Integer, ForeignKey("bookings.id", ondelete="CASCADE"), nullable=True)
    
    # TEMPORARY: Use String instead of Enum to avoid conversion issues
    type = Column(String, nullable=False)  # Changed from Enum(NotificationType)
    title = Column(String(200), nullable=False)
    message = Column(Text, nullable=False)
    
    is_read = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(IST))
    read_at = Column(DateTime, nullable=True)

    connection_id = Column(Integer, ForeignKey("connections.id", ondelete="CASCADE"), nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="notifications")
    dinner = relationship("Dinner")
    booking = relationship("Booking")

    class Config:
        use_enum_values = True