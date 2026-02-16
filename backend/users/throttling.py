"""
Custom throttling for User app.
"""
from django.conf import settings
from rest_framework.throttling import SimpleRateThrottle


class RegisterThrottle(SimpleRateThrottle):
    """Throttle registration to 3 per hour per IP."""
    rate = '3/hour'
    
    def get_cache_key(self, request, view):
        if request.user.is_authenticated:
            return None
        ident = self.get_ident(request)
        return f'throttle_register_{ident}'


class OTPThrottle(SimpleRateThrottle):
    """Throttle OTP requests to 5 per hour per phone."""
    rate = '5/hour'
    
    def get_cache_key(self, request, view):
        phone = request.data.get('phone_number')
        if phone:
            return f'throttle_otp_{phone}'
        return None


class LoginThrottle(SimpleRateThrottle):
    """Throttle login: 5 per 15 min per IP (production), 30 per 15 min (DEBUG)."""
    rate = '5/s'  # Fallback; duration overridden in __init__
    
    def __init__(self):
        super().__init__()
        # En dev : plus permissif pour éviter le blocage après quelques essais
        if getattr(settings, 'DEBUG', False):
            self.num_requests = 30
            self.duration = 900  # 15 min
        else:
            self.num_requests = 5
            self.duration = 900  # 15 min
    
    def get_cache_key(self, request, view):
        ident = self.get_ident(request)
        return f'throttle_login_{ident}'

