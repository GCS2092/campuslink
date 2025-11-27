"""
Custom permissions for User app.
"""
from rest_framework import permissions


class IsActiveAndVerified(permissions.BasePermission):
    """
    Permission to only allow active and verified users.
    Les utilisateurs peuvent accéder à la plateforme mais ne peuvent rien faire
    tant que leur compte n'est pas activé ET vérifié.
    """
    message = 'Votre compte doit être activé et vérifié pour effectuer cette action.'
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return request.user.is_active and request.user.is_verified


class IsActiveAndVerifiedOrReadOnly(permissions.BasePermission):
    """
    Permission to allow read-only for authenticated users, but write only for active and verified users.
    """
    message = 'Votre compte doit être activé et vérifié pour effectuer cette action.'
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        if request.method in permissions.SAFE_METHODS:
            return True  # Lecture autorisée pour tous les utilisateurs authentifiés
        return request.user.is_active and request.user.is_verified


class IsVerified(permissions.BasePermission):
    """
    Permission to only allow verified users (legacy, use IsActiveAndVerified instead).
    """
    message = 'You must be verified to perform this action.'
    
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.is_verified


class IsVerifiedOrReadOnly(permissions.BasePermission):
    """
    Permission to allow read-only for all, but write only for verified users (legacy).
    """
    message = 'You must be verified to perform this action.'
    
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user and request.user.is_authenticated and request.user.is_verified


class IsAdminOrClassLeader(permissions.BasePermission):
    """
    Permission to allow admin or class leader.
    """
    message = 'Vous devez être administrateur ou responsable de classe pour effectuer cette action.'
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return (request.user.is_staff or 
                request.user.role == 'admin' or 
                request.user.role == 'class_leader')

