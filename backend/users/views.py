"""
Views for User app.
"""
import jwt
import logging
from datetime import timedelta
from django.conf import settings
from django.utils import timezone
from django.db.models import Q
from rest_framework import status, generics, viewsets
from rest_framework.decorators import api_view, permission_classes, throttle_classes, action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from .models import User, Profile, Friendship, Follow
from .serializers import (
    UserRegistrationSerializer, UserSerializer, ProfileSerializer,
    FriendshipSerializer, FollowSerializer, UserBasicSerializer
)
from .permissions import IsVerified, IsActiveAndVerified, IsAdminOrClassLeader
from .throttling import RegisterThrottle, OTPThrottle, LoginThrottle
from .security import check_account_lockout, record_failed_login_attempt, clear_login_attempts
from core.cache import get_otp, set_otp, delete_otp
from notifications.tasks import send_otp_sms, send_verification_email

logger = logging.getLogger('users')


class CustomTokenObtainPairView(TokenObtainPairView):
    """Custom token obtain view with throttling and account lockout."""
    throttle_classes = [LoginThrottle]
    
    def post(self, request, *args, **kwargs):
        """Handle login with account lockout protection."""
        email = request.data.get('email')
        
        # Vérifier le verrouillage de compte
        if email:
            is_locked, remaining_time = check_account_lockout(email)
            if is_locked:
                remaining_minutes = remaining_time // 60
                return Response(
                    {
                        'error': {
                            'status_code': 423,
                            'message': f'Compte verrouillé. Réessayez dans {remaining_minutes} minutes.',
                            'lockout_remaining_seconds': remaining_time,
                            'lockout_remaining_minutes': remaining_minutes,
                        }
                    },
                    status=status.HTTP_423_LOCKED
                )
        
        try:
            response = super().post(request, *args, **kwargs)
            # Succès - effacer les tentatives
            if email:
                clear_login_attempts(email)
                logger.info(f"Successful login for {email}")
            return response
        except Exception as e:
            # Échec - enregistrer la tentative
            if email:
                record_failed_login_attempt(email)
                logger.warning(f"Failed login for {email}: {str(e)}")
            raise


@api_view(['POST'])
@permission_classes([AllowAny])
@throttle_classes([RegisterThrottle])
def register(request):
    """User registration."""
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        # Nouveau compte : désactivé par défaut jusqu'à validation admin/responsable
        user.is_active = False
        user.is_verified = False
        user.verification_status = 'pending'
        user.save()
        
        # Send OTP SMS
        send_otp_sms.delay(user.phone_number)
        
        # Send verification email
        send_verification_email.delay(user.id)
        
        return Response({
            'message': 'Inscription réussie. Votre compte sera activé après validation par un administrateur. Vérifiez votre email et téléphone.',
            'user_id': str(user.id)
        }, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
@throttle_classes([OTPThrottle])
def resend_otp(request):
    """Resend OTP to phone number."""
    phone = request.data.get('phone_number')
    
    if not phone:
        return Response({'error': 'Phone number is required.'}, 
                       status=status.HTTP_400_BAD_REQUEST)
    
    try:
        user = User.objects.get(phone_number=phone)
        # Send OTP SMS
        send_otp_sms.delay(phone)
        return Response({'message': 'Code OTP renvoyé avec succès.'}, 
                       status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'error': 'Utilisateur non trouvé.'}, 
                       status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
@permission_classes([AllowAny])
@throttle_classes([OTPThrottle])
def verify_phone(request):
    """Verify phone number with OTP."""
    phone = request.data.get('phone_number')
    otp_code = request.data.get('otp_code')
    
    if not phone or not otp_code:
        return Response({'error': 'Phone number and OTP code are required.'}, 
                       status=status.HTTP_400_BAD_REQUEST)
    
    stored_otp = get_otp(phone)
    if not stored_otp or stored_otp != otp_code:
        return Response({'error': 'Code OTP invalide ou expiré.'}, 
                       status=status.HTTP_400_BAD_REQUEST)
    
    try:
        user = User.objects.get(phone_number=phone)
        user.phone_verified = True
        
        # Check if email is also verified
        if user.profile.email_verified:
            user.is_verified = True
            user.verification_status = 'verified'
        
        user.save()
        delete_otp(phone)
        
        return Response({'message': 'Téléphone vérifié avec succès.'}, 
                       status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'error': 'Utilisateur non trouvé.'}, 
                       status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
@permission_classes([AllowAny])
def verify_email(request, token):
    """Verify email with token."""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
        user_id = payload['user_id']
        
        user = User.objects.get(id=user_id)
        user.profile.email_verified = True
        user.profile.save()
        
        # Check if phone is also verified
        if user.phone_verified:
            user.is_verified = True
            user.verification_status = 'verified'
            user.save()
        
        return Response({'message': 'Email vérifié avec succès.'}, 
                       status=status.HTTP_200_OK)
    except jwt.ExpiredSignatureError:
        return Response({'error': 'Lien expiré.'}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({'error': 'Token invalide.'}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def verification_status(request):
    """Get current verification status."""
    user = request.user
    return Response({
        'is_verified': user.is_verified,
        'phone_verified': user.phone_verified,
        'email_verified': user.profile.email_verified,
        'verification_status': user.verification_status
    })


@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def profile(request):
    """Get or update user profile."""
    if request.method == 'GET':
        serializer = UserSerializer(request.user)
        return Response(serializer.data)
    
    # Update profile
    profile = request.user.profile
    serializer = ProfileSerializer(profile, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for users."""
    queryset = User.objects.all()  # Start with all users
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = None  # Disable pagination to avoid errors
    
    def get_queryset(self):
        # Admins, superusers, and staff can see all users (including inactive)
        # Regular users can only see active users
        if (self.request.user.is_staff or 
            self.request.user.is_superuser or 
            self.request.user.role == 'admin'):
            queryset = User.objects.all()
        else:
            queryset = User.objects.filter(is_active=True)
        
        queryset = queryset.select_related('profile')
        
        verified_only = self.request.query_params.get('verified_only', 'false').lower() == 'true'
        university = self.request.query_params.get('university')
        search = self.request.query_params.get('search')
        is_active_filter = self.request.query_params.get('is_active')
        
        if verified_only:
            queryset = queryset.filter(is_verified=True)
        
        if is_active_filter is not None:
            is_active_bool = is_active_filter.lower() == 'true'
            queryset = queryset.filter(is_active=is_active_bool)
        
        if university:
            queryset = queryset.filter(profile__university__icontains=university)
        
        if search:
            queryset = queryset.filter(
                Q(username__icontains=search) |
                Q(email__icontains=search) |
                Q(first_name__icontains=search) |
                Q(last_name__icontains=search)
            )
        
        # Exclude current user
        queryset = queryset.exclude(id=self.request.user.id)
        
        return queryset.select_related('profile')
    
    @action(detail=True, methods=['get'], permission_classes=[IsAuthenticated])
    def public_profile(self, request, pk=None):
        """Get public profile of a user (without phone number)."""
        try:
            user = User.objects.select_related('profile').get(id=pk, is_active=True)
        except User.DoesNotExist:
            return Response(
                {'error': 'User not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f'Error in public_profile: {str(e)}', exc_info=True)
            return Response(
                {'error': 'An error occurred while fetching the profile.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
        try:
            # Get friendship status
            friendship_status_value = 'none'
            friendship_id = None
            friendship = Friendship.objects.filter(
                Q(from_user=request.user, to_user=user) | Q(from_user=user, to_user=request.user)
            ).first()
            
            if friendship:
                friendship_status_value = friendship.status
                friendship_id = str(friendship.id)
            
            # Serialize user data (excluding phone number)
            from .serializers import UserSerializer
            serializer = UserSerializer(user, context={'request': request})
            user_data = serializer.data
            
            # Remove phone number from response
            user_data.pop('phone_number', None)
            user_data.pop('phone_verified', None)
            
            # Add friendship status
            user_data['friendship_status'] = friendship_status_value
            user_data['friendship_id'] = friendship_id
            
            return Response(user_data, status=status.HTTP_200_OK)
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f'Error serializing user profile: {str(e)}', exc_info=True)
            return Response(
                {'error': 'An error occurred while processing the profile data.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def friends_list(request):
    """Get list of friends (accepted friendships)."""
    friendships = Friendship.objects.filter(
        Q(from_user=request.user) | Q(to_user=request.user),
        status='accepted'
    ).select_related('from_user__profile', 'to_user__profile')
    
    friends = []
    for friendship in friendships:
        friend = friendship.to_user if friendship.from_user == request.user else friendship.from_user
        friends.append(friend)
    
    serializer = UserBasicSerializer(friends, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsActiveAndVerified])
def send_friend_request(request):
    """Send a friend request."""
    to_user_id = request.data.get('to_user_id')
    
    if not to_user_id:
        return Response({'error': 'to_user_id is required.'}, 
                       status=status.HTTP_400_BAD_REQUEST)
    
    try:
        to_user = User.objects.get(id=to_user_id, is_active=True)
    except User.DoesNotExist:
        return Response({'error': 'User not found.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    if to_user == request.user:
        return Response({'error': 'Cannot send friend request to yourself.'}, 
                       status=status.HTTP_400_BAD_REQUEST)
    
    # Check if friendship already exists
    friendship = Friendship.objects.filter(
        Q(from_user=request.user, to_user=to_user) |
        Q(from_user=to_user, to_user=request.user)
    ).first()
    
    if friendship:
        if friendship.status == 'accepted':
            return Response({'error': 'Already friends.'}, 
                           status=status.HTTP_400_BAD_REQUEST)
        elif friendship.status == 'pending':
            if friendship.from_user == request.user:
                return Response({'error': 'Friend request already sent.'}, 
                               status=status.HTTP_400_BAD_REQUEST)
            else:
                # Auto-accept if other user sent request
                friendship.status = 'accepted'
                friendship.save()
                
                # Create notification for the original sender
                from notifications.utils import create_notification
                create_notification(
                    recipient=friendship.from_user,
                    notification_type='friend_request_accepted',
                    title='Demande d\'ami acceptée',
                    message=f'{request.user.username} a accepté votre demande d\'ami',
                    related_object_type='user',
                    related_object_id=request.user.id
                )
                
                return Response({'message': 'Friend request accepted.'}, 
                               status=status.HTTP_200_OK)
        else:
            # Rejected, create new request
            friendship.delete()
    
    # Create new friendship request
    friendship = Friendship.objects.create(
        from_user=request.user,
        to_user=to_user,
        status='pending'
    )
    
    # Create notification
    from notifications.utils import create_notification
    create_notification(
        recipient=to_user,
        notification_type='friend_request',
        title='Nouvelle demande d\'ami',
        message=f'{request.user.username} vous a envoyé une demande d\'ami',
        related_object_type='user',
        related_object_id=request.user.id
    )
    
    serializer = FriendshipSerializer(friendship)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def accept_friend_request(request, friendship_id):
    """Accept a friend request."""
    try:
        friendship = Friendship.objects.get(
            id=friendship_id,
            to_user=request.user,
            status='pending'
        )
    except Friendship.DoesNotExist:
        return Response({'error': 'Friend request not found.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    friendship.status = 'accepted'
    friendship.save()
    
    # Create notification for the sender
    from notifications.utils import create_notification
    create_notification(
        recipient=friendship.from_user,
        notification_type='friend_request_accepted',
        title='Demande d\'ami acceptée',
        message=f'{request.user.username} a accepté votre demande d\'ami',
        related_object_type='user',
        related_object_id=request.user.id
    )
    
    serializer = FriendshipSerializer(friendship)
    return Response(serializer.data)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def reject_friend_request(request, friendship_id):
    """Reject a friend request."""
    try:
        friendship = Friendship.objects.get(
            id=friendship_id,
            to_user=request.user,
            status='pending'
        )
    except Friendship.DoesNotExist:
        return Response({'error': 'Friend request not found.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    friendship.status = 'rejected'
    friendship.save()
    
    # Create notification for the sender
    from notifications.utils import create_notification
    create_notification(
        recipient=friendship.from_user,
        notification_type='friend_request',
        title='Demande d\'ami refusée',
        message=f'{request.user.username} a refusé votre demande d\'ami',
        related_object_type='user',
        related_object_id=request.user.id
    )
    
    return Response({'message': 'Friend request rejected.'})


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def remove_friend(request, friendship_id):
    """Remove a friend (delete friendship)."""
    try:
        friendship = Friendship.objects.get(
            id=friendship_id,
            status='accepted'
        )
    except Friendship.DoesNotExist:
        return Response({'error': 'Friendship not found.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    # Check if user is part of this friendship
    if friendship.from_user != request.user and friendship.to_user != request.user:
        return Response({'error': 'Not authorized.'}, 
                       status=status.HTTP_403_FORBIDDEN)
    
    friendship.delete()
    return Response({'message': 'Friend removed.'})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def friend_requests(request):
    """Get pending friend requests (received)."""
    friendships = Friendship.objects.filter(
        to_user=request.user,
        status='pending'
    ).select_related('from_user__profile')
    
    serializer = FriendshipSerializer(friendships, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def friendship_status(request, user_id):
    """Get friendship status with a specific user."""
    try:
        to_user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({'error': 'User not found.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    friendship = Friendship.objects.filter(
        Q(from_user=request.user, to_user=to_user) |
        Q(from_user=to_user, to_user=request.user)
    ).first()
    
    if not friendship:
        return Response({'status': 'none'})
    
    if friendship.status == 'accepted':
        return Response({'status': 'friends'})
    elif friendship.status == 'pending':
        if friendship.from_user == request.user:
            return Response({'status': 'request_sent'})
        else:
            return Response({'status': 'request_received'})
    else:
        return Response({'status': 'rejected'})


# ==================== ADMIN / CLASS LEADER ENDPOINTS ====================

@api_view(['GET'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def pending_students(request):
    """Get list of students pending activation (for admin/class leader)."""
    queryset = User.objects.filter(
        role='student'
    ).select_related('profile')
    
    # Si c'est un responsable de classe, filtrer par son école et sa classe
    if request.user.role == 'class_leader' and hasattr(request.user, 'profile'):
        user_profile = request.user.profile
        if user_profile.university:
            queryset = queryset.filter(profile__university=user_profile.university)
        # Filtrer par classe si spécifiée (field_of_study + academic_year)
        if user_profile.field_of_study:
            queryset = queryset.filter(profile__field_of_study=user_profile.field_of_study)
        if user_profile.academic_year:
            queryset = queryset.filter(profile__academic_year=user_profile.academic_year)
    
    # Filtres
    university = request.query_params.get('university')
    search = request.query_params.get('search')
    verification_status = request.query_params.get('verification_status')
    is_active_filter = request.query_params.get('is_active')
    field_of_study = request.query_params.get('field_of_study')  # Nouveau filtre
    academic_year = request.query_params.get('academic_year')  # Nouveau filtre
    
    if university:
        queryset = queryset.filter(profile__university__icontains=university)
    
    if search:
        queryset = queryset.filter(
            Q(username__icontains=search) |
            Q(email__icontains=search) |
            Q(first_name__icontains=search) |
            Q(last_name__icontains=search)
        )
    
    if verification_status:
        queryset = queryset.filter(verification_status=verification_status)
    
    if is_active_filter is not None:
        is_active_bool = is_active_filter.lower() == 'true'
        queryset = queryset.filter(is_active=is_active_bool)
    
    # Filtres par classe (pour responsables)
    if field_of_study:
        queryset = queryset.filter(profile__field_of_study__icontains=field_of_study)
    
    if academic_year:
        queryset = queryset.filter(profile__academic_year__icontains=academic_year)
    
    # Tri (ordering)
    ordering = request.query_params.get('ordering', '-date_joined')
    # Sécurité : valider que le champ de tri est autorisé
    allowed_orderings = ['date_joined', '-date_joined', 'username', '-username', 
                        'email', '-email', 'last_login', '-last_login',
                        'profile__field_of_study', '-profile__field_of_study',
                        'profile__academic_year', '-profile__academic_year']
    if ordering in allowed_orderings:
        queryset = queryset.order_by(ordering)
    else:
        queryset = queryset.order_by('-date_joined')
    
    # Pagination
    from rest_framework.pagination import PageNumberPagination
    
    class PendingStudentsPagination(PageNumberPagination):
        page_size = 20
        page_size_query_param = 'page_size'
        max_page_size = 100
    
    paginator = PendingStudentsPagination()
    page = paginator.paginate_queryset(queryset, request)
    
    if page is not None:
        serializer = UserSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)
    
    serializer = UserSerializer(queryset, many=True)
    return Response(serializer.data)


@api_view(['PUT'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def activate_student(request, user_id):
    """Activate a student account."""
    try:
        student = User.objects.get(id=user_id, role='student')
    except User.DoesNotExist:
        return Response({'error': 'Student not found.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    student.is_active = True
    student.save(update_fields=['is_active'])
    
    # Create notification for student
    from notifications.utils import create_notification
    create_notification(
        recipient=student,
        notification_type='account_activated',
        title='Compte activé',
        message=f'Votre compte a été activé par {request.user.username}. Vous pouvez maintenant utiliser toutes les fonctionnalités de CampusLink.',
        related_object_type='user',
        related_object_id=student.id
    )
    
    # Create audit log
    from moderation.utils import create_audit_log
    create_audit_log(
        user=request.user,
        action_type='user_activated',
        resource_type='user',
        resource_id=student.id,
        details={
            'user_id': str(student.id),
            'username': student.username,
            'email': student.email
        },
        request=request
    )
    
    serializer = UserSerializer(student)
    return Response({
        'message': 'Étudiant activé avec succès.',
        'user': serializer.data
    })


@api_view(['PUT'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def deactivate_student(request, user_id):
    """Deactivate a student account."""
    try:
        student = User.objects.get(id=user_id, role='student')
    except User.DoesNotExist:
        return Response({'error': 'Student not found.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    reason = request.data.get('reason', '')
    
    student.is_active = False
    student.save(update_fields=['is_active'])
    
    # Create notification for student
    from notifications.utils import create_notification
    notification_message = f'Votre compte a été désactivé par {request.user.username}.'
    if reason:
        notification_message += f' Raison: {reason}'
    notification_message += ' Contactez l\'administration pour plus d\'informations.'
    
    create_notification(
        recipient=student,
        notification_type='account_deactivated',
        title='Compte désactivé',
        message=notification_message,
        related_object_type='user',
        related_object_id=student.id
    )
    
    # Create audit log
    from moderation.utils import create_audit_log
    create_audit_log(
        user=request.user,
        action_type='user_deactivated',
        resource_type='user',
        resource_id=student.id,
        details={
            'user_id': str(student.id),
            'username': student.username,
            'email': student.email,
            'reason': reason
        },
        request=request
    )
    
    serializer = UserSerializer(student)
    return Response({
        'message': 'Étudiant désactivé avec succès.',
        'user': serializer.data
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsAdminOrClassLeader])
def admin_dashboard_stats(request):
    """Get dashboard statistics for admin/class leader."""
    from events.models import Event
    from groups.models import Group
    from social.models import Post
    
    # For class leaders, filter by their university
    if request.user.role == 'class_leader' and hasattr(request.user, 'profile') and request.user.profile:
        user_university = request.user.profile.university
        students_queryset = User.objects.filter(role='student')
        if user_university:
            students_queryset = students_queryset.filter(profile__university=user_university)
    else:
        # Admins and superusers see all
        students_queryset = User.objects.filter(role='student')
    
    stats = {
        'pending_students_count': students_queryset.filter(is_active=False).count(),
        'active_students_count': students_queryset.filter(is_active=True).count(),
        'total_students_count': students_queryset.count(),
        'events_count': Event.objects.count(),
        'groups_count': Group.objects.count(),
        'posts_count': Post.objects.count(),
        'recent_registrations': list(students_queryset.order_by('-date_joined')[:10].values('id', 'username', 'email', 'date_joined', 'is_active', 'is_verified'))
    }
    
    return Response(stats)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def class_leaders_list(request):
    """Get list of class leaders (for admin only)."""
    # Only admin can see all class leaders
    if not (request.user.is_staff or request.user.role == 'admin'):
        return Response(
            {'error': 'Permission denied. Admin access required.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    queryset = User.objects.filter(role='class_leader').select_related('profile')
    
    # Filtres
    university = request.query_params.get('university')
    search = request.query_params.get('search')
    is_active = request.query_params.get('is_active')
    ordering = request.query_params.get('ordering', '-date_joined')  # Tri
    
    if university:
        queryset = queryset.filter(profile__university__icontains=university)
    
    if search:
        queryset = queryset.filter(
            Q(username__icontains=search) |
            Q(email__icontains=search) |
            Q(first_name__icontains=search) |
            Q(last_name__icontains=search)
        )
    
    if is_active is not None:
        is_active_bool = is_active.lower() == 'true'
        queryset = queryset.filter(is_active=is_active_bool)
    
    # Tri - Support pour trier par université aussi
    allowed_ordering = ['date_joined', '-date_joined', 'username', '-username', 
                       'email', '-email', 'last_login', '-last_login',
                       'profile__university', '-profile__university']
    if ordering in allowed_ordering:
        queryset = queryset.order_by(ordering)
    else:
        queryset = queryset.order_by('-date_joined')
    
    # Pagination
    from rest_framework.pagination import PageNumberPagination
    
    class ClassLeadersPagination(PageNumberPagination):
        page_size = 20
        page_size_query_param = 'page_size'
        max_page_size = 100
    
    paginator = ClassLeadersPagination()
    page = paginator.paginate_queryset(queryset, request)
    
    if page is not None:
        serializer = UserSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)
    
    serializer = UserSerializer(queryset, many=True)
    return Response(serializer.data)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def assign_class_leader(request, user_id):
    """Assign class leader role to a user (admin only)."""
    if not (request.user.is_staff or request.user.role == 'admin'):
        return Response(
            {'error': 'Permission denied. Admin access required.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({'error': 'User not found.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    # Vérifier que l'utilisateur est un étudiant
    if user.role != 'student':
        return Response(
            {'error': 'Seuls les étudiants peuvent être assignés comme responsables de classe.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    user.role = 'class_leader'
    user.is_active = True  # Activer automatiquement
    user.save(update_fields=['role', 'is_active'])
    
    # Create notification
    from notifications.utils import create_notification
    create_notification(
        recipient=user,
        notification_type='class_leader_promoted',
        title='Promotion en Responsable de Classe',
        message=f'Vous avez été promu Responsable de Classe par {request.user.username}. Vous pouvez maintenant gérer les actualités et les étudiants de votre classe.',
        related_object_type='user',
        related_object_id=user.id
    )
    
    serializer = UserSerializer(user)
    return Response({
        'message': 'Responsable de classe assigné avec succès.',
        'user': serializer.data
    })


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def revoke_class_leader(request, user_id):
    """Revoke class leader role from a user (admin only)."""
    if not (request.user.is_staff or request.user.role == 'admin'):
        return Response(
            {'error': 'Permission denied. Admin access required.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = User.objects.get(id=user_id, role='class_leader')
    except User.DoesNotExist:
        return Response({'error': 'Responsable de classe non trouvé.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    user.role = 'student'
    user.save(update_fields=['role'])
    
    serializer = UserSerializer(user)
    return Response({
        'message': 'Rôle de responsable de classe révoqué avec succès.',
        'user': serializer.data
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def class_leaders_by_university(request):
    """Get class leaders grouped by university (admin only)."""
    if not (request.user.is_staff or request.user.role == 'admin'):
        return Response(
            {'error': 'Permission denied. Admin access required.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    from django.db.models import Count
    
    # Récupérer les responsables de classe avec leur université
    class_leaders = User.objects.filter(
        role='class_leader'
    ).select_related('profile').values(
        'profile__university'
    ).annotate(
        count=Count('id')
    ).order_by('profile__university')
    
    # Récupérer les détails par université
    universities = {}
    for item in class_leaders:
        uni = item['profile__university'] or 'Non spécifiée'
        if uni not in universities:
            universities[uni] = {
                'university': uni,
                'count': 0,
                'leaders': []
            }
        universities[uni]['count'] = item['count']
    
    # Récupérer les responsables par université
    for uni_name in universities.keys():
        if uni_name == 'Non spécifiée':
            leaders = User.objects.filter(
                role='class_leader',
                profile__university__isnull=True
            ).select_related('profile')[:10]
        else:
            leaders = User.objects.filter(
                role='class_leader',
                profile__university=uni_name
            ).select_related('profile')[:10]
        
        serializer = UserSerializer(leaders, many=True)
        universities[uni_name]['leaders'] = serializer.data
    
    return Response(list(universities.values()))

