"""
Custom authentication for allowing inactive users to access their profile.
"""
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from django.contrib.auth import get_user_model

User = get_user_model()


class CustomJWTAuthentication(JWTAuthentication):
    """
    Custom JWT authentication that allows inactive users to authenticate.
    This is needed for users waiting for admin approval.
    """
    
    def get_user(self, validated_token):
        """
        Override to not check is_active.
        """
        try:
            user_id = validated_token['user_id']
        except KeyError:
            raise InvalidToken('Token contained no recognizable user identification')

        try:
            user = User.objects.get(**{'id': user_id})
        except User.DoesNotExist:
            raise InvalidToken('User not found')

        # Don't check is_active here - allow inactive users to authenticate
        # The permissions will handle access control
        return user

