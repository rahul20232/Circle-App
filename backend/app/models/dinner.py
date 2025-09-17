# backend/app/models/dinner.py
from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean, Float
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime

class Dinner(Base):
    __tablename__ = "dinners"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    date = Column(DateTime, nullable=False)
    location = Column(String(500), nullable=False)
    latitude = Column(Float, nullable=True)  
    longitude = Column(Float, nullable=True)  
    max_attendees = Column(Integer, default=6, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationship to bookings
    bookings = relationship("Booking", back_populates="dinner", cascade="all, delete-orphan")

    @property
    def current_attendees(self):
        """Get current number of confirmed bookings"""
        if not self.bookings:
            return 0
        # Import BookingStatus here to avoid circular imports
        from app.models.booking import BookingStatus
        return len([booking for booking in self.bookings 
                   if booking.status in [BookingStatus.CONFIRMED, BookingStatus.PENDING]])
    
    @property
    def is_full(self):
        """Check if dinner is fully booked"""
        return self.current_attendees >= self.max_attendees
    
    @property
    def available_spots(self):
        """Get number of available spots"""
        return max(0, self.max_attendees - self.current_attendees)