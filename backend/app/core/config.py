import os
from enum import Enum
from dotenv import load_dotenv

# Load environment variables
env = os.getenv("ENVIRONMENT", "development")
env_file = f".env.{env}"

# Load .env file if it exists
if os.path.exists(env_file):
    load_dotenv(env_file)

class Environment(str, Enum):
    DEVELOPMENT = "development"
    STAGING = "staging" 
    PRODUCTION = "production"

def get_env_var(key: str, default=None, cast_type=str):
    """Get environment variable with optional casting"""
    value = os.getenv(key)
    
    # If environment variable doesn't exist, return default
    if value is None:
        return default
    
    # Cast the string value from environment
    if cast_type == bool:
        return value.lower() in ('true', '1', 'yes', 'on')
    elif cast_type == int:
        return int(value)
    else:
        return value

class Settings:
    def __init__(self):
        self.ENVIRONMENT = Environment(get_env_var("ENVIRONMENT", "development"))
        
        # App Info
        self.APP_NAME = get_env_var("APP_NAME", "TimeLeft Clone")
        self.APP_VERSION = get_env_var("APP_VERSION", "1.0.0")
        self.DEBUG = get_env_var("DEBUG", self.ENVIRONMENT == Environment.DEVELOPMENT, bool)
        
        # Security
        self.SECRET_KEY = get_env_var("SECRET_KEY")
        self.ALGORITHM = get_env_var("ALGORITHM", "HS256")
        self.ACCESS_TOKEN_EXPIRE_MINUTES = get_env_var("ACCESS_TOKEN_EXPIRE_MINUTES", 43200, int)
        
        # Database
        self.DATABASE_URL = get_env_var("DATABASE_URL")

        self.SUPABASE_URL = get_env_var("SUPABASE_URL", "https://vdsymjzmfrqzvetomswx.supabase.co")
        self.SUPABASE_SERVICE_KEY = get_env_var("SUPABASE_SERVICE_KEY", "")
        
        # CORS - Environment specific
        if self.ENVIRONMENT == Environment.PRODUCTION:
            self.ALLOWED_ORIGINS = [
                "https://circle-app-web-production.up.railway.app",
                "https://yourdomain.com",
                "https://www.yourdomain.com"
            ]
        elif self.ENVIRONMENT == Environment.STAGING:
            self.ALLOWED_ORIGINS = [
                "https://circle-app-web-production.up.railway.app",
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
        self.SMTP_SERVER = get_env_var("SMTP_SERVER", "smtp.gmail.com")
        self.SMTP_PORT = get_env_var("SMTP_PORT", 587, int)
        self.SENDER_EMAIL = get_env_var("SENDER_EMAIL", "")
        self.SENDER_PASSWORD = get_env_var("SENDER_PASSWORD", "")
        self.FRONTEND_URL = get_env_var("FRONTEND_URL", "http://localhost:8000")
        
        # AWS S3 settings
        self.AWS_ACCESS_KEY_ID = get_env_var("AWS_ACCESS_KEY_ID", "")
        self.AWS_SECRET_ACCESS_KEY = get_env_var("AWS_SECRET_ACCESS_KEY", "")
        self.AWS_REGION = get_env_var("AWS_REGION", "us-east-1")
        self.S3_BUCKET_NAME = get_env_var("S3_BUCKET_NAME", "")
        
        # Firebase
        self.FIREBASE_PROJECT_ID = get_env_var("FIREBASE_PROJECT_ID", "")
        self.FIREBASE_PRIVATE_KEY_ID = get_env_var("FIREBASE_PRIVATE_KEY_ID", "")
        self.FIREBASE_PRIVATE_KEY = get_env_var("FIREBASE_PRIVATE_KEY", "")
        self.FIREBASE_CLIENT_EMAIL = get_env_var("FIREBASE_CLIENT_EMAIL", "")
        self.FIREBASE_CLIENT_ID = get_env_var("FIREBASE_CLIENT_ID", "")
        
        # Google Services
        self.GOOGLE_GEOCODING_API_KEY = get_env_var("GOOGLE_GEOCODING_API_KEY", "")

        self.SENDGRID_API_KEY: str = get_env_var("SENDGRID_API_KEY", "")
        
        # Environment-specific settings
        if self.ENVIRONMENT == Environment.PRODUCTION:
            # Shorter token expiry in production for security
            self.ACCESS_TOKEN_EXPIRE_MINUTES = get_env_var("ACCESS_TOKEN_EXPIRE_MINUTES", 720, int)  # 12 hours

# Helper functions
def is_development() -> bool:
    return settings.ENVIRONMENT == Environment.DEVELOPMENT

def is_staging() -> bool:
    return settings.ENVIRONMENT == Environment.STAGING

def is_production() -> bool:
    return settings.ENVIRONMENT == Environment.PRODUCTION

# Global settings instance
settings = Settings()