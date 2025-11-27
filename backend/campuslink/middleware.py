"""
Custom middleware for CampusLink.
"""
from moderation.models import AuditLog


class AuditLogMiddleware:
    """
    Middleware to log all user actions for audit purposes.
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        
        # Log authenticated user actions
        if request.user.is_authenticated:
            try:
                AuditLog.objects.create(
                    user=request.user,
                    action_type=request.method,
                    resource_type=request.path,
                    ip_address=self.get_client_ip(request),
                    user_agent=request.META.get('HTTP_USER_AGENT', ''),
                )
            except Exception:
                # Don't break the request if logging fails
                pass
        
        return response

    def get_client_ip(self, request):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip

