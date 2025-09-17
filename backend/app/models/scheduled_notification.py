# backend/app/models/scheduled_notification.py
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean, Text, Enum
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime
import enum

class ScheduledNotificationType(enum.Enum):
    DAY_BEFORE_REMINDER = "day_before_reminder"
    DAY_OF_REMINDER = "day_of_reminder"

class ScheduledNotification(Base):
    __tablename__ = "scheduled_notifications"

    id = Column(Integer, primary_key=True, index=True)
    booking_id = Column(Integer, ForeignKey("bookings.id", ondelete="CASCADE"), nullable=False)
    notification_type = Column(Enum(ScheduledNotificationType), nullable=False)
    scheduled_time = Column(DateTime, nullable=False)
    is_sent = Column(Boolean, default=False, nullable=False)
    sent_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    booking = relationship("Booking")