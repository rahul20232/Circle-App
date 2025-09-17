import firebase_admin
from firebase_admin import credentials, messaging
from typing import List, Optional
import os
from app.core.config import settings

class PushNotificationService:
    _app = None
    
    @classmethod
    def initialize(cls):
        if cls._app is None:
            try:
                # Initialize Firebase Admin SDK
                cred = credentials.Certificate({
                    "type": "service_account",
                    "project_id": settings.FIREBASE_PROJECT_ID,
                    "private_key_id": settings.FIREBASE_PRIVATE_KEY_ID,
                    "private_key": settings.FIREBASE_PRIVATE_KEY.replace('\\n', '\n'),
                    "client_email": settings.FIREBASE_CLIENT_EMAIL,
                    "client_id": settings.FIREBASE_CLIENT_ID,
                    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                    "token_uri": "https://oauth2.googleapis.com/token",
                })
                cls._app = firebase_admin.initialize_app(cred)
                print("Firebase Admin SDK initialized successfully")
            except Exception as e:
                print(f"Error initializing Firebase Admin SDK: {e}")
                cls._app = None
    
    @classmethod
    def send_notification(
        cls,
        token: str,
        title: str,
        body: str,
        data: Optional[dict] = None
    ) -> bool:
        """Send push notification to a single device"""
        if cls._app is None:
            cls.initialize()
        
        if cls._app is None:
            print("Firebase not initialized, skipping push notification")
            return False
        
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                token=token,
                android=messaging.AndroidConfig(
                    notification=messaging.AndroidNotification(
                        channel_id="timeleft_notifications",
                        priority="high",
                    )
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            alert=messaging.ApsAlert(
                                title=title,
                                body=body,
                            ),
                            badge=1,
                            sound="default",
                        )
                    )
                )
            )
            
            response = messaging.send(message)
            print(f"Successfully sent message: {response}")
            return True
            
        except Exception as e:
            print(f"Error sending push notification: {e}")
            return False