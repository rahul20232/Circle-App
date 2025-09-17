from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.notification import Notification
from app.schemas.notification import NotificationResponse, NotificationUpdate
from app.core.security import get_current_user
from app.models.user import User
from datetime import datetime

router = APIRouter(prefix="/notifications", tags=["notifications"])

@router.get("/", response_model=List[NotificationResponse])
async def get_user_notifications(
    skip: int = 0,
    limit: int = 50,
    unread_only: bool = False,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get notifications for the current user"""
    query = db.query(Notification).filter(Notification.user_id == current_user.id)
    
    if unread_only:
        query = query.filter(Notification.is_read == False)
    
    notifications = query.order_by(Notification.created_at.desc()).offset(skip).limit(limit).all()
    return notifications

@router.post("/test-notification")
async def create_test_notification(
    user_id: int,
    title: str = "Test Notification",
    message: str = "This is a test notification",
    notification_type: str = "booking_confirmed",
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)  # Only authenticated users can create test notifications
):
    """Create a test notification (for development only)"""
    from app.models.notification import NotificationType
    from app.services.notification_service import NotificationService
    
    # Convert string to enum
    try:
        type_enum = NotificationType(notification_type)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid notification type")
    
    notification = NotificationService.create_notification(
        db=db,
        user_id=user_id,
        notification_type=type_enum,
        title=title,
        message=message
    )
    
    return {"message": "Test notification created", "notification_id": notification.id}

@router.delete("/{notification_id}")
async def delete_notification(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a specific notification"""
    try:
        # Find the notification
        notification = db.query(Notification).filter(
            Notification.id == notification_id,
            Notification.user_id == current_user.id  # Ensure user owns the notification
        ).first()
        
        if not notification:
            raise HTTPException(
                status_code=404,
                detail="Notification not found or you don't have permission to delete it"
            )
        
        # Delete the notification
        db.delete(notification)
        db.commit()
        
        return {
            "message": "Notification deleted successfully",
            "notification_id": notification_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete notification: {str(e)}"
        )
    
@router.put("/{notification_id}/read")
async def mark_notification_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Mark a notification as read"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()
    
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    notification.is_read = True
    notification.read_at = datetime.utcnow()
    db.commit()
    
    return {"message": "Notification marked as read"}

@router.put("/read-all")
async def mark_all_notifications_read(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Mark all notifications as read for the current user"""
    db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).update({
        "is_read": True,
        "read_at": datetime.utcnow()
    })
    db.commit()
    
    return {"message": "All notifications marked as read"}

@router.get("/unread-count")
async def get_unread_count(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get count of unread notifications"""
    count = db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).count()
    
    return {"unread_count": count}