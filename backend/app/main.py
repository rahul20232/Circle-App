import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime
import logging

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

logger = logging.getLogger("timeleft_api")

# Create database tables
user.Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting background services...")
    task = asyncio.create_task(BackgroundTaskService.start_notification_scheduler())
    
    logger.info(f"=== {settings.APP_NAME} API Started ===")
    logger.info(f"Application starting in {settings.ENVIRONMENT.value} mode")
    logger.info(f"Debug mode: {settings.DEBUG}")
    logger.info(f"Version: {settings.APP_VERSION}")
    logger.info(f"Database: {settings.DATABASE_URL.split('@')[-1].split('/')[0] if '@' in settings.DATABASE_URL else 'hidden'}")
    
    yield
    
    # Shutdown
    logger.info("Shutting down background services...")
    logger.info(f"=== {settings.APP_NAME} API Shutting Down ===")
    task.cancel()

app = FastAPI(
    lifespan=lifespan,
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    debug=settings.DEBUG,
    docs_url="/docs" if not is_production() else None,
    redoc_url="/redoc" if not is_production() else None,
    description="TimeLeft Clone API with comprehensive logging and security"
)

# Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["*"],
)
app.add_middleware(SecurityHeadersMiddleware)
if not is_development():
    app.add_middleware(
        RateLimitMiddleware,
        requests_per_minute=100 if is_production() else 500
    )
app.add_middleware(RequestLoggingMiddleware)

# Exception handlers
app.add_exception_handler(HTTPException, custom_http_exception_handler)
app.add_exception_handler(TimeleftException, custom_timeleft_exception_handler)
app.add_exception_handler(SQLAlchemyError, sqlalchemy_exception_handler)

# Include routers
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

@app.get("/")
async def root():
    """Root endpoint with basic API info"""
    return {
        "message": f"{settings.APP_NAME} API is running!",
        "environment": settings.ENVIRONMENT.value,
        "version": settings.APP_VERSION,
        "docs_url": "/docs" if not is_production() else "hidden",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/health")
async def health_check():
    """Basic health check"""
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT.value,
        "version": settings.APP_VERSION,
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/health/detailed")
async def detailed_health_check():
    """Comprehensive health check with database and external services"""
    
    health_status = {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "environment": settings.ENVIRONMENT.value,
        "version": settings.APP_VERSION,
        "checks": {}
    }
    
    overall_healthy = True
    
    # Database health check
    try:
        db_health = await HealthChecker.check_database()
        health_status["checks"]["database"] = db_health
        if db_health["status"] != "healthy":
            overall_healthy = False
    except Exception as e:
        logger.error(f"Database health check failed: {str(e)}")
        health_status["checks"]["database"] = {
            "status": "error",
            "error": str(e)
        }
        overall_healthy = False
    
    # External services health check
    try:
        services_health = await HealthChecker.check_external_services()
        health_status["checks"]["external_services"] = services_health
        
        for service, status in services_health.items():
            if status.get("status") == "unhealthy":
                overall_healthy = False
    except Exception as e:
        logger.error(f"External services health check failed: {str(e)}")
        health_status["checks"]["external_services"] = {
            "status": "error",
            "error": str(e)
        }
    
    # System information (development only)
    if is_development():
        try:
            system_info = await HealthChecker.get_system_info()
            health_status["system"] = system_info
        except Exception as e:
            logger.warning(f"Could not retrieve system info: {str(e)}")
    
    health_status["status"] = "healthy" if overall_healthy else "unhealthy"
    status_code = 200 if overall_healthy else 503
    
    return JSONResponse(
        status_code=status_code,
        content=health_status
    )

@app.get("/metrics")
async def metrics():
    """Basic metrics endpoint for monitoring"""
    return {
        "environment": settings.ENVIRONMENT.value,
        "version": settings.APP_VERSION,
        "timestamp": datetime.utcnow().isoformat(),
        "uptime": "Not implemented yet",
        "note": "Integrate with monitoring tools for production metrics"
    }

# Development-only endpoints
if is_development():
    @app.get("/debug/config")
    async def debug_config():
        """Debug endpoint to view current configuration"""
        return {
            "environment": settings.ENVIRONMENT.value,
            "debug": settings.DEBUG,
            "database_host": settings.DATABASE_URL.split("@")[-1].split("/")[0] if "@" in settings.DATABASE_URL else "hidden",
            "allowed_origins": settings.ALLOWED_ORIGINS,
            "s3_bucket": settings.S3_BUCKET_NAME,
            "frontend_url": settings.FRONTEND_URL,
            "access_token_expire_minutes": settings.ACCESS_TOKEN_EXPIRE_MINUTES,
        }
    
    @app.get("/debug/routes")
    async def debug_routes():
        """Debug endpoint to list all routes"""
        routes = []
        for route in app.routes:
            if hasattr(route, 'methods') and hasattr(route, 'path'):
                routes.append({
                    "path": route.path,
                    "methods": list(route.methods),
                    "name": getattr(route, 'name', 'unnamed')
                })
        return {"routes": routes}