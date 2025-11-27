"""
Permissions for feed app.
"""
from rest_framework import permissions
from users.permissions import IsAdminOrClassLeader


class CanManageFeed(permissions.BasePermission):
    """
    Permission to allow only admin or class leaders to manage feed items.
    """
    message = 'Seuls les administrateurs et responsables de classe peuvent gérer les actualités.'
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return (request.user.is_staff or 
                request.user.role == 'admin' or 
                request.user.role == 'class_leader')


class CanViewFeed(permissions.BasePermission):
    """
    Permission to view feed items based on visibility settings.
    """
    def has_object_permission(self, request, view, obj):
        # Public items are visible to all authenticated users
        if obj.visibility == 'public':
            return True
        
        # Private items are visible only to users from the same university
        if obj.visibility == 'private':
            if not hasattr(request.user, 'profile'):
                return False
            user_university = request.user.profile.university if request.user.profile else None
            return user_university and user_university == obj.university
        
        return False

