from sqlalchemy.orm import Session
from typing import List, Optional
from app.models.notification import Notification, NotificationType
from app.models.booking import Booking, BookingStatus
from app.models.dinner import Dinner
from app.models.user import User
from datetime import datetime, timedelta

from app.models.scheduled_notification import ScheduledNotification, ScheduledNotificationType

from app.services.push_notification_service import PushNotificationService

class NotificationService:
    
    @staticmethod
    def create_notification(
        db: Session,
        user_id: int,
        notification_type: NotificationType,
        title: str,
        message: str,
        dinner_id: Optional[int] = None,
        booking_id: Optional[int] = None,
        connection_id: Optional[int] = None,
        send_push: bool = True  # Add this parameter
    ) -> Notification:
        """Create a single notification"""
        notification = Notification(
            user_id=user_id,
            dinner_id=dinner_id,
            booking_id=booking_id,
            connection_id=connection_id,
            type=notification_type,
            title=title,
            message=message
        )
        db.add(notification)
        db.commit()
        db.refresh(notification)
        
        # Send push notification if enabled
        if send_push:
            user = db.query(User).filter(User.id == user_id).first()
            if user and user.fcm_token:
                PushNotificationService.send_notification(
                    token=user.fcm_token,
                    title=title,
                    body=message,
                    data={
                        "notification_type": notification_type.value if hasattr(notification_type, 'value') else str(notification_type),
                        "notification_id": str(notification.id),
                        "connection_id": str(connection_id) if connection_id else None,
                        "booking_id": str(booking_id) if booking_id else None,
                        "dinner_id": str(dinner_id) if dinner_id else None,
                    }
                )
        
        return notification

    @staticmethod
    def notify_dinner_users(
        db: Session,
        dinner_id: int,
        notification_type: NotificationType,
        title: str,
        message: str,
        exclude_user_id: Optional[int] = None
    ) -> List[Notification]:
        """Send notification to all users who have bookings for a dinner"""
        # Get all confirmed bookings for this dinner
        bookings = db.query(Booking).filter(
            Booking.dinner_id == dinner_id,
            Booking.status.in_([BookingStatus.CONFIRMED, BookingStatus.PENDING])
        ).all()
        
        notifications = []
        for booking in bookings:
            # Skip if this is the user who triggered the notification
            if exclude_user_id and booking.user_id == exclude_user_id:
                continue
                
            notification = NotificationService.create_notification(
                db=db,
                user_id=booking.user_id,
                notification_type=notification_type,
                title=title,
                message=message,
                dinner_id=dinner_id,
                booking_id=booking.id
            )
            notifications.append(notification)
        
        return notifications
    
    @staticmethod
    def notify_booking_confirmed(db: Session, booking_id: int):
        """Send notification when booking is confirmed"""
        booking = db.query(Booking).filter(Booking.id == booking_id).first()
        if not booking:
            return None
            
        dinner = booking.dinner
        NotificationService.create_notification(
            db=db,
            user_id=booking.user_id,
            notification_type=NotificationType.BOOKING_CONFIRMED,
            title="Booking Confirmed!",
            message=f"Your booking for '{dinner.title}' has been confirmed.",
            dinner_id=booking.dinner_id,
            booking_id=booking_id
        )
    
    @staticmethod
    def notify_booking_cancelled(db: Session, booking_id: int):
        """Send notification when booking is confirmed"""
        booking = db.query(Booking).filter(Booking.id == booking_id).first()
        if not booking:
            return None
            
        dinner = booking.dinner
        NotificationService.create_notification(
            db=db,
            user_id=booking.user_id,
            notification_type=NotificationType.BOOKING_CONFIRMED,
            title="Booking Cancelled!",
            message=f"Your booking for '{dinner.title}' has been cancalled.",
            dinner_id=booking.dinner_id,
            booking_id=booking_id
        )
    
    @staticmethod
    def notify_dinner_updated(db: Session, dinner_id: int, update_message: str):
        """Notify all dinner participants about updates"""
        dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
        if not dinner:
            return []
            
        return NotificationService.notify_dinner_users(
            db=db,
            dinner_id=dinner_id,
            notification_type=NotificationType.DINNER_UPDATED,
            title=f"Update: {dinner.title}",
            message=update_message
        )
    
    @staticmethod
    def notify_dinner_cancelled(db: Session, dinner_id: int):
        """Notify all participants that dinner is cancelled"""
        dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
        if not dinner:
            return []
            
        return NotificationService.notify_dinner_users(
            db=db,
            dinner_id=dinner_id,
            notification_type=NotificationType.DINNER_CANCELLED,
            title="Dinner Cancelled",
            message=f"Unfortunately, '{dinner.title}' has been cancelled. You will receive a full refund."
        )
    

    @staticmethod
    def schedule_booking_reminders(db: Session, booking_id: int):
        """Schedule reminder notifications for a booking"""
        booking = db.query(Booking).filter(Booking.id == booking_id).first()
        
        if not booking:
            return
        
        dinner_datetime = booking.dinner.date
        
        # Schedule day-before reminder (at 6 PM the day before)
        day_before = dinner_datetime.date() - timedelta(days=1)
        day_before_time = datetime.combine(day_before, datetime.min.time().replace(hour=18, minute=0))
        
        # Only schedule if it's in the future
        if day_before_time > datetime.utcnow():
            scheduled_notification = ScheduledNotification(
                booking_id=booking_id,
                notification_type=ScheduledNotificationType.DAY_BEFORE_REMINDER,
                scheduled_time=day_before_time
            )
            db.add(scheduled_notification)

        # Schedule day-of reminder (2 hours before dinner)
        day_of_time = dinner_datetime - timedelta(hours=2)
        
        if day_of_time > datetime.utcnow():
            scheduled_notification = ScheduledNotification(
                booking_id=booking_id,
                notification_type=ScheduledNotificationType.DAY_OF_REMINDER,
                scheduled_time=day_of_time
            )
            db.add(scheduled_notification)
        
        db.commit()


    @staticmethod
    def process_scheduled_notifications(db: Session):
        """Process due scheduled notifications (call this from a background task)"""
        now = datetime.utcnow()
        
        # Get all unsent notifications that are due
        due_notifications = db.query(ScheduledNotification).filter(
            ScheduledNotification.is_sent == False,
            ScheduledNotification.scheduled_time <= now
        ).all()
        
        for scheduled in due_notifications:
            booking = scheduled.booking
            dinner = booking.dinner
            
            if scheduled.notification_type == ScheduledNotificationType.DAY_BEFORE_REMINDER:
                title = f"Reminder: {dinner.title} Tomorrow"
                message = f"Don't forget! You have dinner at {dinner.location} tomorrow at {dinner.date.strftime('%I:%M %p')}."
            else:  # DAY_OF_REMINDER
                title = f"Today: {dinner.title}"
                message = f"Your dinner is in 2 hours at {dinner.location}. See you there!"
            
            # Create the actual notification
            NotificationService.create_notification(
                db=db,
                user_id=booking.user_id,
                notification_type=NotificationType.DINNER_REMINDER,
                title=title,
                message=message,
                dinner_id=booking.dinner_id,
                booking_id=booking.id
            )
            
            # Mark as sent
            scheduled.is_sent = True
            scheduled.sent_at = now
        
        db.commit()
        return len(due_notifications)

    @staticmethod
    def delete_scheduled_notifications_for_booking(db: Session, booking_id: int):
        """Delete all scheduled notifications for a booking (e.g., if cancelled)."""
        db.query(ScheduledNotification).filter(
            ScheduledNotification.booking_id == booking_id,
            ScheduledNotification.is_sent == False
        ).delete(synchronize_session=False)
        db.commit()

    @staticmethod
    def send_admin_notification_to_dinner_users(
        db: Session,
        dinner_id: int,
        title: str,
        message: str,
        admin_user_id: int
    ) -> List[Notification]:
        """Admin endpoint to send custom notifications to all dinner participants"""
        return NotificationService.notify_dinner_users(
            db=db,
            dinner_id=dinner_id,
            notification_type=NotificationType.DINNER_UPDATED,
            title=title,
            message=message,
            exclude_user_id=None  # Don't exclude admin
        )