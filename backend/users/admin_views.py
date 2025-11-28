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
from users.permissions import IsAdminOrClassLeader, IsAdmin
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
    
    # Vérifier que l'admin d'université ne peut vérifier que ses étudiants
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(user, 'profile') or not user.profile.university:
            return Response(
                {'error': 'Cet utilisateur n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if user.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez vérifier que les utilisateurs de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
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
    
    # Vérifier que l'admin d'université ne peut rejeter que ses étudiants
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(user, 'profile') or not user.profile.university:
            return Response(
                {'error': 'Cet utilisateur n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if user.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez rejeter que les utilisateurs de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
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
    
    # Vérifier que l'admin d'université ne peut bannir que ses étudiants
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(user, 'profile') or not user.profile.university:
            return Response(
                {'error': 'Cet utilisateur n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if user.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez bannir que les utilisateurs de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
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
    
    # Vérifier que l'admin d'université ne peut débannir que ses étudiants
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(user, 'profile') or not user.profile.university:
            return Response(
                {'error': 'Cet utilisateur n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if user.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez débannir que les utilisateurs de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
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
@permission_classes([IsAuthenticated])
def get_pending_verifications(request):
    """Get list of users pending verification."""
    # Check permissions: admin or university_admin
    if not (request.user.is_staff or request.user.role == 'admin' or 
            (request.user.role == 'university_admin' and request.user.managed_university)):
        return Response(
            {'error': 'Permission denied. Admin or university admin access required.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    queryset = User.objects.filter(
        verification_status='pending',
        role='student'
    ).select_related('profile').order_by('-date_joined')
    
    # For university admins, filter by their managed university
    if request.user.role == 'university_admin' and request.user.managed_university:
        queryset = queryset.filter(profile__university=request.user.managed_university)
    # For class leaders, filter by their university AND class (field_of_study + academic_year)
    elif request.user.role == 'class_leader' and hasattr(request.user, 'profile') and request.user.profile:
        user_profile = request.user.profile
        if user_profile.university:
            queryset = queryset.filter(profile__university=user_profile.university)
        if user_profile.field_of_study:
            queryset = queryset.filter(profile__field_of_study=user_profile.field_of_study)
        if user_profile.academic_year:
            queryset = queryset.filter(profile__academic_year=user_profile.academic_year)
    
    # Filtre par classe si fourni (pour university_admin)
    academic_year = request.query_params.get('academic_year')
    if academic_year:
        queryset = queryset.filter(profile__academic_year=academic_year)
    
    serializer = UserSerializer(queryset, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_banned_users(request):
    """Get list of banned users."""
    # Check permissions: admin or university_admin
    if not (request.user.is_staff or request.user.role == 'admin' or 
            (request.user.role == 'university_admin' and request.user.managed_university)):
        return Response(
            {'error': 'Permission denied. Admin or university admin access required.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    queryset = User.objects.filter(is_banned=True).select_related('profile', 'banned_by').order_by('-banned_at')
    
    # For university admins, filter by their managed university
    if request.user.role == 'university_admin' and request.user.managed_university:
        queryset = queryset.filter(profile__university=request.user.managed_university)
    # For class leaders, filter by their university AND class (field_of_study + academic_year)
    elif request.user.role == 'class_leader' and hasattr(request.user, 'profile') and request.user.profile:
        user_profile = request.user.profile
        if user_profile.university:
            queryset = queryset.filter(profile__university=user_profile.university)
        if user_profile.field_of_study:
            queryset = queryset.filter(profile__field_of_study=user_profile.field_of_study)
        if user_profile.academic_year:
            queryset = queryset.filter(profile__academic_year=user_profile.academic_year)
    
    # Filtre par classe si fourni (pour university_admin)
    academic_year = request.query_params.get('academic_year')
    if academic_year:
        queryset = queryset.filter(profile__academic_year=academic_year)
    
    serializer = UserSerializer(queryset, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_student(request):
    """Create a new student (for university admin)."""
    from .serializers import UserRegistrationSerializer
    from .models import AcademicYear
    from .external_student_verification import get_external_verifier
    
    # Check permissions: only university_admin can create students
    if not (request.user.role == 'university_admin' and request.user.managed_university):
        return Response(
            {'error': 'Permission denied. Only university admins can create students.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Get the university admin's managed university
    university = request.user.managed_university
    
    # Prepare data for registration serializer
    registration_data = request.data.copy()
    
    # Force role to 'student'
    registration_data['role'] = 'student'
    
    # If academic_year_id is provided, validate it belongs to the university
    academic_year_id = registration_data.get('academic_year_id')
    academic_year_obj = None
    if academic_year_id:
        try:
            academic_year_obj = AcademicYear.objects.get(id=academic_year_id, university=university)
            # Convert to academic_year name for the serializer (use year field)
            registration_data['academic_year'] = academic_year_obj.year
        except AcademicYear.DoesNotExist:
            return Response(
                {'error': 'L\'année académique spécifiée n\'appartient pas à votre université.'},
                status=status.HTTP_400_BAD_REQUEST
            )
    else:
        # If no academic_year_id, try to get it from academic_year string
        academic_year_name = registration_data.get('academic_year')
        if academic_year_name:
            # Try to find matching AcademicYear by year name
            academic_year_obj = AcademicYear.objects.filter(
                university=university,
                year__icontains=academic_year_name
            ).first()
            if not academic_year_obj:
                # If not found, try to create a simple mapping (Licence 1, Licence 2, etc.)
                # This is a fallback - ideally academic_year_id should be provided
                pass
    
    # Validate email belongs to university domain
    email = registration_data.get('email', '')
    if email and '@' in email:
        domain = email.split('@')[1]
        if domain not in university.email_domains:
            return Response(
                {'error': f'L\'email doit appartenir au domaine de votre université: {", ".join(university.email_domains)}'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    # Vérification avec la base de données externe (si activée)
    external_verifier = get_external_verifier()
    if external_verifier.is_enabled():
        verification_result = external_verifier.verify_student(
            email=email,
            student_id=registration_data.get('student_id'),
            phone_number=registration_data.get('phone_number')
        )
        
        if not verification_result['exists']:
            return Response(
                {
                    'error': 'Étudiant non trouvé dans la base de données externe.',
                    'verification_details': {
                        'exists': False,
                        'differences': verification_result.get('differences', []),
                        'errors': verification_result.get('errors', [])
                    }
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if not verification_result['verified']:
            return Response(
                {
                    'error': 'Les informations fournies ne correspondent pas à celles de la base de données externe.',
                    'verification_details': {
                        'exists': True,
                        'verified': False,
                        'differences': verification_result.get('differences', []),
                        'external_data': verification_result.get('external_data', {})
                    }
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Si la vérification est réussie, on peut optionnellement synchroniser les données
        # depuis la base externe pour s'assurer de la cohérence
        if verification_result.get('external_data'):
            external_data = verification_result['external_data']
            # Mettre à jour les données avec celles de la base externe si nécessaire
            # (par exemple, pour corriger les noms, prénoms, etc.)
            if external_data.get('first_name') and not registration_data.get('first_name'):
                registration_data['first_name'] = external_data['first_name']
            if external_data.get('last_name') and not registration_data.get('last_name'):
                registration_data['last_name'] = external_data['last_name']
            if external_data.get('student_id') and not registration_data.get('student_id'):
                registration_data['student_id'] = external_data['student_id']
    
    # Use registration serializer to create user
    serializer = UserRegistrationSerializer(data=registration_data)
    if serializer.is_valid():
        user = serializer.save()
        
        # Ensure university is set correctly
        if hasattr(user, 'profile') and user.profile:
            user.profile.university = university
            if academic_year_obj:
                user.profile.academic_year_obj = academic_year_obj
            user.profile.save(update_fields=['university', 'academic_year_obj'])
        
        # Auto-verify and activate student created by university admin
        user.is_verified = True
        user.verification_status = 'verified'
        user.is_active = True
        user.phone_verified = True  # Auto-verify phone for admin-created accounts
        if hasattr(user, 'profile') and user.profile:
            user.profile.email_verified = True
            user.profile.save(update_fields=['email_verified'])
        user.save(update_fields=['is_verified', 'verification_status', 'is_active', 'phone_verified'])
        
        # Create notification
        create_notification(
            recipient=user,
            notification_type='account_created',
            title='Compte créé',
            message=f'Votre compte CampusLink a été créé par l\'administrateur de {university.name}. Vous pouvez maintenant vous connecter.',
            related_object_type='user',
            related_object_id=user.id
        )
        
        # Create audit log
        create_audit_log(
            user=request.user,
            action_type='student_created',
            resource_type='user',
            resource_id=user.id,
            details={
                'user_id': str(user.id),
                'username': user.username,
                'email': user.email,
                'university': university.name
            },
            request=request
        )
        
        return Response({
            'message': 'Étudiant créé avec succès.',
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

