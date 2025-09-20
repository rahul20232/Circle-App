import secrets
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from datetime import datetime, timedelta, timezone
from ..core.config import settings

class EmailService:
    @staticmethod
    def generate_verification_token():
        return secrets.token_urlsafe(32)
    
    @staticmethod
    def _send_email(to_email: str, subject: str, html_content: str = None, text_content: str = None):
        """Internal method to send emails using SendGrid"""
        try:
            message = Mail(
                from_email=settings.SENDER_EMAIL,  # Use your verified sender email
                to_emails=to_email,
                subject=subject,
                html_content=html_content,
                plain_text_content=text_content
            )
            
            sg = SendGridAPIClient(api_key=settings.SENDGRID_API_KEY)
            response = sg.send(message)
            print(f"Email sent successfully. Status code: {response.status_code}")
            return True
            
        except Exception as e:
            print(f"SendGrid email sending failed: {e}")
            raise e
    
    @staticmethod
    def send_verification_email(email: str, display_name: str, token: str):
        try:
            verification_link = f"https://circle-app-production-0a7b.up.railway.app/verify-email?token={token}"
            
            text_content = f"""
            Hi {display_name},
            
            Thanks for signing up! Please click the link below to verify your email address:
            
            {verification_link}
            
            This link will expire in 24 hours.
            
            If you didn't create an account, you can safely ignore this email.
            
            Best regards,
            TimeLeft Clone Team
            """
            
            html_content = f"""
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #f8f9fa; padding: 40px 20px; text-align: center;">
                    <h1 style="color: #333; margin-bottom: 20px;">Verify Your Email</h1>
                    <p style="color: #666; font-size: 16px; margin-bottom: 30px;">
                        Hi {display_name},<br><br>
                        Thanks for signing up! Please click the button below to verify your email address:
                    </p>
                    <a href="{verification_link}" 
                    style="background-color: #28a745; color: white; padding: 12px 30px; 
                            text-decoration: none; border-radius: 5px; font-weight: bold; 
                            display: inline-block; margin: 20px 0;">
                        Verify Email
                    </a>
                    <p style="color: #999; font-size: 14px; margin-top: 30px;">
                        This link will expire in 24 hours.<br>
                        If you didn't create an account, you can safely ignore this email.
                    </p>
                </div>
            </body>
            </html>
            """
            
            EmailService._send_email(
                to_email=email,
                subject="Verify your email - TimeLeft Clone",
                html_content=html_content,
                text_content=text_content
            )
            
            return True
        except Exception as e:
            print(f"Email sending failed: {e}")
            return False
    
    @staticmethod
    def is_verification_token_expired(sent_at: datetime):
        if not sent_at:
            return True
        now = datetime.now(timezone.utc)
        return now - sent_at > timedelta(hours=24)
    
    @staticmethod
    def send_password_reset_email(email: str, display_name: str, reset_token: str):
        """Send password reset email"""
        try:
            reset_url = f"https://circle-app-production-0a7b.up.railway.app/reset-password?token={reset_token}"
            
            html_content = f"""
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #f8f9fa; padding: 40px 20px; text-align: center;">
                    <h1 style="color: #333; margin-bottom: 20px;">Password Reset Request</h1>
                    <p style="color: #666; font-size: 16px; margin-bottom: 30px;">
                        Hi {display_name},<br><br>
                        You requested a password reset for your account. Click the button below to reset your password:
                    </p>
                    <a href="{reset_url}" 
                    style="background-color: #28a745; color: white; padding: 12px 30px; 
                            text-decoration: none; border-radius: 5px; font-weight: bold; 
                            display: inline-block; margin: 20px 0;">
                        Reset Password
                    </a>
                    <p style="color: #999; font-size: 14px; margin-top: 30px;">
                        If you didn't request this reset, please ignore this email.<br>
                        This link will expire in 24 hours.
                    </p>
                    <p style="color: #999; font-size: 12px;">
                        If the button doesn't work, copy and paste this link:<br>
                        <a href="{reset_url}">{reset_url}</a>
                    </p>
                </div>
            </body>
            </html>
            """
            
            text_content = f"""
            Password Reset Request
            
            Hi {display_name},
            
            You requested a password reset for your account. 
            
            Click this link to reset your password: {reset_url}
            
            If you didn't request this reset, please ignore this email.
            This link will expire in 24 hours.
            """
            
            EmailService._send_email(
                to_email=email,
                subject="Password Reset Request - TimeLeft Clone",
                html_content=html_content,
                text_content=text_content
            )
            
            print(f"Password reset email sent to {email}")
            
        except Exception as e:
            print(f"Failed to send password reset email: {e}")
            raise e