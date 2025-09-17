# backend/app/services/background_service.py
import asyncio
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.notification_service import NotificationService
import logging

logger = logging.getLogger(__name__)

class BackgroundTaskService:
    
    @staticmethod
    async def start_notification_scheduler():
        """Start the notification scheduler background task"""
        while True:
            try:
                # Process notifications every 5 minutes
                with next(get_db()) as db:
                    processed = NotificationService.process_scheduled_notifications(db)
                    if processed > 0:
                        logger.info(f"Processed {processed} scheduled notifications")
                
                # Wait 5 minutes before next check
                await asyncio.sleep(300)  # 5 minutes
                
            except Exception as e:
                logger.error(f"Error in notification scheduler: {e}")
                await asyncio.sleep(60)  # Wait 1 minute on error