# Add this to a new file: backend/seed_dinners.py
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from app.database import engine, get_db
from app.models.dinner import Dinner

def seed_dinners():
    """Add sample dinners to the database"""
    
    # Get database session
    db = next(get_db())
    
    # Sample dinners data
    sample_dinners = [
        {
            "title": "Welcome Wednesday Mixer",
            "description": "Join fellow professionals for an evening of networking and delicious food at one of Bangalore's finest restaurants.",
            "date": datetime.now() + timedelta(days=2, hours=20),  # 2 days from now at 8PM
            "location": "The Fatty Bao, Indiranagar",
            "max_attendees": 6,
            "is_active": True
        },
        {
            "title": "Startup Founders Dinner",
            "description": "An exclusive dinner for startup founders to share experiences and build connections.",
            "date": datetime.now() + timedelta(days=9, hours=20),  # 9 days from now at 8PM
            "location": "Toit, Koramangala",
            "max_attendees": 6,
            "is_active": True
        },
        {
            "title": "Tech Leaders Roundtable",
            "description": "Connect with senior tech professionals over an intimate dinner discussion.",
            "date": datetime.now() + timedelta(days=16, hours=20),  # 16 days from now at 8PM
            "location": "Smoke House Deli, UB City",
            "max_attendees": 6,
            "is_active": True
        },
        {
            "title": "Creative Minds Meetup",
            "description": "For designers, artists, and creative professionals looking to network and collaborate.",
            "date": datetime.now() + timedelta(days=23, hours=19, minutes=30),  # 23 days from now at 7:30PM
            "location": "Cafe Max, Cunningham Road",
            "max_attendees": 6,
            "is_active": True
        }
    ]
    
    # Check if dinners already exist to avoid duplicates
    existing_dinners = db.query(Dinner).count()
    if existing_dinners > 0:
        print(f"Database already has {existing_dinners} dinners. Skipping seed data.")
        return
    
    # Create dinner objects and add to database
    created_dinners = []
    for dinner_data in sample_dinners:
        dinner = Dinner(**dinner_data)
        db.add(dinner)
        created_dinners.append(dinner)
    
    try:
        db.commit()
        print(f"Successfully created {len(created_dinners)} sample dinners:")
        for dinner in created_dinners:
            print(f"  - {dinner.title} on {dinner.date.strftime('%A, %B %d at %I:%M %p')}")
    except Exception as e:
        db.rollback()
        print(f"Error creating dinners: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_dinners()