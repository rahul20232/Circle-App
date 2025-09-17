# backend/app/routers/rating.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import List

from ..database import get_db
from ..models.booking import Booking, BookingStatus
from ..models.dinner import Dinner
from ..core.security import get_current_user
from ..models.user import User
from ..schemas.rating import RatingCreate, RatingResponse

router = APIRouter(prefix="/ratings", tags=["ratings"])

@router.post("/", response_model=RatingResponse)
async def rate_dinner(
    rating_data: RatingCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Rate a dinner booking"""
    # Verify booking belongs to current user
    booking = db.query(Booking).filter(
        Booking.id == rating_data.booking_id,
        Booking.user_id == current_user.id
    ).first()
    
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    
    if booking.status != BookingStatus.CONFIRMED:
        raise HTTPException(status_code=400, detail="Can only rate confirmed bookings")
    
    if booking.has_been_rated:
        raise HTTPException(status_code=400, detail="Booking has already been rated")
    
    # Check if dinner was in the past
    dinner = booking.dinner
    if dinner.date > datetime.utcnow():
        raise HTTPException(status_code=400, detail="Can only rate past dinners")
    
    # Update booking with rating
    booking.rating = rating_data.rating
    booking.has_been_rated = True
    booking.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(booking)
    
    return RatingResponse(
        booking_id=booking.id,
        rating=booking.rating,
        has_been_rated=booking.has_been_rated
    )

@router.get("/ratable-bookings")
async def get_ratable_bookings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get bookings that can be rated (confirmed, past, not yet rated)"""
    yesterday = datetime.utcnow() - timedelta(days=2)
    
    bookings = db.query(Booking).join(Dinner).filter(
        Booking.user_id == current_user.id,
        Booking.status == BookingStatus.CONFIRMED,
        Booking.has_been_rated == False,
        Dinner.date < datetime.utcnow(),
        Dinner.date >= yesterday  # Only show recent past dinners
    ).all()
    
    result = []
    for booking in bookings:
        result.append({
            "booking_id": booking.id,
            "dinner_id": booking.dinner_id,
            "dinner_title": booking.dinner.title,
            "dinner_date": booking.dinner.date,
            "dinner_location": booking.dinner.location,
            "can_rate": True
        })
    
    return result

@router.post("/create-test-ratable-booking")
async def create_test_ratable_booking(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a test booking for rating purposes (development only)"""
    from datetime import datetime, timedelta
    
    # Create a dinner from yesterday
    yesterday = datetime.utcnow() - timedelta(days=1)
    test_dinner = Dinner(
        title="Test Dinner for Rating",
        description="A test dinner to test rating functionality",
        date=yesterday,
        location="Test Restaurant, Bangalore",
        latitude=12.9716,
        longitude=77.5946,
        max_attendees=6
    )
    db.add(test_dinner)
    db.flush()  # Get the ID
    
    # Create a confirmed booking for this dinner
    test_booking = Booking(
        user_id=current_user.id,
        dinner_id=test_dinner.id,
        status=BookingStatus.CONFIRMED,
        has_been_rated=False
    )
    db.add(test_booking)
    db.commit()
    
    return {
        "message": "Test ratable booking created",
        "booking_id": test_booking.id,
        "dinner_id": test_dinner.id
    }