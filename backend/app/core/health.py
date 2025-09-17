# app/core/health.py
from datetime import datetime
from typing import Dict, Any
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from fastapi import HTTPException
import asyncio
import logging

from ..database import engine
from ..core.config import settings

logger = logging.getLogger("timeleft_api")

class HealthChecker:
    """Comprehensive health checking system"""
    
    @staticmethod
    async def check_database() -> Dict[str, Any]:
        """Check database connectivity and performance"""
        try:
            start_time = datetime.utcnow()
            
            with engine.connect() as conn:
                # Test basic connectivity
                result = conn.execute(text("SELECT 1"))
                result.fetchone()
                
                # Test a more complex query
                result = conn.execute(text("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public'"))
                table_count = result.fetchone()[0]
                
                # Calculate response time
                response_time = (datetime.utcnow() - start_time).total_seconds() * 1000
                
                return {
                    "status": "healthy",
                    "response_time_ms": round(response_time, 2),
                    "table_count": table_count,
                    "database_type": "postgresql",
                    "checked_at": datetime.utcnow().isoformat()
                }
                
        except SQLAlchemyError as e:
            logger.error(f"Database health check failed: {str(e)}")
            return {
                "status": "unhealthy",
                "error": "Database connection failed",
                "error_detail": str(e),
                "checked_at": datetime.utcnow().isoformat()
            }
        except Exception as e:
            logger.error(f"Unexpected error in database health check: {str(e)}")
            return {
                "status": "unhealthy", 
                "error": "Unexpected database error",
                "checked_at": datetime.utcnow().isoformat()
            }
    
    @staticmethod
    async def check_external_services() -> Dict[str, Any]:
        """Check external service connectivity (AWS S3, etc.)"""
        services_status = {}
        
        # Check AWS S3 (basic connectivity test)
        try:
            import boto3
            from botocore.exceptions import BotoCoreError, ClientError
            
            s3_client = boto3.client(
                's3',
                aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
                region_name=settings.AWS_REGION
            )
            
            # Test if bucket exists and is accessible
            start_time = datetime.utcnow()
            s3_client.head_bucket(Bucket=settings.S3_BUCKET_NAME)
            response_time = (datetime.utcnow() - start_time).total_seconds() * 1000
            
            services_status["s3"] = {
                "status": "healthy",
                "bucket": settings.S3_BUCKET_NAME,
                "region": settings.AWS_REGION,
                "response_time_ms": round(response_time, 2)
            }
            
        except (BotoCoreError, ClientError) as e:
            logger.warning(f"S3 health check failed: {str(e)}")
            services_status["s3"] = {
                "status": "unhealthy",
                "error": "S3 connectivity failed",
                "error_detail": str(e)
            }
        except Exception as e:
            logger.warning(f"Unexpected error in S3 health check: {str(e)}")
            services_status["s3"] = {
                "status": "unknown",
                "error": "Unexpected S3 error"
            }
        
        # Check Firebase (basic config validation)
        try:
            if all([
                settings.FIREBASE_PROJECT_ID,
                settings.FIREBASE_PRIVATE_KEY,
                settings.FIREBASE_CLIENT_EMAIL
            ]):
                services_status["firebase"] = {
                    "status": "configured",
                    "project_id": settings.FIREBASE_PROJECT_ID
                }
            else:
                services_status["firebase"] = {
                    "status": "misconfigured",
                    "error": "Missing Firebase configuration"
                }
        except Exception as e:
            services_status["firebase"] = {
                "status": "unknown",
                "error": str(e)
            }
        
        return services_status
    
    @staticmethod
    async def get_system_info() -> Dict[str, Any]:
        """Get system information"""
        import psutil
        import sys
        
        try:
            return {
                "python_version": sys.version,
                "memory_usage": {
                    "total": psutil.virtual_memory().total,
                    "available": psutil.virtual_memory().available,
                    "percent": psutil.virtual_memory().percent
                },
                "cpu_percent": psutil.cpu_percent(interval=1),
                "disk_usage": {
                    "total": psutil.disk_usage('/').total,
                    "used": psutil.disk_usage('/').used,
                    "free": psutil.disk_usage('/').free
                }
            }
        except ImportError:
            # psutil not installed
            return {
                "python_version": sys.version,
                "note": "Install psutil for detailed system metrics"
            }
        except Exception as e:
            return {
                "error": "Could not retrieve system info",
                "detail": str(e)
            }