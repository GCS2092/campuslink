"""
Admin views for user management.
"""
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import User
from .serializers import UserSerializer
from users.permissions import IsAdminOrClassLeader
from moderation.utils import create_audit_log
from notifications.utils import create_notification
import logging

logger = logging.getLogger(__name__)


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def verify_user(request, user_id):
    """Manually verify a user account."""
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({'error': 'Utilisateur introuvable.'}, status=status.HTTP_404_NOT_FOUND)
    
    # Check if already verified
    if user.is_verified:
        return Response({'error': 'L\'utilisateur est déjà vérifié.'}, status=status.HTTP_400_BAD_REQUEST)
    
    user.is_verified = True
    user.verification_status = 'verified'
    user.is_active = True  # Activate when verifying
    user.save(update_fields=['is_verified', 'verification_status', 'is_active'])
    
    # Create notification
    create_notification(
        recipient=user,
        notification_type='account_verified',
        title='Compte vérifié',
        message=f'Votre compte a été vérifié par {request.user.username}. Vous pouvez maintenant utiliser toutes les fonctionnalités de CampusLink.',
        related_object_type='user',
        related_object_id=user.id
    )
    
    # Create audit log
    create_audit_log(
        user=request.user,
        action_type='user_verified',
        resource_type='user',
        resource_id=user.id,
        details={
            'user_id': str(user.id),
            'username': user.username,
            'email': user.email
        },
        request=request
    )
    
    return Response({
        'message': 'Utilisateur vérifié avec succès.',
        'user': UserSerializer(user).data
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def reject_user(request, user_id):
    """Reject a user account verification."""
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({'error': 'Utilisateur introuvable.'}, status=status.HTTP_404_NOT_FOUND)
    
    reason = request.data.get('reason', '')
    message = request.data.get('message', '')
    
    user.is_verified = False
    user.verification_status = 'rejected'
    user.is_active = False
    user.save(update_fields=['is_verified', 'verification_status', 'is_active'])
    
    # Create notification
    notification_message = message or f'Votre demande de vérification a été rejetée. Raison: {reason}' if reason else 'Votre demande de vérification a été rejetée.'
    create_notification(
        recipient=user,
        notification_type='account_rejected',
        title='Compte rejeté',
        message=notification_message,
        related_object_type='user',
        related_object_id=user.id
    )
    
    # Create audit log
    create_audit_log(
        user=request.user,
        action_type='user_rejected',
        resource_type='user',
        resource_id=user.id,
        details={
            'user_id': str(user.id),
            'username': user.username,
            'email': user.email,
            'reason': reason,
            'message': message
        },
        request=request
    )
    
    return Response({
        'message': 'Utilisateur rejeté avec succès.',
        'user': UserSerializer(user).data
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def ban_user(request, user_id):
    """Ban a user (temporary or permanent)."""
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({'error': 'Utilisateur introuvable.'}, status=status.HTTP_404_NOT_FOUND)
    
    # Cannot ban admins
    if user.role == 'admin' or user.is_staff:
        return Response({'error': 'Impossible de bannir un administrateur.'}, status=status.HTTP_400_BAD_REQUEST)
    
    ban_type = request.data.get('ban_type', 'permanent')  # 'permanent' or 'temporary'
    reason = request.data.get('reason', '')
    banned_until = request.data.get('banned_until')  # For temporary bans
    
    user.is_banned = True
    user.banned_at = timezone.now()
    user.ban_reason = reason
    user.banned_by = request.user
    
    if ban_type == 'temporary' and banned_until:
        from django.utils.dateparse import parse_datetime
        user.banned_until = parse_datetime(banned_until) if isinstance(banned_until, str) else banned_until
    else:
        user.banned_until = None
    
    user.is_active = False  # Deactivate when banned
    user.save(update_fields=['is_banned', 'banned_at', 'banned_until', 'ban_reason', 'banned_by', 'is_active'])
    
    # Create notification
    ban_message = f'Votre compte a été banni{" temporairement" if ban_type == "temporary" else ""} par un administrateur.'
    if reason:
        ban_message += f' Raison: {reason}'
    if ban_type == 'temporary' and user.banned_until:
        ban_message += f' Jusqu\'au: {user.banned_until.strftime("%d/%m/%Y %H:%M")}'
    
    create_notification(
        recipient=user,
        notification_type='account_banned',
        title='Compte banni',
        message=ban_message,
        related_object_type='user',
        related_object_id=user.id
    )
    
    # Create audit log
    create_audit_log(
        user=request.user,
        action_type='user_banned',
        resource_type='user',
        resource_id=user.id,
        details={
            'user_id': str(user.id),
            'username': user.username,
            'email': user.email,
            'ban_type': ban_type,
            'reason': reason,
            'banned_until': str(user.banned_until) if user.banned_until else None
        },
        request=request
    )
    
    return Response({
        'message': f'Utilisateur banni{" temporairement" if ban_type == "temporary" else ""} avec succès.',
        'user': UserSerializer(user).data
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def unban_user(request, user_id):
    """Unban a user."""
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({'error': 'Utilisateur introuvable.'}, status=status.HTTP_404_NOT_FOUND)
    
    if not user.is_banned:
        return Response({'error': 'L\'utilisateur n\'est pas banni.'}, status=status.HTTP_400_BAD_REQUEST)
    
    user.is_banned = False
    user.banned_at = None
    user.banned_until = None
    user.ban_reason = ''
    user.banned_by = None
    user.is_active = True  # Reactivate when unbanned
    user.save(update_fields=['is_banned', 'banned_at', 'banned_until', 'ban_reason', 'banned_by', 'is_active'])
    
    # Create notification
    create_notification(
        recipient=user,
        notification_type='account_unbanned',
        title='Compte débanni',
        message='Votre compte a été débanni. Vous pouvez à nouveau utiliser CampusLink.',
        related_object_type='user',
        related_object_id=user.id
    )
    
    # Create audit log
    create_audit_log(
        user=request.user,
        action_type='user_unbanned',
        resource_type='user',
        resource_id=user.id,
        details={
            'user_id': str(user.id),
            'username': user.username,
            'email': user.email
        },
        request=request
    )
    
    return Response({
        'message': 'Utilisateur débanni avec succès.',
        'user': UserSerializer(user).data
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def get_pending_verifications(request):
    """Get list of users pending verification."""
    queryset = User.objects.filter(
        verification_status='pending',
        role='student'
    ).select_related('profile').order_by('-date_joined')
    
    # For class leaders, filter by their university
    if request.user.role == 'class_leader' and hasattr(request.user, 'profile') and request.user.profile:
        user_university = request.user.profile.university
        if user_university:
            queryset = queryset.filter(profile__university=user_university)
    
    serializer = UserSerializer(queryset, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def get_banned_users(request):
    """Get list of banned users."""
    queryset = User.objects.filter(is_banned=True).select_related('profile', 'banned_by').order_by('-banned_at')
    
    # For class leaders, filter by their university
    if request.user.role == 'class_leader' and hasattr(request.user, 'profile') and request.user.profile:
        user_university = request.user.profile.university
        if user_university:
            queryset = queryset.filter(profile__university=user_university)
    
    serializer = UserSerializer(queryset, many=True)
    return Response(serializer.data)

