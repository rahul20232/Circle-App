from pydantic import BaseModel, EmailStr
from typing import Dict, Optional, List
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    display_name: str

class UserCreate(UserBase):
    email: str
    password: str
    display_name: str
    phone_number: Optional[str] = None
    personality_data: Optional[Dict[str, str]] = None
    identity_data: Optional[Dict[str, str]] = None

class UserGoogleAuth(BaseModel):
    email: str
    display_name: str
    google_id: str
    profile_picture_url: Optional[str] = None

class UserResponse(BaseModel):
    id: int
    email: str
    display_name: str
    phone_number: Optional[str] = None
    is_google_user: bool
    is_verified: bool
    profile_picture_url: Optional[str] = None
    created_at: datetime

    relationship_status: Optional[str] = None
    children_status: Optional[str] = None
    industry: Optional[str] = None
    country: Optional[str] = None
    
    # Preferences
    dinner_languages: Optional[List[str]] = None
    dinner_budget: Optional[str] = None
    has_dietary_restrictions: bool = False
    dietary_options: Optional[List[str]] = None
    
    # Notification preferences
    event_push_notifications: bool = True
    event_sms: bool = True
    event_email: bool = True
    lastminute_push_notifications: bool = True
    lastminute_sms: bool = True
    lastminute_email: bool = True
    marketing_email: bool = True

    is_subscribed: bool = False
    subscription_start: Optional[datetime] = None
    subscription_end: Optional[datetime] = None
    subscription_type: Optional[str] = None
    subscription_plan_id: Optional[str] = None
    is_subscription_active: bool = False  # Computed property
    days_until_subscription_expires: int = -1 # Computed property
    
    @classmethod
    def from_orm(cls, user):
        """Custom from_orm to handle JSON parsing"""
        import json
        
        # Parse JSON fields
        dinner_languages = None
        if user.dinner_languages:
            try:
                dinner_languages = json.loads(user.dinner_languages)
            except:
                dinner_languages = []
        
        dietary_options = None
        if user.dietary_options:
            try:
                dietary_options = json.loads(user.dietary_options)
            except:
                dietary_options = []
        
        return cls(
            id=user.id,
            email=user.email,
            display_name=user.display_name,
            phone_number=user.phone_number,
            is_google_user=user.google_id is not None,
            is_verified=user.is_verified,
            profile_picture_url=user.profile_picture_url,
            created_at=user.created_at,
            relationship_status=user.relationship_status,
            children_status=user.children_status,
            industry=user.industry,
            country=user.country,
            dinner_languages=dinner_languages,
            dinner_budget=user.dinner_budget,
            has_dietary_restrictions=user.has_dietary_restrictions or False,
            dietary_options=dietary_options,
            event_push_notifications=user.event_push_notifications if hasattr(user, 'event_push_notifications') else True,
            event_sms=user.event_sms if hasattr(user, 'event_sms') else True,
            event_email=user.event_email if hasattr(user, 'event_email') else True,
            lastminute_push_notifications=user.lastminute_push_notifications if hasattr(user, 'lastminute_push_notifications') else True,
            lastminute_sms=user.lastminute_sms if hasattr(user, 'lastminute_sms') else True,
            lastminute_email=user.lastminute_email if hasattr(user, 'lastminute_email') else True,
            marketing_email=user.marketing_email if hasattr(user, 'marketing_email') else True,
            is_subscribed=user.is_subscribed if hasattr(user, 'is_subscribed') else False,
            subscription_start=user.subscription_start if hasattr(user, 'subscription_start') else None,
            subscription_end=user.subscription_end if hasattr(user, 'subscription_end') else None,
            subscription_type=user.subscription_type if hasattr(user, 'subscription_type') else None,
            subscription_plan_id=user.subscription_plan_id if hasattr(user, 'subscription_plan_id') else None,
            is_subscription_active=user.is_subscription_active if hasattr(user, 'is_subscription_active') else False,
            days_until_subscription_expires=user.days_until_subscription_expires if hasattr(user, 'days_until_subscription_expires') else -1,
        )
    
    class Config:
        from_attributes = True

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserGoogleAuthWithOnboarding(BaseModel):
    email: str
    display_name: str
    google_id: str
    profile_picture_url: Optional[str] = None
    personality_data: Optional[Dict[str, str]] = None
    identity_data: Optional[Dict[str, str]] = None

class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    phone_number: Optional[str] = None

class UserPreferencesUpdate(BaseModel):
    relationship_status: Optional[str] = None
    children_status: Optional[str] = None
    industry: Optional[str] = None
    country: Optional[str] = None
    dinner_languages: Optional[List[str]] = None
    dinner_budget: Optional[str] = None
    has_dietary_restrictions: Optional[bool] = None
    dietary_options: Optional[List[str]] = None
    event_push_notifications: Optional[bool] = None
    event_sms: Optional[bool] = None
    event_email: Optional[bool] = None
    lastminute_push_notifications: Optional[bool] = None
    lastminute_sms: Optional[bool] = None
    lastminute_email: Optional[bool] = None
    marketing_email: Optional[bool] = None

class UserSubscriptionUpdate(BaseModel):
    is_subscribed: Optional[bool] = None
    subscription_start: Optional[datetime] = None
    subscription_end: Optional[datetime] = None
    subscription_type: Optional[str] = None
    subscription_plan_id: Optional[str] = None
    
class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

class TokenData(BaseModel):
    email: Optional[str] = None

class EmailVerification(BaseModel):
    token: str

class PasswordResetRequest(BaseModel):
    email: EmailStr

class PasswordReset(BaseModel):
    token: str
    new_password: str

class AccountDeletionRequest(BaseModel):
    password: str
    confirmation_text: str  # User must type "delete my account"