# app/core/exceptions.py
from fastapi import HTTPException, Request, status
from fastapi.responses import JSONResponse
from fastapi.exception_handlers import http_exception_handler
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime
import logging

logger = logging.getLogger("timeleft_api")

class TimeleftException(Exception):
    """Base exception for Timeleft application"""
    
    def __init__(self, message: str, status_code: int = 500, details: dict = None):
        self.message = message
        self.status_code = status_code
        self.details = details or {}
        super().__init__(self.message)

class DatabaseError(TimeleftException):
    """Database related errors"""
    
    def __init__(self, message: str = "Database operation failed", details: dict = None):
        super().__init__(message, status_code=500, details=details)

class ValidationError(TimeleftException):
    """Input validation errors"""
    
    def __init__(self, message: str = "Validation failed", details: dict = None):
        super().__init__(message, status_code=400, details=details)

class AuthenticationError(TimeleftException):
    """Authentication related errors"""
    
    def __init__(self, message: str = "Authentication failed", details: dict = None):
        super().__init__(message, status_code=401, details=details)

class AuthorizationError(TimeleftException):
    """Authorization related errors"""
    
    def __init__(self, message: str = "Insufficient permissions", details: dict = None):
        super().__init__(message, status_code=403, details=details)

class NotFoundError(TimeleftException):
    """Resource not found errors"""
    
    def __init__(self, message: str = "Resource not found", details: dict = None):
        super().__init__(message, status_code=404, details=details)

class RateLimitError(TimeleftException):
    """Rate limiting errors"""
    
    def __init__(self, message: str = "Rate limit exceeded", details: dict = None):
        super().__init__(message, status_code=429, details=details)


async def custom_http_exception_handler(request: Request, exc: HTTPException):
    """Custom HTTP exception handler with request context"""
    
    # Get request ID if available
    request_id = getattr(request.state, 'request_id', 'unknown')
    
    # Log the exception
    logger.error(
        f"HTTP Exception: {exc.status_code} - {exc.detail}",
        extra={
            "request_id": request_id,
            "method": request.method,
            "url": str(request.url),
            "status_code": exc.status_code,
            "detail": exc.detail
        }
    )
    
    # Create standardized error response
    error_response = {
        "error": {
            "message": exc.detail,
            "status_code": exc.status_code,
            "timestamp": datetime.utcnow().isoformat(),
            "request_id": request_id,
            "path": request.url.path
        }
    }
    
    # Add headers if present
    headers = getattr(exc, 'headers', None)
    
    return JSONResponse(
        status_code=exc.status_code,
        content=error_response,
        headers=headers
    )


async def custom_timeleft_exception_handler(request: Request, exc: TimeleftException):
    """Custom handler for our application exceptions"""
    
    request_id = getattr(request.state, 'request_id', 'unknown')
    
    logger.error(
        f"Application Exception: {exc.message}",
        extra={
            "request_id": request_id,
            "method": request.method,
            "url": str(request.url),
            "status_code": exc.status_code,
            "details": exc.details
        }
    )
    
    error_response = {
        "error": {
            "message": exc.message,
            "status_code": exc.status_code,
            "timestamp": datetime.utcnow().isoformat(),
            "request_id": request_id,
            "path": request.url.path
        }
    }
    
    # Add details if available
    if exc.details:
        error_response["error"]["details"] = exc.details
    
    return JSONResponse(
        status_code=exc.status_code,
        content=error_response
    )


async def sqlalchemy_exception_handler(request: Request, exc: SQLAlchemyError):
    """Handle SQLAlchemy database errors"""
    
    request_id = getattr(request.state, 'request_id', 'unknown')
    
    logger.error(
        f"Database Exception: {str(exc)}",
        extra={
            "request_id": request_id,
            "method": request.method,
            "url": str(request.url),
            "exception_type": type(exc).__name__
        }
    )
    
    error_response = {
        "error": {
            "message": "A database error occurred",
            "status_code": 500,
            "timestamp": datetime.utcnow().isoformat(),
            "request_id": request_id,
            "path": request.url.path
        }
    }
    
    return JSONResponse(
        status_code=500,
        content=error_response
    )