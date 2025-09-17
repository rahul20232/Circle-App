import smtplib
import secrets
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta, timezone
from ..core.config import settings

class EmailService:
    @staticmethod
    def generate_verification_token():
        return secrets.token_urlsafe(32)
    
    @staticmethod
    def _send_email(to_email: str, subject: str, html_content: str = None, text_content: str = None):
        """Internal method to send emails"""
        try:
            # Email configuration
            smtp_server = settings.SMTP_SERVER
            smtp_port = settings.SMTP_PORT
            sender_email = settings.SENDER_EMAIL
            sender_password = settings.SENDER_PASSWORD
            
            # Create message
            msg = MIMEMultipart('alternative')
            msg['From'] = sender_email
            msg['To'] = to_email
            msg['Subject'] = subject
            
            # Add text content
            if text_content:
                msg.attach(MIMEText(text_content, 'plain'))
            
            # Add HTML content
            if html_content:
                msg.attach(MIMEText(html_content, 'html'))
            
            # Send email
            server = smtplib.SMTP(smtp_server, smtp_port)
            server.starttls()
            server.login(sender_email, sender_password)
            server.send_message(msg)
            server.quit()
            
            return True
        except Exception as e:
            print(f"Email sending failed: {e}")
            raise e
    
    @staticmethod
    def send_verification_email(email: str, display_name: str, token: str):
        try:
            # Email body
            verification_link = f"https://5923997ed36c.ngrok-free.app/verify-email?token={token}"
            
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
        # make both datetimes aware in UTC
        now = datetime.now(timezone.utc)
        return now - sent_at > timedelta(hours=24)
    
    @staticmethod
    def send_password_reset_email(email: str, display_name: str, reset_token: str):
        """Send password reset email"""
        try:
            reset_url = f"timeleftclone://reset-password?token={reset_token}"
            
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