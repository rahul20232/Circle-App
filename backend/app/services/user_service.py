from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserUpdate
from typing import Optional

def update_user_profile(db: Session, user_id: int, user_update: UserUpdate) -> Optional[User]:
    """Update user profile in database"""
    try:
        # user_id is already an integer from get_current_user
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return None
        
        print("REACHED 1")
        
        # Update only provided fields
        if user_update.display_name is not None:
            user.display_name = user_update.display_name
        if user_update.phone_number is not None:
            user.phone_number = user_update.phone_number

        print(user.display_name)
        print(user.phone_number)
        
        db.commit()
        db.refresh(user)
        return user
        
    except Exception as e:
        db.rollback()
        raise e
    
async def get_user_by_id(db: Session, user_id: str) -> Optional[User]:
    """Get user by ID"""
    return db.query(User).filter(User.id == user_id).first()