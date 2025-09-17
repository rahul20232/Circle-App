# backend/app/schemas/rating.py
from pydantic import BaseModel, validator
from typing import Optional

class RatingCreate(BaseModel):
    booking_id: int
    rating: int
    comment: Optional[str] = None
    
    @validator('rating')
    def validate_rating(cls, v):
        if v < 1 or v > 5:
            raise ValueError('Rating must be between 1 and 5')
        return v

class RatingResponse(BaseModel):
    booking_id: int
    rating: int
    comment: Optional[str] = None
    has_been_rated: bool = True
    
    class Config:
        from_attributes = True