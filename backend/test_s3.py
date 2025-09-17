# Create a test file: test_s3.py
import boto3
from core.config import settings

def test_s3_connection():
    try:
        s3_client = boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_REGION
        )
        
        # Test bucket access
        response = s3_client.head_bucket(Bucket=settings.S3_BUCKET_NAME)
        print(f"✅ S3 bucket '{settings.S3_BUCKET_NAME}' is accessible")
        return True
        
    except Exception as e:
        print(f"❌ S3 connection failed: {e}")
        return False

if __name__ == "__main__":
    test_s3_connection()