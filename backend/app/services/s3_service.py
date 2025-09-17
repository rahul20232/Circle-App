import boto3
import uuid
from fastapi import HTTPException, UploadFile
from ..core.config import settings
import os
from typing import Optional

class S3Service:
    def __init__(self):
        self.s3_client = boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_REGION
        )
        self.bucket_name = settings.S3_BUCKET_NAME
    
    def upload_profile_image(self, file: UploadFile, user_id: int) -> str:
        """Upload profile image to S3 and return the URL"""
        try:
            # Get file extension to determine type
            file_extension = file.filename.split('.')[-1].lower() if '.' in file.filename else 'jpg'
            
            # Validate file extension instead of content_type (more reliable)
            allowed_extensions = ['jpg', 'jpeg', 'png', 'webp']
            if file_extension not in allowed_extensions:
                raise HTTPException(
                    status_code=400,
                    detail="Invalid file type. Only JPEG, PNG, and WebP are allowed."
                )
            
            # Set content type based on extension (more reliable than file.content_type)
            content_type_map = {
                'jpg': 'image/jpeg',
                'jpeg': 'image/jpeg', 
                'png': 'image/png',
                'webp': 'image/webp'
            }
            content_type = content_type_map.get(file_extension, 'image/jpeg')
            
            # Validate file size (5MB limit)
            max_size = 5 * 1024 * 1024  # 5MB
            file.file.seek(0, 2)  # Seek to end
            file_size = file.file.tell()
            file.file.seek(0)  # Reset to beginning
            
            if file_size > max_size:
                raise HTTPException(
                    status_code=400,
                    detail="File too large. Maximum size is 5MB."
                )
            
            # Generate unique filename
            unique_filename = f"profile_pictures/{user_id}_{uuid.uuid4()}.{file_extension}"
            
            # Upload to S3
            self.s3_client.upload_fileobj(
                file.file,
                self.bucket_name,
                unique_filename,
                ExtraArgs={
                    'ContentType': content_type
                }
            )
            
            # Generate pre-signed URL (valid for 1 year)
            presigned_url = self.s3_client.generate_presigned_url(
                'get_object',
                Params={'Bucket': self.bucket_name, 'Key': unique_filename},
                ExpiresIn=31536000  # 1 year
            )
            
            # Return the pre-signed URL
            return presigned_url
            
        except Exception as e:
            if isinstance(e, HTTPException):
                raise
            raise HTTPException(
                status_code=500,
                detail=f"Failed to upload image: {str(e)}"
            )
    
    def delete_profile_image(self, image_url: str) -> bool:
        """Delete profile image from S3 using the URL"""
        try:
            # Extract the key from the URL
            # URL format: https://bucket.s3.region.amazonaws.com/key
            key = image_url.split(f"{self.bucket_name}.s3.{settings.AWS_REGION}.amazonaws.com/")[-1]
            
            self.s3_client.delete_object(
                Bucket=self.bucket_name,
                Key=key
            )
            return True
            
        except Exception as e:
            print(f"Failed to delete image from S3: {e}")
            return False