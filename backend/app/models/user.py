from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=True)  
    display_name = Column(String, nullable=False)
    google_id = Column(String, unique=True, nullable=True)  
    profile_picture_url = Column(String, nullable=True)
    phone_number = Column(String, nullable=True)  # Add this column if missing
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)  
    verification_token = Column(String, nullable=True)  
    verification_sent_at = Column(DateTime(timezone=True), nullable=True)  
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    password_reset_token = Column(String, nullable=True)
    password_reset_sent_at = Column(DateTime(timezone=True), nullable=True)
    
    relationship_status = Column(String, nullable=True)  # 'single', 'in_a_relationship', etc.
    children_status = Column(String, nullable=True)  # 'no_children', 'has_children', etc.
    industry = Column(String, nullable=True)  # 'tech', 'finance', etc.
    country = Column(String, nullable=True)  # Country code like 'US', 'UK', etc.

    # User Preferences
    dinner_languages = Column(Text, nullable=True)  # JSON string of languages
    dinner_budget = Column(String, nullable=True)  # '$', '$$', '$$$'
    has_dietary_restrictions = Column(Boolean, default=False)
    dietary_options = Column(Text, nullable=True)  # JSON string of dietary restrictions
    
    # Notification Preferences
    event_push_notifications = Column(Boolean, default=True)
    event_sms = Column(Boolean, default=True)
    event_email = Column(Boolean, default=True)
    
    lastminute_push_notifications = Column(Boolean, default=True)
    lastminute_sms = Column(Boolean, default=True)
    lastminute_email = Column(Boolean, default=True)
    marketing_email = Column(Boolean, default=True)

    is_subscribed = Column(Boolean, default=False, nullable=False)
    subscription_start = Column(DateTime(timezone=True), nullable=True)
    subscription_end = Column(DateTime(timezone=True), nullable=True)
    subscription_type = Column(String, nullable=True)  # e.g., 'monthly', 'yearly', 'lifetime'
    subscription_plan_id = Column(String, nullable=True)

    fcm_token = Column(String(255), nullable=True)

    bookings = relationship("Booking", back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")

    sent_connections = relationship(
        "Connection", 
        foreign_keys="Connection.sender_id",
        back_populates="sender",
        cascade="all, delete-orphan"
    )
    received_connections = relationship(
        "Connection", 
        foreign_keys="Connection.receiver_id", 
        back_populates="receiver",
        cascade="all, delete-orphan"
    )

    chats_as_user1 = relationship(
    "Chat", 
    foreign_keys="Chat.user1_id",
    cascade="all, delete-orphan",
    passive_deletes=True
    )
    chats_as_user2 = relationship(
        "Chat", 
        foreign_keys="Chat.user2_id", 
        cascade="all, delete-orphan",
        passive_deletes=True
    )

    @property
    def is_google_user(self) -> bool:
        """Compute whether user is a Google user based on google_id"""
        return self.google_id is not None
    
    @property
    def is_subscription_active(self) -> bool:
        """Check if user has an active subscription"""
        if not self.is_subscribed:
            return False
        
        if self.subscription_end is None:
            # Lifetime subscription or no end date set
            return True
            
        from datetime import datetime, timezone
        return datetime.now(timezone.utc) < self.subscription_end
    
    @property
    def days_until_subscription_expires(self) -> int:
        """Get number of days until subscription expires (returns -1 if expired or no subscription)"""
        if not self.is_subscribed or self.subscription_end is None:
            return -1
            
        from datetime import datetime, timezone
        now = datetime.now(timezone.utc)
        if now >= self.subscription_end:
            return 0  # Expired
            
        return (self.subscription_end - now).days