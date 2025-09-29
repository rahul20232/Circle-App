import os
from app.models.booking import Booking
from app.models.notification import Notification
from app.models.connection import Connection
from app.models.chat import Chat
from ..services.user_service import update_user_profile
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_
from datetime import timedelta, datetime, timezone
from typing import Annotated
import json
from fastapi import UploadFile, File
from sqlalchemy.exc import SQLAlchemyError 

from ..database import get_db
from ..models.user import User
from ..schemas.user import PasswordReset, PasswordResetRequest, UserCreate, UserLogin, UserGoogleAuth, Token, UserPreferencesUpdate, UserResponse, EmailVerification, UserSubscriptionUpdate, UserUpdate
from ..core.security import get_current_user, verify_password, get_password_hash, create_access_token
from ..core.config import settings
from ..services.email_service import EmailService
from ..schemas.user import AccountDeletionRequest
from ..services.s3_service import S3Service

from pydantic import BaseModel

router = APIRouter(prefix="/auth", tags=["authentication"])

class FCMTokenRequest(BaseModel):
    token: str

SKIP_EMAIL_VERIFICATION = os.getenv("SKIP_EMAIL_VERIFICATION", "false").lower() == "true"

@router.post("/fcm-token")
async def update_fcm_token(
    request: FCMTokenRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user's FCM token"""
    current_user.fcm_token = request.token
    db.commit()
    return {"message": "FCM token updated successfully"}

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_user_by_google_id(db: Session, google_id: str):
    return db.query(User).filter(User.google_id == google_id).first()

def get_user_by_verification_token(db: Session, token: str):
    return db.query(User).filter(User.verification_token == token).first()

def create_user(db: Session, user: UserCreate):
    hashed_password = get_password_hash(user.password)
    verification_token = EmailService.generate_verification_token()
    
    db_user = User(
        email=user.email,
        password_hash=hashed_password,
        display_name=user.display_name,
        verification_token=verification_token,
        verification_sent_at=datetime.utcnow()
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Send verification email
    EmailService.send_verification_email(
        user.email, 
        user.display_name, 
        verification_token
    )
    
    return db_user

@router.post("/google", response_model=Token)
async def google_auth(google_data: UserGoogleAuth, db: Session = Depends(get_db)):
    """Authenticate EXISTING users via Google OAuth - NO new user creation"""
    try:
        print(f"DEBUG: Google auth attempt for email: {google_data.email}")
        print(f"DEBUG: Google ID: {google_data.google_id}")
        
        # First, try to find user by Google ID
        db_user = get_user_by_google_id(db, google_data.google_id)
        print(f"DEBUG: User found by Google ID: {db_user is not None}")
        
        # If not found by Google ID, try to find by email
        if not db_user:
            db_user = get_user_by_email(db, google_data.email)
            print(f"DEBUG: User found by email: {db_user is not None}")
        
        # If still no user found, REJECT instead of creating new user
        if not db_user:
            print(f"DEBUG: No existing user found - rejecting Google sign in")
            raise HTTPException(
                status_code=404,
                detail="No account found with this Google account. Please sign up using email first."
            )
        
        # User exists - link Google account if not already linked
        if not db_user.google_id:
            print(f"DEBUG: Linking existing email account to Google")
            db_user.google_id = google_data.google_id
            if google_data.profile_picture_url:
                db_user.profile_picture_url = google_data.profile_picture_url
            if not db_user.is_verified:
                db_user.is_verified = True  # Auto-verify when linking Google
            db.commit()
            db.refresh(db_user)
            print(f"DEBUG: Successfully linked account")
        
        print(f"DEBUG: Using existing user with ID: {db_user.id}")
        
        # Create access token
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": str(db_user.id)}, expires_delta=access_token_expires
        )
        print(f"DEBUG: Created access token")
        
        user_response = UserResponse.from_orm(db_user)
        
        return Token(
            access_token=access_token,
            token_type="bearer",
            user=user_response
        )
        
    except HTTPException:
        # Re-raise HTTP exceptions as-is (like 404 for no user found)
        raise
    except Exception as e:
        print(f"DEBUG: Google auth exception: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail=f"Google authentication failed: {str(e)}"
        )
    
@router.post("/register", response_model=dict)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    """Register user with complete onboarding data"""
    try:
        print(f"DEBUG: Registration request for email: {user.email}")
        print(f"DEBUG: Has personality data: {user.personality_data is not None}")
        print(f"DEBUG: Has identity data: {user.identity_data is not None}")
        print(f"DEBUG: Phone number: {user.phone_number}")
        
        # Check if user already exists
        db_user = get_user_by_email(db, user.email)
        if db_user:
            raise HTTPException(
                status_code=400,
                detail="Email already registered"
            )
        
        # Create new user with enhanced data
        db_user = create_user_with_onboarding_data(db, user)
        
        return {
            "message": "Registration successful! Please check your email to verify your account.",
            "user_id": db_user.id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"DEBUG: Registration exception: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Registration failed: {str(e)}"
        )

@router.get("/check-user-exists")
async def check_user_exists(email: str, db: Session = Depends(get_db)):
    """Check if a user exists with the given email"""
    try:
        user = db.query(User).filter(User.email == email).first()
        return {
            "exists": user is not None,
            "email": email
        }
    except Exception as e:
        print(f"Error checking user existence: {e}")
        raise HTTPException(
            status_code=500,
            detail="Failed to check user existence"
        )

def create_user_with_onboarding_data(db: Session, user: UserCreate):
    """Create user with complete onboarding data"""
    hashed_password = get_password_hash(user.password)
    verification_token = EmailService.generate_verification_token()
    
    # Process identity data to extract user information
    country = None
    relationship_status = None
    children_status = None
    industry = None
    birth_date = None
    
    if user.identity_data:
        # Extract structured data from identity responses
        country = user.identity_data.get('What country are you from?')
        relationship_status = user.identity_data.get('What is your relationship status?')
        children_status = user.identity_data.get('Do you have children?')
        industry = user.identity_data.get("If you're working, what industry do you work in?")
        
        # Parse birthday if provided
        birthday_str = user.identity_data.get('When is your birthday?')
        if birthday_str:
            try:
                # Parse MM/DD/YYYY format
                from datetime import datetime
                birth_date = datetime.strptime(birthday_str, '%m/%d/%Y').date()
            except ValueError:
                print(f"DEBUG: Could not parse birthday: {birthday_str}")
    
    # Clean up country data (remove flag emojis)
    if country:
        country = country.split(' ')[0]  # Take first part before emoji
    
    db_user = User(
        email=user.email,
        password_hash=hashed_password,
        display_name=user.display_name,
        phone_number=user.phone_number,
        verification_token=verification_token,
        verification_sent_at=datetime.utcnow(),
        
        # Identity data
        country=country,
        relationship_status=relationship_status,
        children_status=children_status,
        industry=industry,
        birth_date=birth_date,
        
        # Store raw onboarding data as JSON
        personality_data=json.dumps(user.personality_data) if user.personality_data else None,
        identity_data=json.dumps(user.identity_data) if user.identity_data else None,
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Send verification email
    EmailService.send_verification_email(
        user.email, 
        user.display_name, 
        verification_token
    )
    
    print(f"DEBUG: Created user with onboarding data:")
    print(f"  - Country: {country}")
    print(f"  - Relationship: {relationship_status}")
    print(f"  - Children: {children_status}")
    print(f"  - Industry: {industry}")
    print(f"  - Phone: {user.phone_number}")
    print(f"  - Birth date: {birth_date}")
    
    return db_user

@router.post("/login", response_model=Token)
async def login(user_credentials: UserLogin, db: Session = Depends(get_db)):

    print(f"DEBUG: Login attempt for email: {user_credentials.email}")
    # Get user from database
    db_user = get_user_by_email(db, user_credentials.email)
    print(f"DEBUG: User found: {db_user is not None}")
    
    if not db_user or not verify_password(user_credentials.password, db_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if SKIP_EMAIL_VERIFICATION:
        db_user.is_verified = True
    
    if not db_user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please verify your email before logging in",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(db_user.id)}, expires_delta=access_token_expires
    )
    
    # Use the custom from_orm method to handle JSON parsing
    user_response = UserResponse.from_orm(db_user)
    
    return Token(
        access_token=access_token,
        token_type="bearer",
        user=user_response
    )

@router.post("/test-sendgrid")
async def test_sendgrid():
    try:
        print(f"DEBUG: Testing SendGrid with API key: {settings.SENDGRID_API_KEY[:10]}...")
        print(f"DEBUG: Sender email: {settings.SENDER_EMAIL}")
        
        EmailService._send_email(
            to_email="rahul20232@iiitd.ac.in",
            subject="Test Email from SendGrid",
            text_content="This is a test email from SendGrid",
            html_content="<p>This is a test email from SendGrid</p>"
        )
        return {"message": "Test email sent successfully"}
    except Exception as e:
        print(f"DEBUG: SendGrid test failed: {str(e)}")
        return {"error": str(e), "api_key_prefix": settings.SENDGRID_API_KEY[:10] if settings.SENDGRID_API_KEY else "None"}

@router.post("/verify-email")
async def verify_email(verification: EmailVerification, db: Session = Depends(get_db)):
    # Find user by verification token
    db_user = get_user_by_verification_token(db, verification.token)
    
    if not db_user:
        raise HTTPException(
            status_code=404,
            detail="Invalid verification token"
        )
    
    if EmailService.is_verification_token_expired(db_user.verification_sent_at):
        raise HTTPException(
            status_code=400,
            detail="Verification token has expired"
        )
    
    if db_user.is_verified:
        raise HTTPException(
            status_code=400,
            detail="Email already verified"
        )
    
    # Verify the user
    db_user.is_verified = True
    db_user.verification_token = None
    db.commit()
    
    return {"message": "Email verified successfully! You can now log in."}

@router.put("/profile", response_model=UserResponse)
async def update_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user profile with better error handling"""
    try:
        # Update only provided fields
        if user_update.display_name is not None:
            # Validate display name
            if len(user_update.display_name.strip()) < 2:
                raise HTTPException(
                    status_code=400,
                    detail="Display name must be at least 2 characters"
                )
            current_user.display_name = user_update.display_name.strip()
            
        if user_update.phone_number is not None:
            # Basic phone number validation
            phone = user_update.phone_number.strip()
            if phone and len(phone) < 10:
                raise HTTPException(
                    status_code=400,
                    detail="Phone number must be at least 10 digits"
                )
            current_user.phone_number = phone if phone else None
        
        db.commit()
        db.refresh(current_user)
        
        # Return updated user with proper JSON parsing
        return UserResponse.from_orm(current_user)
        
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Database error occurred while updating profile"
        )
    except HTTPException:
        raise  # Re-raise HTTP exceptions as-is
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail=f"Profile update failed: {str(e)}"
        )
    
@router.post("/resend-verification")
async def resend_verification(email: str, db: Session = Depends(get_db)):
    db_user = get_user_by_email(db, email)
    
    if not db_user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )
    
    if db_user.is_verified:
        raise HTTPException(
            status_code=400,
            detail="Email already verified"
        )
    
    # Remove rate limiting for development/testing
    # if (db_user.verification_sent_at and 
    #     datetime.now(timezone.utc) - db_user.verification_sent_at < timedelta(minutes=5)):
    #     raise HTTPException(
    #         status_code=429,
    #         detail="Please wait 5 minutes before requesting another verification email"
    #     )
    
    # Generate new token and resend
    verification_token = EmailService.generate_verification_token()
    db_user.verification_token = verification_token
    db_user.verification_sent_at = datetime.now(timezone.utc)  # Fix timezone here too
    db.commit()
    
    EmailService.send_verification_email(
        db_user.email,
        db_user.display_name,
        verification_token
    )
    
    return {"message": "Verification email sent!"}

# Add these endpoints to your auth.py

@router.post("/forgot-password")
async def forgot_password(request: PasswordResetRequest, db: Session = Depends(get_db)):
    try:
        db_user = get_user_by_email(db, request.email)
        
        if not db_user:
            return {"message": "If the email exists, a password reset link has been sent."}
        
        # Remove rate limiting for development/testing
        # if (db_user.password_reset_sent_at and 
        #     datetime.now(timezone.utc) - db_user.password_reset_sent_at < timedelta(minutes=5)):
        #     raise HTTPException(
        #         status_code=429,
        #         detail="Please wait 5 minutes before requesting another reset email"
        #     )
        
        # Generate reset token and save to database
        reset_token = EmailService.generate_verification_token()
        print(f"DEBUG: Generated reset token: {reset_token}")
        
        db_user.password_reset_token = reset_token
        db_user.password_reset_sent_at = datetime.now(timezone.utc)
        db.commit()
        print(f"DEBUG: Saved reset token to database")
        
        # Send password reset email
        print(f"DEBUG: Attempting to send email to {db_user.email}")
        EmailService.send_password_reset_email(
            db_user.email,
            db_user.display_name,
            reset_token
        )
        print(f"DEBUG: Email sent successfully")
        
        return {"message": "If the email exists, a password reset link has been sent."}
    
    except Exception as e:
        print(f"ERROR in forgot_password: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    
@router.put("/preferences", response_model=UserResponse)
async def update_preferences(
    preferences_update: UserPreferencesUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user preferences"""
    try:
        user = db.query(User).filter(User.id == current_user.id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        if preferences_update.relationship_status is not None:
            user.relationship_status = preferences_update.relationship_status
        if preferences_update.children_status is not None:
            user.children_status = preferences_update.children_status
        if preferences_update.industry is not None:
            user.industry = preferences_update.industry
        if preferences_update.country is not None:
            user.country = preferences_update.country
        
        # Update dinner preferences
        if preferences_update.dinner_languages is not None:
            user.dinner_languages = json.dumps(preferences_update.dinner_languages)
        if preferences_update.dinner_budget is not None:
            user.dinner_budget = preferences_update.dinner_budget
        if preferences_update.has_dietary_restrictions is not None:
            user.has_dietary_restrictions = preferences_update.has_dietary_restrictions
        if preferences_update.dietary_options is not None:
            user.dietary_options = json.dumps(preferences_update.dietary_options)
        
        # Update notification preferences
        if preferences_update.event_push_notifications is not None:
            user.event_push_notifications = preferences_update.event_push_notifications
        if preferences_update.event_sms is not None:
            user.event_sms = preferences_update.event_sms
        if preferences_update.event_email is not None:
            user.event_email = preferences_update.event_email

        if preferences_update.lastminute_push_notifications is not None:
            user.lastminute_push_notifications = preferences_update.lastminute_push_notifications
        if preferences_update.lastminute_sms is not None:
            user.lastminute_sms = preferences_update.lastminute_sms
        if preferences_update.lastminute_email is not None:
            user.lastminute_email = preferences_update.lastminute_email
        if preferences_update.marketing_email is not None:
            user.marketing_email = preferences_update.marketing_email
        
        db.commit()
        db.refresh(user)
        
        # Use custom from_orm method to properly parse JSON fields
        return UserResponse.from_orm(user)
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/preferences", response_model=UserResponse)
async def get_preferences(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user preferences"""
    user = db.query(User).filter(User.id == current_user.id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Use custom from_orm method to properly parse JSON fields
    return UserResponse.from_orm(user)
    
@router.post("/reset-password")
async def reset_password(reset_data: PasswordReset, db: Session = Depends(get_db)):
    # Find user by reset token
    db_user = db.query(User).filter(User.password_reset_token == reset_data.token).first()
    
    if not db_user:
        raise HTTPException(
            status_code=404,
            detail="Invalid reset token"
        )
    
    # Check if reset token is expired (24 hours) - FIX: Use timezone-aware datetime
    if (db_user.password_reset_sent_at and 
        datetime.now(timezone.utc) - db_user.password_reset_sent_at > timedelta(hours=24)):
        raise HTTPException(
            status_code=400,
            detail="Reset token has expired"
        )
    
    # Update password
    db_user.password_hash = get_password_hash(reset_data.new_password)
    db_user.password_reset_token = None  # Clear the token
    db_user.password_reset_sent_at = None
    db.commit()
    
    return {"message": "Password reset successfully!"}

@router.post("/upload-profile-photo", response_model=dict)
async def upload_profile_photo(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload profile photo to S3 and update user profile"""
    
    # Validate file
    if not file.filename:
        raise HTTPException(
            status_code=400,
            detail="No file provided"
        )
    
    old_photo_url = current_user.profile_picture_url
    s3_service = S3Service()
    
    try:
        # Upload new image to S3
        new_photo_url = s3_service.upload_profile_image(file, current_user.id)
        
        # Update database
        current_user.profile_picture_url = new_photo_url
        db.commit()
        db.refresh(current_user)
        
        # Delete old photo after successful update
        if old_photo_url:
            s3_service.delete_profile_image(old_photo_url)
        
        # Return updated user data
        user_response = UserResponse.from_orm(current_user)
        
        return {
            "message": "Profile photo uploaded successfully",
            "profile_picture_url": new_photo_url,
            "user": user_response.dict()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Photo upload failed: {str(e)}"
        )
    
@router.post("/delete-account")
async def delete_account(
    deletion_request: AccountDeletionRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete user account with comprehensive cleanup"""
    try:
        # For Google users, skip password verification
        if current_user.google_id is None:
            if not verify_password(deletion_request.password, current_user.password_hash):
                raise HTTPException(
                    status_code=401,
                    detail="Incorrect password"
                )
        
        # Check confirmation text
        if deletion_request.confirmation_text.lower() != "delete my account":
            raise HTTPException(
                status_code=400,
                detail="Please type 'delete my account' to confirm deletion"
            )
        
        user_id = current_user.id
        
        try:
            # 1. Delete profile picture from S3 if exists
            if current_user.profile_picture_url:
                try:
                    s3_service = S3Service()
                    s3_service.delete_profile_image(current_user.profile_picture_url)
                except Exception as s3_error:
                    print(f"Failed to delete profile picture from S3: {s3_error}")
                    # Continue with account deletion even if S3 cleanup fails
            
            # 2. Cancel active subscriptions with payment providers
            if current_user.subscription_plan_id and current_user.is_subscribed:
                try:
                    # Cancel subscription with Stripe/PayPal/etc
                    # Example: stripe.Subscription.delete(current_user.subscription_plan_id)
                    pass
                except Exception as sub_error:
                    print(f"Failed to cancel subscription: {sub_error}")
            
            # 3. Delete the user record - this will cascade delete all related data
            # Thanks to properly configured foreign key constraints and relationships
            db.delete(current_user)
            db.commit()
            
            return {
                "message": "Account and all associated data successfully deleted"
            }

        except Exception as deletion_error:
            db.rollback()
            raise HTTPException(
                status_code=500,
                detail=f"Failed to delete account data: {str(deletion_error)}"
            )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete account: {str(e)}"
        )
    
    
@router.put("/subscription", response_model=UserResponse)
async def update_subscription(
    subscription_update: UserSubscriptionUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user subscription status"""
    try:
        user = db.query(User).filter(User.id == current_user.id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Update subscription fields
        if subscription_update.is_subscribed is not None:
            user.is_subscribed = subscription_update.is_subscribed
            
            # If unsubscribing, clear subscription data
            if not subscription_update.is_subscribed:
                user.subscription_start = None
                user.subscription_end = None
                user.subscription_type = None
                user.subscription_plan_id = None
        
        if subscription_update.subscription_start is not None:
            user.subscription_start = subscription_update.subscription_start
            
        if subscription_update.subscription_end is not None:
            user.subscription_end = subscription_update.subscription_end
            
        if subscription_update.subscription_type is not None:
            user.subscription_type = subscription_update.subscription_type
            
        if subscription_update.subscription_plan_id is not None:
            user.subscription_plan_id = subscription_update.subscription_plan_id
        
        db.commit()
        db.refresh(user)
        
        return UserResponse.from_orm(user)
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/subscription/activate")
async def activate_subscription(
    subscription_data: UserSubscriptionUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Activate a subscription for the current user"""
    try:
        user = db.query(User).filter(User.id == current_user.id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Activate subscription
        user.is_subscribed = True
        user.subscription_start = subscription_data.subscription_start or datetime.utcnow()
        user.subscription_end = subscription_data.subscription_end
        user.subscription_type = subscription_data.subscription_type or "monthly"
        user.subscription_plan_id = subscription_data.subscription_plan_id
        
        db.commit()
        db.refresh(user)
        
        return {
            "message": "Subscription activated successfully",
            "user": UserResponse.from_orm(user)
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Subscription activation failed: {str(e)}")

@router.post("/subscription/cancel")
async def cancel_subscription(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Cancel user subscription (but keep it active until end date)"""
    try:
        user = db.query(User).filter(User.id == current_user.id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        if not user.is_subscribed:
            raise HTTPException(status_code=400, detail="User is not subscribed")
        
        # Mark as cancelled but keep active until end date
        # You might want to add a 'cancelled' field to track this state
        # For now, we'll just not renew it by clearing the plan_id
        user.subscription_plan_id = None
        
        db.commit()
        db.refresh(user)
        
        return {
            "message": "Subscription cancelled. You can continue using the service until your subscription expires.",
            "user": UserResponse.from_orm(user)
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Subscription cancellation failed: {str(e)}")

@router.get("/subscription/status", response_model=dict)
async def get_subscription_status(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get detailed subscription status for the current user"""
    user = db.query(User).filter(User.id == current_user.id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {
        "is_subscribed": user.is_subscribed,
        "is_subscription_active": user.is_subscription_active,
        "subscription_start": user.subscription_start,
        "subscription_end": user.subscription_end,
        "subscription_type": user.subscription_type,
        "subscription_plan_id": user.subscription_plan_id,
        "days_until_subscription_expires": user.days_until_subscription_expires,
    }
# Keep your existing Google auth and other endpoints...

# Add this to your auth.py router

@router.post("/register-test-user", response_model=dict)
async def register_test_user(user: UserCreate, db: Session = Depends(get_db)):
    """Register a test user with auto-verification (for development only)"""
    
    # Check if user already exists
    db_user = get_user_by_email(db, user.email)
    if db_user:
        raise HTTPException(
            status_code=400,
            detail="Email already registered"
        )
    
    # Create user with auto-verification
    hashed_password = get_password_hash(user.password)
    
    db_user = User(
        email=user.email,
        password_hash=hashed_password,
        display_name=user.display_name,
        is_verified=True,  # Auto-verify test users
        verification_token=None,
        verification_sent_at=None
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return {
        "message": "Test user registered and auto-verified!",
        "user_id": db_user.id,
        "email": db_user.email
    }