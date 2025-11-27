"""
Utility functions for creating notifications.
This module provides both synchronous and asynchronous (Celery) notification creation.
"""
from django.utils import timezone
from .models import Notification
from users.models import User

# Try to import Celery for async notifications
try:
    from celery import shared_task
    CELERY_AVAILABLE = True
except ImportError:
    CELERY_AVAILABLE = False
    shared_task = None


def create_notification(
    recipient,
    notification_type,
    title,
    message,
    related_object_type=None,
    related_object_id=None,
    use_async=False
):
    """
    Create a notification for a user.
    
    Args:
        recipient: User instance or user ID
        notification_type: Type of notification (from TYPE_CHOICES)
        title: Notification title
        message: Notification message
        related_object_type: Type of related object (e.g., 'group', 'event', 'user')
        related_object_id: ID of related object (UUID)
        use_async: If True and Celery is available, use async task
    
    Returns:
        Notification instance or None (or task ID if async)
    """
    # If async is requested and Celery is available, use the task
    if use_async and CELERY_AVAILABLE:
        from .tasks import create_notification as create_notification_task
        recipient_id = recipient.id if isinstance(recipient, User) else recipient
        return create_notification_task.delay(
            recipient_id=str(recipient_id),
            notification_type=notification_type,
            title=title,
            message=message,
            related_object_type=related_object_type,
            related_object_id=str(related_object_id) if related_object_id else None
        )
    
    # Synchronous creation
    try:
        # Handle recipient as User instance or ID
        if isinstance(recipient, str):
            recipient = User.objects.get(id=recipient)
        elif not isinstance(recipient, User):
            recipient = User.objects.get(id=recipient)
        
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
        return notification
    except User.DoesNotExist:
        return None
    except Exception as e:
        print(f"Error creating notification: {e}")
        return None


def create_bulk_notifications(
    recipients,
    notification_type,
    title,
    message,
    related_object_type=None,
    related_object_id=None,
    use_async=False
):
    """
    Create notifications for multiple users.
    
    Args:
        recipients: List of User instances or user IDs
        notification_type: Type of notification
        title: Notification title
        message: Notification message
        related_object_type: Type of related object
        related_object_id: ID of related object
        use_async: If True and Celery is available, use async tasks
    
    Returns:
        Number of notifications created (or list of task IDs if async)
    """
    if use_async and CELERY_AVAILABLE:
        # Use async for bulk operations
        task_ids = []
        for recipient in recipients:
            task = create_notification(
                recipient=recipient,
                notification_type=notification_type,
                title=title,
                message=message,
                related_object_type=related_object_type,
                related_object_id=related_object_id,
                use_async=True
            )
            if task:
                task_ids.append(task)
        return task_ids
    
    # Synchronous bulk creation
    notifications = []
    for recipient in recipients:
        notification = create_notification(
            recipient=recipient,
            notification_type=notification_type,
            title=title,
            message=message,
            related_object_type=related_object_type,
            related_object_id=related_object_id,
            use_async=False
        )
        if notification:
            notifications.append(notification)
    
    return len(notifications)


def get_unread_count(user):
    """Get count of unread notifications for a user."""
    if isinstance(user, str):
        user = User.objects.get(id=user)
    elif not isinstance(user, User):
        user = User.objects.get(id=user)
    
    return Notification.objects.filter(recipient=user, is_read=False).count()

