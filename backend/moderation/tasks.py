"""
Celery tasks for Moderation app.
"""
from celery import shared_task
from .models import Report
from notifications.tasks import create_notification


FORBIDDEN_WORDS = ['spam', 'scam', 'fraud']  # Add more words as needed


@shared_task
def moderate_content(content_type, content_id, reason):
    """Automatic content moderation."""
    # Check for forbidden words (simplified - can be enhanced with ML)
    # This is a placeholder - implement actual content checking
    
    # Notify admins
    create_notification.delay(
        recipient_id=None,  # Would need to get admin users
        notification_type='system',
        title='Nouveau signalement',
        message=f'Signalement reçu: {content_type} #{content_id}',
        related_object_type=content_type,
        related_object_id=content_id
    )
    
    return f"Moderation triggered for {content_type} #{content_id}"

