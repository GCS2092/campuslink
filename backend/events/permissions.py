"""
Custom permissions for Events app.
"""
from rest_framework import permissions
from users.permissions import IsActiveAndVerified, IsActiveAndVerifiedOrReadOnly


class IsVerifiedOrReadOnly(permissions.BasePermission):
    """
    Permission to allow read-only for all, but write only for active and verified users.
    """
    message = 'Votre compte doit être activé et vérifié pour créer ou modifier des événements.'
    
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return (request.user and 
                request.user.is_authenticated and 
                request.user.is_active and 
                request.user.is_verified)

