import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime
import logging
import traceback
import os

# Configure logging first
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("timeleft_api")

from .database import engine
from .models import user
from .routers import auth, gemini, imagegen, gemini_image_edit, dinner, notification, rating, websocket, chat, connection
from .core.config import settings, is_development, is_production
from .core.health import HealthChecker
from .core.exceptions import (
    custom_http_exception_handler, 
    custom_timeleft_exception_handler,
    sqlalchemy_exception_handler,
    TimeleftException
)

from .middleware import RequestLoggingMiddleware, SecurityHeadersMiddleware, RateLimitMiddleware
from app.services.background_service import BackgroundTaskService

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("=== STARTING LIFESPAN STARTUP ===")
    
    try:
        logger.info("Starting up TimeLeft API...")
        print("Starting up TimeLeft API...")
        
        # Create database tables
        try:
            print("Creating database tables...")
            user.Base.metadata.create_all(bind=engine)
            print("✓ Database tables created successfully")
        except Exception as e:
            print(f"✗ Failed to create database tables: {str(e)}")
            logger.error(f"Failed to create database tables: {str(e)}")
        
        # Start background services (only if available and not blocking)
        background_task = None
        if BackgroundTaskService:
            try:
                print("Starting background services...")
                # Don't await this - let it run in background
                background_task = asyncio.create_task(
                    BackgroundTaskService.start_notification_scheduler()
                )
                print("✓ Background services task created")
            except Exception as e:
                print(f"✗ Failed to start background services: {str(e)}")
                logger.error(f"Failed to start background services: {str(e)}")
        else:
            print("⚠ Background service not available, skipping...")
        
        print("=== STARTUP COMPLETE ===")
        logger.info(f"=== {settings.APP_NAME} API Started Successfully ===")
        
        yield
        
    except Exception as e:
        print(f"✗ STARTUP FAILED: {str(e)}")
        print(traceback.format_exc())
        logger.error(f"Startup failed: {str(e)}")
        logger.error(traceback.format_exc())
        raise
    
    # Shutdown
    print("=== STARTING SHUTDOWN ===")
    try:
        logger.info("Shutting down...")
        if background_task and not background_task.done():
            background_task.cancel()
        logger.info("=== Shutdown complete ===")
    except Exception as e:
        logger.error(f"Shutdown error: {str(e)}")

print("=== CREATING FASTAPI APP ===")

app = FastAPI(
    lifespan=lifespan,
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    debug=settings.DEBUG,
    docs_url="/docs" if not is_production() else None,
    redoc_url="/redoc" if not is_production() else None,
    description="TimeLeft Clone API with comprehensive logging and security"
)

print("✓ FastAPI app created")

# Middleware
try:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
        allow_headers=["*"],
    )
    print("✓ CORS middleware added")
    
    app.add_middleware(SecurityHeadersMiddleware)
    print("✓ Security middleware added")
    
    if not is_development():
        app.add_middleware(
            RateLimitMiddleware,
            requests_per_minute=100 if is_production() else 500
        )
        print("✓ Rate limit middleware added")
    
    app.add_middleware(RequestLoggingMiddleware)
    print("✓ Logging middleware added")
except Exception as e:
    print(f"✗ Middleware setup failed: {e}")
    raise

# Exception handlers
try:
    app.add_exception_handler(HTTPException, custom_http_exception_handler)
    app.add_exception_handler(TimeleftException, custom_timeleft_exception_handler)
    app.add_exception_handler(SQLAlchemyError, sqlalchemy_exception_handler)
    print("✓ Exception handlers added")
except Exception as e:
    print(f"✗ Exception handlers setup failed: {e}")
    raise

# Include routers
try:
    app.include_router(auth.router, prefix="/api")
    app.include_router(gemini.router, prefix="/api")
    app.include_router(imagegen.router, prefix="/api")
    app.include_router(gemini_image_edit.router, prefix="/api")
    app.include_router(dinner.router, prefix="/api")
    app.include_router(notification.router, prefix="/api")
    app.include_router(rating.router, prefix="/api")
    app.include_router(websocket.router, prefix="/api")
    app.include_router(chat.router, prefix="/api")
    app.include_router(connection.router, prefix="/api")
    print("✓ All routers included")
except Exception as e:
    print(f"✗ Router setup failed: {e}")
    raise

@app.get("/")
async def root():
    """Root endpoint with basic API info"""
    return {
        "message": f"{settings.APP_NAME} API is running!",
        "environment": settings.ENVIRONMENT.value,
        "version": settings.APP_VERSION,
        "docs_url": "/docs" if not is_production() else "hidden",
        "timestamp": datetime.utcnow().isoformat(),
        "port": os.getenv("PORT", "unknown")
    }

@app.get("/health")
async def health_check():
    """Basic health check"""
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT.value,
        "version": settings.APP_VERSION,
        "timestamp": datetime.utcnow().isoformat(),
        "port": os.getenv("PORT", "unknown")
    }

@app.get("/test")
async def test_endpoint():
    """Simple test endpoint"""
    return {
        "message": "Test successful", 
        "timestamp": datetime.utcnow().isoformat(),
        "environment": settings.ENVIRONMENT.value,
        "port": os.getenv("PORT", "unknown")
    }

print("=== APP SETUP COMPLETE ===")
print(f"Environment: {settings.ENVIRONMENT.value}")
print(f"Debug mode: {settings.DEBUG}")
print(f"Port: {os.getenv('PORT', 'not set')}")