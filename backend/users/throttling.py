"""
Custom throttling for User app.
"""
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
    """Throttle login to 5 per 15 minutes per IP."""
    rate = '5/s'  # Use a valid rate format, we'll override duration
    
    def __init__(self):
        super().__init__()
        # Override duration to 15 minutes (900 seconds)
        self.duration = 900
    
    def get_cache_key(self, request, view):
        ident = self.get_ident(request)
        return f'throttle_login_{ident}'

