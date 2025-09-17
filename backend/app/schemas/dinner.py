from pydantic import BaseModel, validator
from datetime import datetime
from typing import Optional, List
from app.schemas.user import UserResponse


class DinnerBase(BaseModel):
    title: str
    description: Optional[str] = None
    date: datetime
    location: str
    latitude: Optional[float] = None  # Add this
    longitude: Optional[float] = None  # Add this
    max_attendees: int = 6


class DinnerCreate(DinnerBase):
    pass


class DinnerUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    date: Optional[datetime] = None
    location: Optional[str] = None
    latitude: Optional[float] = None  # Add this
    longitude: Optional[float] = None  # Add this
    max_attendees: Optional[int] = None
    is_active: Optional[bool] = None

    @validator('max_attendees')
    def validate_max_attendees(cls, v):
        if v is not None and v < 1:
            raise ValueError('Max attendees must be at least 1')
        if v is not None and v > 20:
            raise ValueError('Max attendees cannot exceed 20')
        return v


class BookingBase(BaseModel):
    notes: Optional[str] = None


class BookingCreate(BookingBase):
    dinner_id: int


class BookingUpdate(BaseModel):
    notes: Optional[str] = None
    status: Optional[str] = None


class BookingResponse(BookingBase):
    id: int
    user_id: int
    dinner_id: int
    status: str
    booked_at: datetime
    updated_at: datetime
    has_been_rated: bool = False
    rating: Optional[int] = None 
    # user: Optional[UserResponse] = None

    class Config:
        from_attributes = True


class DinnerResponse(DinnerBase):
    id: int
    current_attendees: int
    available_spots: int
    is_full: bool
    is_active: bool
    created_at: datetime
    updated_at: datetime
    bookings: Optional[List[BookingResponse]] = None

    class Config:
        from_attributes = True


class DinnerListResponse(BaseModel):
    id: int
    title: str
    date: datetime
    location: str
    latitude: Optional[float] = None  # Add this
    longitude: Optional[float] = None  # Add this
    current_attendees: int
    available_spots: int
    is_full: bool

    class Config:
        from_attributes = True