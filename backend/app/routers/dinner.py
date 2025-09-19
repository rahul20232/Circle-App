from app.models.notification import NotificationType
from app.services.notification_service import NotificationService
from app.services.connection_service import ConnectionService
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta

from app.database import get_db
from app.models.dinner import Dinner
from app.models.booking import Booking, BookingStatus
from app.schemas.dinner import (
    DinnerCreate, 
    DinnerUpdate, 
    DinnerResponse, 
    DinnerListResponse,
    BookingCreate,
    BookingResponse
)
from app.core.security import get_current_user
from app.models.user import User
from ..services.geocoding_service import GeocodingService 

router = APIRouter(prefix="/dinners", tags=["dinners"])

@router.post("/seed-dinners-no-auth")
async def seed_dinners_no_auth(db: Session = Depends(get_db)):
    """Create test dinners WITHOUT authentication (temporary)"""
    from app.models.dinner import Dinner
    from datetime import datetime, timedelta
    
    test_dinners = [
        Dinner(
            title="Italian Night at Mario's",
            description="Authentic Italian cuisine with wine pairing",
            date=datetime.now() + timedelta(days=2),
            location="Mario's Restaurant, Downtown",
            max_attendees=6
        ),
        Dinner(
            title="Sushi & Sake Experience", 
            description="Fresh sushi with premium sake tasting",
            date=datetime.now() + timedelta(days=5),
            location="Sakura Sushi Bar",
            max_attendees=4
        )
    ]
    
    for dinner in test_dinners:
        db.add(dinner)
    db.commit()
    
    return {"message": f"Created {len(test_dinners)} test dinners"}


@router.get("/", response_model=List[DinnerListResponse])
async def get_available_dinners(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """Get all available dinners (not full and active)"""
    dinners = db.query(Dinner).filter(
        Dinner.is_active == True,
        Dinner.date > datetime.utcnow()  # Only future dinners
    ).offset(skip).limit(limit).all()
    
    # Filter out full dinners
    available_dinners = [
        dinner for dinner in dinners 
        if not dinner.is_full
    ]
    
    return available_dinners

@router.get("/all", response_model=List[DinnerResponse])
async def get_all_dinners(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all dinners (including past ones) - for user's booking history"""
    dinners = db.query(Dinner).filter(
        Dinner.is_active == True
    ).order_by(Dinner.date.desc()).offset(skip).limit(limit).all()
    
    return dinners

@router.get("/{dinner_id}", response_model=DinnerResponse)
async def get_dinner(
    dinner_id: int,
    db: Session = Depends(get_db)
):
    """Get a specific dinner with booking details"""
    dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
    if not dinner:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dinner not found"
        )
    return dinner


@router.post("/", response_model=DinnerResponse)
async def create_dinner(
    dinner: DinnerCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new dinner with geocoded coordinates"""
    
    # Get coordinates for the location
    coordinates = GeocodingService.get_coordinates_free(dinner.location)
    
    dinner_data = dinner.dict()
    if coordinates:
        dinner_data['latitude'] = coordinates[0]
        dinner_data['longitude'] = coordinates[1]
    else:
        print(f"Failed to geocode: {dinner.location}")
    
    # BUG: You're using dinner.dict() instead of dinner_data
    db_dinner = Dinner(**dinner_data)  # Change this line
    db.add(db_dinner)
    db.commit()
    db.refresh(db_dinner)
    return db_dinner


@router.put("/{dinner_id}", response_model=DinnerResponse)
async def update_dinner(
    dinner_id: int,
    dinner_update: DinnerUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update a dinner (admin only for now)"""
    db_dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
    if not db_dinner:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dinner not found"
        )
    
    # Update only provided fields
    update_data = dinner_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_dinner, field, value)
    
    db.commit()
    db.refresh(db_dinner)
    return db_dinner


@router.delete("/{dinner_id}")
async def delete_dinner(
    dinner_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete a dinner (admin only for now)"""
    db_dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
    if not db_dinner:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dinner not found"
        )
    
    db.delete(db_dinner)
    db.commit()
    return {"message": "Dinner deleted successfully"}


@router.post("/{dinner_id}/book", response_model=BookingResponse)
async def book_dinner(
    dinner_id: int,
    booking_data: dict = None,  # Change this line - accept optional dict
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Book a dinner for the current user"""
    # Check if dinner exists
    dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
    if not dinner:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dinner not found"
        )
    
    # Check if dinner is active and not in the past
    if not dinner.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This dinner is no longer available"
        )
    
    if dinner.date <= datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot book past dinners"
        )
    
    # Check if dinner is full
    if dinner.is_full:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This dinner is fully booked"
        )
    
    # Check if user already has a booking for this dinner
    existing_booking = db.query(Booking).filter(
        Booking.user_id == current_user.id,
        Booking.dinner_id == dinner_id,
        Booking.status.in_([BookingStatus.PENDING, BookingStatus.CONFIRMED])
    ).first()
    
    if existing_booking:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already have a booking for this dinner"
        )
    
    # Extract notes from booking_data if provided
    notes = None
    if booking_data and isinstance(booking_data, dict):
        notes = booking_data.get('notes')
    
    # Create the booking
    db_booking = Booking(
        user_id=current_user.id,
        dinner_id=dinner_id,
        notes=notes,  # Use the extracted notes
        status=BookingStatus.CONFIRMED
    )
    
    db.add(db_booking)
    db.commit()
    db.refresh(db_booking)

    from app.services.notification_service import NotificationService
    NotificationService.schedule_booking_reminders(db, db_booking.id)
    
    # Send immediate confirmation notification
    NotificationService.notify_booking_confirmed(db, db_booking.id)
    
    return db_booking

@router.get("/user/bookings")
async def get_user_bookings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all bookings for the current user"""
    bookings = db.query(Booking).filter(Booking.user_id == current_user.id).all()
    
    result = []
    for booking in bookings:
        dinner = booking.dinner
        result.append({
            "id": booking.id,
            "dinner_id": booking.dinner_id,
            "status": booking.status.value,
            "notes": booking.notes,
            "booked_at": booking.booked_at,
            "updated_at": booking.updated_at,
            "has_been_rated": booking.has_been_rated,
            "rating": booking.rating,
            # Include dinner details
            "dinner_title": dinner.title,
            "dinner_date": dinner.date,
            "dinner_location": dinner.location,
            "dinner_latitude": dinner.latitude,
            "dinner_longitude": dinner.longitude,
        })
    
    return result

@router.put("/bookings/{booking_id}/cancel")
async def cancel_booking(
    booking_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Cancel a booking"""
    booking = db.query(Booking).filter(
        Booking.id == booking_id,
        Booking.user_id == current_user.id
    ).first()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    if booking.status == BookingStatus.CANCELLED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Booking is already cancelled"
        )
    
    booking.status = BookingStatus.CANCELLED
    NotificationService.delete_scheduled_notifications_for_booking(db, booking.id)

    NotificationService.notify_booking_cancelled(db, booking.id)
    
    db.commit()
    
    return {"message": "Booking cancelled successfully"}

@router.delete("/bookings/{booking_id}/remove")
async def remove_booking(
    booking_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Remove a booking from database (only for past or cancelled bookings)"""
    
    # Get the booking with dinner details
    booking = db.query(Booking).join(Dinner).filter(
        Booking.id == booking_id,
        Booking.user_id == current_user.id
    ).first()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Check if booking can be removed (only past dinners or cancelled bookings)
    is_past_dinner = booking.dinner.date < datetime.utcnow()
    is_cancelled = booking.status == BookingStatus.CANCELLED
    
    if not (is_past_dinner or is_cancelled):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Can only remove past dinners or cancelled bookings"
        )
    
    # Additional safety check: don't allow removal of recent bookings (within 1 hour)
    # This prevents accidental deletion of bookings that just finished
    if is_past_dinner:
        one_hour_ago = datetime.utcnow() - timedelta(hours=1)
        if booking.dinner.date > one_hour_ago:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot remove bookings for dinners that ended less than 1 hour ago"
            )
    
    # Store dinner title before deletion
    dinner_title = booking.dinner.title
    
    # Delete any scheduled notifications for this booking
    try:
        NotificationService.delete_scheduled_notifications_for_booking(db, booking.id)
    except Exception as e:
        print(f"Error deleting notifications for booking {booking.id}: {e}")
        # Continue with deletion even if notification cleanup fails
    
    # Delete the booking from database
    db.delete(booking)
    db.commit()
    
    return {
        "message": "Booking removed successfully",
        "booking_id": booking_id,
        "dinner_title": dinner_title
    }

@router.get("/{dinner_id}/users")
async def get_users_from_dinner(
    dinner_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all users who have bookings for a specific dinner"""
    
    # Check if dinner exists
    dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
    if not dinner:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dinner not found"
        )
    
    # Get users with confirmed/pending bookings
    users = db.query(User).join(Booking).filter(
        Booking.dinner_id == dinner_id,
        Booking.status.in_([BookingStatus.CONFIRMED, BookingStatus.PENDING])
    ).all()
    
    # Format response
    user_list = []
    for user in users:
        user_list.append({
            "id": user.id,
            "display_name": user.display_name,
            "email": user.email,
            "profile_picture_url": user.profile_picture_url
        })
    
    return {
        "dinner_id": dinner_id,
        "dinner_title": dinner.title,
        "total_users": len(user_list),
        "users": user_list
    }

# @router.get("/{dinner_id}/users")
# async def get_users_from_dinner(
#     dinner_id: int,
#     db: Session = Depends(get_db),
#     current_user: User = Depends(get_current_user)
# ):
#     """Get all users who have bookings for a specific dinner (only if dinner is max 1 day old)"""
    
#     # Check if dinner exists
#     dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
#     if not dinner:
#         raise HTTPException(
#             status_code=status.HTTP_404_NOT_FOUND,
#             detail="Dinner not found"
#         )
    
#     # Check if dinner is maximum 1 day old
#     one_day_ago = datetime.utcnow() - timedelta(days=1)
#     if dinner.date < one_day_ago:
#         raise HTTPException(
#             status_code=status.HTTP_403_FORBIDDEN,
#             detail="Cannot access attendee information for dinners older than 1 day"
#         )
    
#     # Get users with confirmed/pending bookings
#     users = db.query(User).join(Booking).filter(
#         Booking.dinner_id == dinner_id,
#         Booking.status.in_([BookingStatus.CONFIRMED, BookingStatus.PENDING])
#     ).all()
    
#     # Format response
#     user_list = []
#     for user in users:
#         user_list.append({
#             "id": user.id,
#             "display_name": user.display_name,
#             "email": user.email,
#             "profile_picture_url": user.profile_picture_url
#         })
    
#     return {
#         "dinner_id": dinner_id,
#         "dinner_title": dinner.title,
#         "total_users": len(user_list),
#         "users": user_list
#     }

@router.get("/user/recent-dinner-attendees")
async def get_recent_dinner_attendees(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get attendees from user's most recent confirmed dinner (only if dinner is max 1 day old)"""
    
    # Get user's most recent confirmed booking (within the last 2 days)
    one_day_ago = datetime.utcnow() - timedelta(days=2)
    recent_booking = db.query(Booking).join(Dinner).filter(
        Booking.user_id == current_user.id,
        Booking.status == BookingStatus.CONFIRMED,
        Dinner.date < datetime.utcnow(),  # Only past dinners
        Dinner.date >= one_day_ago  # Only dinners within the last day
    ).order_by(Dinner.date.desc()).first()
    
    if not recent_booking:
        return {
            "dinner_id": None,
            "dinner_title": None,
            "attendees": []
        }
    
    # Get all other users who have confirmed bookings for the same dinner
    other_users = db.query(User).join(Booking).filter(
        Booking.dinner_id == recent_booking.dinner_id,
        Booking.status == BookingStatus.CONFIRMED,
        Booking.user_id != current_user.id  # Exclude current user
    ).all()
    
    # Check connection status for each user
    attendees_list = []
    for user in other_users:
        # Get connection status between current user and this attendee
        connection_status = ConnectionService.get_connection_status(
            db, current_user.id, user.id
        )
        
        attendees_list.append({
            "id": user.id,
            "display_name": user.display_name,
            "profile_picture_url": user.profile_picture_url,
            "industry": user.industry,
            "connection_request_sent": connection_status["connection_request_sent"],
            "already_connected": connection_status["already_connected"]
        })
    
    return {
        "dinner_id": recent_booking.dinner_id,
        "dinner_title": recent_booking.dinner.title,
        "attendees": attendees_list
    }

@router.get("/user/dinner-id-attendees")
async def get_dinner_id_attendees(
    dinner_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get attendees for a specific dinner by dinner ID (user must have confirmed booking for this dinner)"""
    
    # Check if dinner exists
    dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
    if not dinner:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dinner not found"
        )
    
    # Check if current user has a confirmed booking for this dinner
    user_booking = db.query(Booking).filter(
        Booking.user_id == current_user.id,
        Booking.dinner_id == dinner_id,
        Booking.status == BookingStatus.CONFIRMED
    ).first()
    
    if not user_booking:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only view attendees for dinners you have confirmed bookings for"
        )
    
    # Get all other users who have confirmed bookings for this dinner
    other_users = db.query(User).join(Booking).filter(
        Booking.dinner_id == dinner_id,
        Booking.status == BookingStatus.CONFIRMED,
        Booking.user_id != current_user.id  # Exclude current user
    ).all()
    
    # Check connection status for each user
    attendees_list = []
    for user in other_users:
        # Get connection status between current user and this attendee
        connection_status = ConnectionService.get_connection_status(
            db, current_user.id, user.id
        )
        
        attendees_list.append({
            "id": user.id,
            "display_name": user.display_name,
            "profile_picture_url": user.profile_picture_url,
            "industry": user.industry,
            "connection_request_sent": connection_status["connection_request_sent"],
            "already_connected": connection_status["already_connected"]
        })
    
    return {
        "dinner_id": dinner_id,
        "dinner_title": dinner.title,
        "dinner_date": dinner.date,
        "total_attendees": len(attendees_list),
        "attendees": attendees_list
    }
    
@router.post("/admin/send-to-dinner")
async def admin_send_notification_to_dinner(
    dinner_id: int,
    title: str,
    message: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Admin endpoint to send notification to all users of a specific dinner"""
    # TODO: Add admin role check here
    # if not current_user.is_admin:
    #     raise HTTPException(status_code=403, detail="Admin access required")
    
    from app.services.notification_service import NotificationService
    
    # Check if dinner exists
    dinner = db.query(Dinner).filter(Dinner.id == dinner_id).first()
    if not dinner:
        raise HTTPException(status_code=404, detail="Dinner not found")
    
    notifications = NotificationService.send_admin_notification_to_dinner_users(
        db=db,
        dinner_id=dinner_id,
        title=title,
        message=message,
        admin_user_id=current_user.id
    )
    
    return {
        "message": f"Notification sent to {len(notifications)} users",
        "notifications_sent": len(notifications)
    }

@router.post("/admin/send-to-booking")
async def admin_send_notification_to_booking(
    booking_id: int,
    title: str,
    message: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Admin endpoint to send notification to a specific booking user"""
    # TODO: Add admin role check
    
    from app.services.notification_service import NotificationService
    
    # Check if booking exists
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    
    notification = NotificationService.create_notification(
        db=db,
        user_id=booking.user_id,
        notification_type=NotificationType.DINNER_UPDATED,
        title=title,
        message=message,
        dinner_id=booking.dinner_id,
        booking_id=booking_id
    )
    
    return {
        "message": "Notification sent successfully",
        "notification_id": notification.id
    }