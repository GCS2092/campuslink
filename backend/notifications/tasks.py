"""
Celery tasks for Notifications app.
"""
import random
import jwt
from datetime import timedelta
from celery import shared_task
from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone
from twilio.rest import Client
from core.cache import set_otp


@shared_task
def send_otp_sms(phone_number):
    """Generate and send OTP via SMS."""
    otp_code = str(random.randint(100000, 999999))
    
    # Store in Redis (TTL 10 minutes)
    set_otp(phone_number, otp_code, ttl=600)
    
    # Send SMS via Twilio
    if settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN:
        try:
            client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
            message = client.messages.create(
                body=f'Votre code de vérification CampusLink : {otp_code}. Valide 10 minutes.',
                from_=settings.TWILIO_PHONE_NUMBER,
                to=phone_number
            )
            return message.sid
        except Exception as e:
            print(f"Error sending SMS: {e}")
            return None
    
    # In development, just print the OTP
    print(f"OTP for {phone_number}: {otp_code}")
    return otp_code


@shared_task
def send_verification_email(user_id):
    """Send email verification link."""
    from users.models import User
    
    try:
        user = User.objects.get(id=user_id)
        
        # Generate JWT token
        token = jwt.encode(
            {
                'user_id': str(user.id),
                'exp': timezone.now() + timedelta(days=1)
            },
            settings.SECRET_KEY,
            algorithm='HS256'
        )
        
        verification_url = f"{settings.FRONTEND_URL}/verify-email/{token}"
        
        send_mail(
            subject='Vérifiez votre email - CampusLink',
            message=f'Cliquez sur ce lien pour vérifier votre email: {verification_url}',
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=False,
        )
        
        return f"Verification email sent to {user.email}"
    except User.DoesNotExist:
        return f"User {user_id} not found"
    except Exception as e:
        print(f"Error sending verification email: {e}")
        return None


@shared_task
def create_notification(recipient_id, notification_type, title, message, related_object_type=None, related_object_id=None):
    """Create a notification for a user (Celery task)."""
    from .models import Notification
    from users.models import User
    
    try:
        recipient = User.objects.get(id=recipient_id)
        
        # Only send notifications to active users
        if not recipient.is_active:
            return None
        
        notification = Notification.objects.create(
            recipient=recipient,
            notification_type=notification_type,
            title=title,
            message=message,
            related_object_type=related_object_type or '',
            related_object_id=related_object_id
        )
        return f"Notification created for {recipient.username}"
    except User.DoesNotExist:
        return None
    except Exception as e:
        print(f"Error creating notification: {e}")
        return None

