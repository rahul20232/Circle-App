from decouple import Config, RepositoryEnv
from dotenv import load_dotenv
import os
from enum import Enum

env = os.getenv("ENVIRONMENT", "development")
env_file = f".env.{env}"

# Load into environment
if os.path.exists(env_file):
    load_dotenv(env_file)
    config = Config(RepositoryEnv(env_file))
else:
    # Fall back to environment variables directly
    config = Config()

class Environment(str, Enum):
    DEVELOPMENT = "development"
    STAGING = "staging" 
    PRODUCTION = "production"

class Settings:
    def __init__(self):
        self.ENVIRONMENT = Environment(config("ENVIRONMENT", default="development"))
        
        # App Info
        self.APP_NAME = config("APP_NAME", default="TimeLeft Clone")
        self.APP_VERSION = config("APP_VERSION", default="1.0.0")
        self.DEBUG = config("DEBUG", default=self.ENVIRONMENT == Environment.DEVELOPMENT, cast=bool)
        
        # Security
        self.SECRET_KEY = config("SECRET_KEY")
        self.ALGORITHM = config("ALGORITHM", default="HS256")
        self.ACCESS_TOKEN_EXPIRE_MINUTES = config("ACCESS_TOKEN_EXPIRE_MINUTES", default=43200, cast=int)
        
        # Database
        self.DATABASE_URL = config("DATABASE_URL")
        
        # CORS - Environment specific
        if self.ENVIRONMENT == Environment.PRODUCTION:
            self.ALLOWED_ORIGINS = [
                "https://yourdomain.com",
                "https://www.yourdomain.com"
            ]
        elif self.ENVIRONMENT == Environment.STAGING:
            self.ALLOWED_ORIGINS = [
                "https://staging.yourdomain.com"
            ]
        else:  # Development
            self.ALLOWED_ORIGINS = [
                "http://localhost:3000",
                "http://localhost:8080", 
                "http://192.168.18.22:8000",
                "http://127.0.0.1:3000"
            ]
        
        # Email settings
        self.SMTP_SERVER = config("SMTP_SERVER", default="smtp.gmail.com")
        self.SMTP_PORT = config("SMTP_PORT", default=587, cast=int)
        self.SENDER_EMAIL = config("SENDER_EMAIL")
        self.SENDER_PASSWORD = config("SENDER_PASSWORD")
        self.FRONTEND_URL = config("FRONTEND_URL")
        
        # AWS S3 settings
        self.AWS_ACCESS_KEY_ID = config("AWS_ACCESS_KEY_ID")
        self.AWS_SECRET_ACCESS_KEY = config("AWS_SECRET_ACCESS_KEY")
        self.AWS_REGION = config("AWS_REGION", default="us-east-1")
        self.S3_BUCKET_NAME = config("S3_BUCKET_NAME")
        
        # Firebase
        self.FIREBASE_PROJECT_ID = config("FIREBASE_PROJECT_ID", default="")
        self.FIREBASE_PRIVATE_KEY_ID = config("FIREBASE_PRIVATE_KEY_ID", default="")
        self.FIREBASE_PRIVATE_KEY = config("FIREBASE_PRIVATE_KEY", default="")
        self.FIREBASE_CLIENT_EMAIL = config("FIREBASE_CLIENT_EMAIL", default="")
        self.FIREBASE_CLIENT_ID = config("FIREBASE_CLIENT_ID", default="")
        
        # Google Services
        self.GOOGLE_GEOCODING_API_KEY = config("GOOGLE_GEOCODING_API_KEY", default="")
        
        # Environment-specific settings
        if self.ENVIRONMENT == Environment.PRODUCTION:
            # Shorter token expiry in production for security
            self.ACCESS_TOKEN_EXPIRE_MINUTES = config("ACCESS_TOKEN_EXPIRE_MINUTES", default=720, cast=int)  # 12 hours

# Helper functions
def is_development() -> bool:
    return settings.ENVIRONMENT == Environment.DEVELOPMENT

def is_staging() -> bool:
    return settings.ENVIRONMENT == Environment.STAGING

def is_production() -> bool:
    return settings.ENVIRONMENT == Environment.PRODUCTION

# Global settings instance
settings = Settings()