"""
JWT Authentication middleware for WebSocket connections.
"""
from urllib.parse import parse_qs
from channels.middleware import BaseMiddleware
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.tokens import UntypedToken
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from django.conf import settings
import jwt

User = get_user_model()


@database_sync_to_async
def get_user_from_token(token_string):
    """Get user from JWT token."""
    try:
        # Decode token
        UntypedToken(token_string)
        decoded_data = jwt.decode(token_string, settings.SECRET_KEY, algorithms=["HS256"])
        user_id = decoded_data.get('user_id')
        if user_id:
            try:
                return User.objects.get(id=user_id)
            except User.DoesNotExist:
                return AnonymousUser()
        return AnonymousUser()
    except (InvalidToken, TokenError, jwt.DecodeError, jwt.InvalidTokenError):
        return AnonymousUser()


class JWTAuthMiddleware(BaseMiddleware):
    """
    Custom middleware to authenticate WebSocket connections using JWT tokens.
    """
    
    async def __call__(self, scope, receive, send):
        # Get token from query string or headers
        token = None
        
        # Try to get token from query string
        query_string = scope.get('query_string', b'').decode()
        if query_string:
            query_params = parse_qs(query_string)
            token = query_params.get('token', [None])[0]
        
        # If no token in query string, try to get from headers (subprotocol)
        if not token:
            headers = dict(scope.get('headers', []))
            # Check for Authorization header
            auth_header = headers.get(b'authorization', b'').decode()
            if auth_header.startswith('Bearer '):
                token = auth_header.split(' ')[1]
        
        # Authenticate user
        if token:
            scope['user'] = await get_user_from_token(token)
        else:
            scope['user'] = AnonymousUser()
        
        return await super().__call__(scope, receive, send)

