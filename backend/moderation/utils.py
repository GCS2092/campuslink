"""
Utility functions for moderation.
"""
from django.utils import timezone
from .models import AuditLog
import logging

logger = logging.getLogger(__name__)


def create_audit_log(
    user,
    action_type,
    resource_type=None,
    resource_id=None,
    ip_address=None,
    user_agent=None,
    details=None,
    request=None
):
    """
    Create an audit log entry.
    
    Args:
        user: User performing the action
        action_type: Type of action (e.g., 'user_activated', 'post_deleted')
        resource_type: Type of resource (e.g., 'user', 'post', 'event')
        resource_id: ID of the resource
        ip_address: IP address of the user
        user_agent: User agent string
        details: Additional details as dict
        request: Request object (optional, will extract IP and user agent)
    """
    try:
        # Extract IP and user agent from request if provided
        if request:
            ip_address = ip_address or get_client_ip(request)
            user_agent = user_agent or request.META.get('HTTP_USER_AGENT', '')
        
        audit_log = AuditLog.objects.create(
            user=user,
            action_type=action_type,
            resource_type=resource_type or '',
            resource_id=resource_id,
            ip_address=ip_address,
            user_agent=user_agent or '',
            details=details or {}
        )
        
        logger.info(f"Audit log created: {action_type} by {user.username if user else 'Anonymous'}")
        return audit_log
    except Exception as e:
        logger.error(f"Error creating audit log: {str(e)}", exc_info=True)
        return None


def get_client_ip(request):
    """Get client IP address from request."""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip

