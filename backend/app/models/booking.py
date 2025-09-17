from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Enum, Text, Boolean
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime
import enum


class BookingStatus(enum.Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    CANCELLED = "cancelled"
    NO_SHOW = "no_show"


class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    dinner_id = Column(Integer, ForeignKey("dinners.id", ondelete="CASCADE"), nullable=False)
    status = Column(Enum(BookingStatus), default=BookingStatus.CONFIRMED, nullable=False)
    notes = Column(Text, nullable=True)  # Any special requests or notes
    booked_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    has_been_rated = Column(Boolean, default=False, nullable=False)
    rating = Column(Integer, nullable=True)  # 1-5 stars

    # Relationships
    user = relationship("User", back_populates="bookings")
    dinner = relationship("Dinner", back_populates="bookings")

    class Config:
        use_enum_values = True