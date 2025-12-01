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
from .models import User, Profile, Friendship, Follow, University, Campus, Department
from .serializers import (
    UserRegistrationSerializer, UserSerializer, ProfileSerializer,
    FriendshipSerializer, FollowSerializer, UserBasicSerializer,
    UniversitySerializer, UniversityBasicSerializer, CampusSerializer, CampusBasicSerializer,
    DepartmentSerializer, DepartmentBasicSerializer
)
from .permissions import IsVerified, IsActiveAndVerified, IsAdminOrClassLeader, IsAdmin, IsUniversityAdmin
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
        password = request.data.get('password')
        
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
        
        # Vérifier d'abord si l'utilisateur existe et si le mot de passe est correct
        # même si is_active=False
        if email and password:
            try:
                user = User.objects.get(email=email)
                if user.check_password(password):
                    # Vérifier si le compte est banni
                    if user.is_banned:
                        return Response(
                            {
                                'error': {
                                    'status_code': 403,
                                    'message': 'Votre compte a été banni.',
                                    'ban_reason': user.ban_reason,
                                }
                            },
                            status=status.HTTP_403_FORBIDDEN
                        )
                    
                    # Si le compte n'est pas activé, retourner un code spécial
                    if not user.is_active or not user.is_verified:
                        # Générer quand même un token pour permettre l'accès à la page d'attente
                        # On utilise une méthode qui fonctionne même si is_active=False
                        try:
                            # Temporairement activer l'utilisateur pour générer le token
                            original_is_active = user.is_active
                            user.is_active = True
                            refresh = RefreshToken.for_user(user)
                            user.is_active = original_is_active  # Restaurer l'état original
                            
                            return Response(
                                {
                                    'access': str(refresh.access_token),
                                    'refresh': str(refresh),
                                    'account_status': {
                                        'is_active': user.is_active,
                                        'is_verified': user.is_verified,
                                        'verification_status': user.verification_status,
                                        'requires_activation': True,
                                        'message': 'Votre compte est en attente de validation par un administrateur.'
                                    }
                                },
                                status=status.HTTP_200_OK
                            )
                        except Exception as token_error:
                            # Si la génération du token échoue, retourner quand même une réponse
                            logger.warning(f"Token generation failed for inactive user {email}: {str(token_error)}")
                            return Response(
                                {
                                    'account_status': {
                                        'is_active': user.is_active,
                                        'is_verified': user.is_verified,
                                        'verification_status': user.verification_status,
                                        'requires_activation': True,
                                        'message': 'Votre compte est en attente de validation par un administrateur.'
                                    }
                                },
                                status=status.HTTP_200_OK
                            )
                    
                    # Compte activé, procéder normalement
                    try:
                        response = super().post(request, *args, **kwargs)
                        # Succès - effacer les tentatives
                        if email:
                            clear_login_attempts(email)
                            logger.info(f"Successful login for {email}")
                        return response
                    except Exception as e:
                        # Si l'authentification échoue pour une autre raison
                        if email:
                            record_failed_login_attempt(email)
                            logger.warning(f"Failed login for {email}: {str(e)}")
                        raise
                else:
                    # Mot de passe incorrect
                    if email:
                        record_failed_login_attempt(email)
                    return Response(
                        {'detail': 'Email ou mot de passe incorrect.'},
                        status=status.HTTP_401_UNAUTHORIZED
                    )
            except User.DoesNotExist:
                # Utilisateur n'existe pas
                if email:
                    record_failed_login_attempt(email)
                return Response(
                    {'detail': 'Email ou mot de passe incorrect.'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
        
        # Si pas d'email/password, laisser le comportement par défaut
        try:
            response = super().post(request, *args, **kwargs)
            if email:
                clear_login_attempts(email)
                logger.info(f"Successful login for {email}")
            return response
        except Exception as e:
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
        # Allow inactive users to see their own profile
        serializer = UserSerializer(request.user)
        return Response(serializer.data)
    
    # Update profile and user
    user = request.user
    profile = user.profile
    
    # Update User fields (first_name, last_name)
    user_data = {}
    if 'first_name' in request.data:
        user_data['first_name'] = request.data['first_name']
    if 'last_name' in request.data:
        user_data['last_name'] = request.data['last_name']
    
    if user_data:
        for key, value in user_data.items():
            setattr(user, key, value)
        user.save(update_fields=list(user_data.keys()))
    
    # Update Profile fields
    profile_data = {k: v for k, v in request.data.items() if k not in ['first_name', 'last_name']}
    serializer = ProfileSerializer(profile, data=profile_data, partial=True)
    if serializer.is_valid():
        serializer.save()
        # Return updated user with profile
        user_serializer = UserSerializer(user)
        return Response(user_serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """Change user password."""
    from django.contrib.auth.password_validation import validate_password
    from django.core.exceptions import ValidationError
    
    user = request.user
    old_password = request.data.get('old_password')
    new_password = request.data.get('new_password')
    new_password_confirm = request.data.get('new_password_confirm')
    
    if not old_password or not new_password or not new_password_confirm:
        return Response(
            {'error': 'Tous les champs sont requis.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Verify old password
    if not user.check_password(old_password):
        return Response(
            {'error': 'L\'ancien mot de passe est incorrect.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Check if new passwords match
    if new_password != new_password_confirm:
        return Response(
            {'error': 'Les nouveaux mots de passe ne correspondent pas.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Validate new password
    try:
        validate_password(new_password, user)
    except ValidationError as e:
        return Response(
            {'error': 'Le nouveau mot de passe ne respecte pas les critères de sécurité.', 'details': list(e.messages)},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Set new password
    user.set_password(new_password)
    user.save()
    
    return Response(
        {'message': 'Mot de passe modifié avec succès.'},
        status=status.HTTP_200_OK
    )


@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def notification_preferences(request):
    """Get or update user notification preferences."""
    user = request.user
    
    if request.method == 'GET':
        # Get preferences from profile.interests (temporary storage)
        preferences = {}
        if hasattr(user, 'profile') and user.profile:
            profile = user.profile
            if profile.interests and isinstance(profile.interests, dict):
                preferences = profile.interests.get('notification_preferences', {})
        
        # Default preferences
        default_preferences = {
            'email_notifications': True,
            'push_notifications': True,
            'event_reminders': True,
            'friend_requests': True,
            'messages': True,
            'group_updates': True,
            'event_invitations': True,
        }
        
        # Merge with defaults
        for key, value in default_preferences.items():
            if key not in preferences:
                preferences[key] = value
        
        return Response(preferences)
    
    # Update preferences
    preferences = request.data
    
    # Validate preferences
    valid_keys = [
        'email_notifications', 'push_notifications', 'event_reminders',
        'friend_requests', 'messages', 'group_updates', 'event_invitations'
    ]
    
    for key in preferences.keys():
        if key not in valid_keys:
            return Response(
                {'error': f'Clé de préférence invalide: {key}'},
                status=status.HTTP_400_BAD_REQUEST
            )
        if not isinstance(preferences[key], bool):
            return Response(
                {'error': f'La valeur de {key} doit être un booléen.'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    # Store in profile (we'll add a JSONField for this)
    # For now, we'll store it in a simple way
    if hasattr(user, 'profile') and user.profile:
        # If Profile model has notification_preferences field, use it
        # Otherwise, we'll need to add it via migration
        # For now, let's use a workaround with interests field or create a simple storage
        profile = user.profile
        # We'll store as JSON in a text field or use interests field temporarily
        # This is a simplified approach - in production, add a proper JSONField
        try:
            import json
            if hasattr(profile, 'notification_preferences'):
                profile.notification_preferences = preferences
            else:
                # Store in interests as a workaround (not ideal, but works)
                # In production, add a notification_preferences JSONField to Profile
                profile.interests = preferences if isinstance(profile.interests, dict) else {}
            profile.save()
        except Exception as e:
            logger.error(f"Error saving notification preferences: {e}")
            return Response(
                {'error': 'Erreur lors de la sauvegarde des préférences.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    return Response(
        {'message': 'Préférences mises à jour avec succès.', 'preferences': preferences},
        status=status.HTTP_200_OK
    )


class UserViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for users."""
    queryset = User.objects.all()  # Start with all users
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = None  # Disable pagination to avoid errors
    
    def get_queryset(self):
        # Admins, superusers, and staff can see all users (including inactive)
        # University admins can only see users from their university
        # Regular users can only see active users
        if (self.request.user.is_staff or 
            self.request.user.is_superuser or 
            self.request.user.role == 'admin'):
            queryset = User.objects.all()
        elif self.request.user.role == 'university_admin' and self.request.user.managed_university:
            # University admin can only see users from their university
            queryset = User.objects.filter(profile__university=self.request.user.managed_university)
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
            # Support both UUID and name/slug
            try:
                from uuid import UUID
                UUID(university)  # Check if it's a UUID
                queryset = queryset.filter(profile__university_id=university)
            except ValueError:
                # It's a name or slug
                queryset = queryset.filter(
                    Q(profile__university__name__icontains=university) |
                    Q(profile__university__slug__icontains=university)
                )
        
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
    """Get list of friends (accepted friendships) with friendship IDs."""
    friendships = Friendship.objects.filter(
        Q(from_user=request.user) | Q(to_user=request.user),
        status='accepted'
    ).select_related('from_user__profile', 'to_user__profile')
    
    friends_data = []
    for friendship in friendships:
        friend = friendship.to_user if friendship.from_user == request.user else friendship.from_user
        friend_data = UserBasicSerializer(friend).data
        friend_data['friendship_id'] = str(friendship.id)  # Add friendship ID
        friends_data.append(friend_data)
    
    return Response(friends_data)


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
@permission_classes([IsAuthenticated, IsActiveAndVerified])
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
@permission_classes([IsAuthenticated, IsActiveAndVerified])
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
@permission_classes([IsAuthenticated])
def pending_students(request):
    """Get list of students pending activation (for admin/class leader/university admin)."""
    # Check permissions: admin, class_leader, or university_admin
    if not (request.user.is_staff or request.user.role == 'admin' or 
            request.user.role == 'class_leader' or 
            (request.user.role == 'university_admin' and request.user.managed_university)):
        return Response(
            {'error': 'Permission denied. Admin, class leader, or university admin access required.'},
            status=status.HTTP_403_FORBIDDEN
        )
    queryset = User.objects.filter(
        role='student',
        profile__isnull=False  # Only students with profiles
    ).select_related('profile')
    
    # Si c'est un admin d'université, filtrer par son université
    if request.user.role == 'university_admin' and request.user.managed_university:
        queryset = queryset.filter(profile__university=request.user.managed_university)
    # Si c'est un responsable de classe, filtrer par son école (université) ET sa classe
    elif request.user.role == 'class_leader' and hasattr(request.user, 'profile'):
        user_profile = request.user.profile
        # Filtrer par école (université) ET classe (field_of_study + academic_year)
        if user_profile.university:
            queryset = queryset.filter(profile__university=user_profile.university)
        if user_profile.field_of_study:
            queryset = queryset.filter(profile__field_of_study=user_profile.field_of_study)
        if user_profile.academic_year:
            queryset = queryset.filter(profile__academic_year=user_profile.academic_year)
    
    # Filtres
    university = request.query_params.get('university')
    search = request.query_params.get('search')
    verification_status = request.query_params.get('verification_status')
    is_active_filter = request.query_params.get('is_active')
    academic_year = request.query_params.get('academic_year')  # Filtre par classe
    
    # Only allow university filter for admins (class leaders are already filtered by their university)
    if university and (request.user.is_staff or request.user.role == 'admin'):
        queryset = queryset.filter(profile__university__name__icontains=university)
    
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
    
    # Filtre par classe
    if academic_year:
        queryset = queryset.filter(profile__academic_year=academic_year)
    
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
    
    # Vérifier que l'admin d'université ne peut activer que ses étudiants
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(student, 'profile') or not student.profile.university:
            return Response(
                {'error': 'Cet étudiant n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if student.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez activer que les étudiants de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
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
    
    # Vérifier que l'admin d'université ne peut désactiver que ses étudiants
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(student, 'profile') or not student.profile.university:
            return Response(
                {'error': 'Cet étudiant n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if student.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez désactiver que les étudiants de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
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
@permission_classes([IsAuthenticated, IsAdmin])
def admin_dashboard_stats(request):
    """Get dashboard statistics for admin only (global platform stats)."""
    # Explicitly reject university_admin and class_leader
    if request.user.role == 'university_admin' or request.user.role == 'class_leader':
        return Response(
            {'error': 'Only global administrators can access this endpoint.'},
            status=status.HTTP_403_FORBIDDEN
        )
    from events.models import Event, Participation
    from groups.models import Group, Membership
    from social.models import Post
    from django.db.models import Count, Q
    from django.utils import timezone
    from datetime import timedelta
    
    # Admin sees all data (no filtering)
    students_queryset = User.objects.filter(role='student')
    events_queryset = Event.objects.all()
    groups_queryset = Group.objects.all()
    posts_queryset = Post.objects.all()
    
    # Time-based statistics
    now = timezone.now()
    last_7_days = now - timedelta(days=7)
    last_30_days = now - timedelta(days=30)
    this_month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    
    # Registration trends
    registrations_last_7_days = students_queryset.filter(date_joined__gte=last_7_days).count()
    registrations_last_30_days = students_queryset.filter(date_joined__gte=last_30_days).count()
    registrations_this_month = students_queryset.filter(date_joined__gte=this_month_start).count()
    
    # Activity statistics
    active_students_last_7_days = students_queryset.filter(
        is_active=True,
        last_activity__gte=last_7_days
    ).count()
    
    # Events statistics
    upcoming_events = events_queryset.filter(start_date__gte=now, status='published').count()
    past_events = events_queryset.filter(start_date__lt=now).count()
    events_this_month = events_queryset.filter(created_at__gte=this_month_start).count()
    
    # Groups statistics
    verified_groups = groups_queryset.filter(is_verified=True).count()
    public_groups = groups_queryset.filter(is_public=True).count()
    groups_this_month = groups_queryset.filter(created_at__gte=this_month_start).count()
    
    # Top groups by members
    top_groups = groups_queryset.annotate(
        active_members=Count('memberships', filter=Q(memberships__status='active'))
    ).order_by('-active_members')[:5].values('id', 'name', 'active_members')
    
    # Top events by participants
    top_events = events_queryset.annotate(
        participants=Count('participations')
    ).order_by('-participants')[:5].values('id', 'title', 'participants', 'start_date')
    
    # Verification rate
    total_students = students_queryset.count()
    verified_count = students_queryset.filter(is_verified=True).count()
    verification_rate = (verified_count / total_students * 100) if total_students > 0 else 0
    
    # Activity rate (students active in last 30 days)
    active_in_30_days = students_queryset.filter(
        is_active=True,
        last_activity__gte=last_30_days
    ).count()
    activity_rate = (active_in_30_days / total_students * 100) if total_students > 0 else 0
    
    stats = {
        # Basic counts
        'pending_students_count': students_queryset.filter(is_active=False).count(),
        'active_students_count': students_queryset.filter(is_active=True).count(),
        'total_students_count': total_students,
        'verified_students_count': verified_count,
        'unverified_students_count': students_queryset.filter(is_verified=False).count(),
        'events_count': events_queryset.count(),
        'groups_count': groups_queryset.count(),
        'posts_count': posts_queryset.count(),
        
        # Trends
        'registrations_last_7_days': registrations_last_7_days,
        'registrations_last_30_days': registrations_last_30_days,
        'registrations_this_month': registrations_this_month,
        
        # Activity metrics
        'active_students_last_7_days': active_students_last_7_days,
        'active_students_last_30_days': active_in_30_days,
        'activity_rate': round(activity_rate, 2),
        'verification_rate': round(verification_rate, 2),
        
        # Events details
        'upcoming_events': upcoming_events,
        'past_events': past_events,
        'events_this_month': events_this_month,
        
        # Groups details
        'verified_groups': verified_groups,
        'public_groups': public_groups,
        'groups_this_month': groups_this_month,
        
        # Top content
        'top_groups': list(top_groups),
        'top_events': list(top_events),
        
        # Recent registrations
        'recent_registrations': list(students_queryset.order_by('-date_joined')[:10].values('id', 'username', 'email', 'date_joined', 'is_active', 'is_verified'))
    }
    
    return Response(stats)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def class_leader_dashboard_stats(request):
    """Get dashboard statistics for class leader (filtered by their university AND class)."""
    # Explicitly reject university_admin and global admin
    if request.user.role != 'class_leader':
        return Response(
            {'error': 'Only class leaders can access this endpoint.'},
            status=status.HTTP_403_FORBIDDEN
        )
    if request.user.role == 'university_admin' or request.user.role == 'admin':
        return Response(
            {'error': 'University admins and global admins cannot access class leader dashboard.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    from events.models import Event, Participation
    from groups.models import Group, Membership
    from social.models import Post
    from django.db.models import Count, Q
    from django.utils import timezone
    from datetime import timedelta
    
    # Get class leader's university and class info from profile
    user_profile = request.user.profile if hasattr(request.user, 'profile') else None
    
    if not user_profile or not user_profile.university:
        return Response(
            {'error': 'Class leader must have a university in their profile.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    user_university = user_profile.university
    
    # Filter by class leader's university AND class (field_of_study + academic_year)
    students_filter = {'role': 'student', 'profile__university': user_university}
    if user_profile.field_of_study:
        students_filter['profile__field_of_study'] = user_profile.field_of_study
    if user_profile.academic_year:
        students_filter['profile__academic_year'] = user_profile.academic_year
    
    students_queryset = User.objects.filter(**students_filter)
    
    # Events: filter by university AND organizer's class
    events_filter = Q(university=user_university) | Q(university__isnull=True, organizer__profile__university=user_university)
    if user_profile.field_of_study:
        events_filter &= Q(organizer__profile__field_of_study=user_profile.field_of_study)
    if user_profile.academic_year:
        events_filter &= Q(organizer__profile__academic_year=user_profile.academic_year)
    events_queryset = Event.objects.filter(events_filter)
    
    # Groups: filter by university AND members' class
    groups_filter = Q(university=user_university)
    if user_profile.field_of_study:
        groups_filter &= Q(memberships__user__profile__field_of_study=user_profile.field_of_study)
    if user_profile.academic_year:
        groups_filter &= Q(memberships__user__profile__academic_year=user_profile.academic_year)
    groups_queryset = Group.objects.filter(groups_filter).distinct()
    
    # Posts: filter by author's university AND class
    posts_filter = Q(author__profile__university=user_university)
    if user_profile.field_of_study:
        posts_filter &= Q(author__profile__field_of_study=user_profile.field_of_study)
    if user_profile.academic_year:
        posts_filter &= Q(author__profile__academic_year=user_profile.academic_year)
    posts_queryset = Post.objects.filter(posts_filter)
    
    # Time-based statistics
    now = timezone.now()
    last_7_days = now - timedelta(days=7)
    last_30_days = now - timedelta(days=30)
    this_month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    
    # Registration trends
    registrations_last_7_days = students_queryset.filter(date_joined__gte=last_7_days).count()
    registrations_last_30_days = students_queryset.filter(date_joined__gte=last_30_days).count()
    registrations_this_month = students_queryset.filter(date_joined__gte=this_month_start).count()
    
    # Activity statistics
    active_students_last_7_days = students_queryset.filter(
        is_active=True,
        last_activity__gte=last_7_days
    ).count()
    
    # Events statistics
    upcoming_events = events_queryset.filter(start_date__gte=now, status='published').count()
    past_events = events_queryset.filter(start_date__lt=now).count()
    events_this_month = events_queryset.filter(created_at__gte=this_month_start).count()
    
    # Groups statistics
    verified_groups = groups_queryset.filter(is_verified=True).count()
    public_groups = groups_queryset.filter(is_public=True).count()
    groups_this_month = groups_queryset.filter(created_at__gte=this_month_start).count()
    
    # Top groups by members
    top_groups = groups_queryset.annotate(
        active_members=Count('memberships', filter=Q(memberships__status='active'))
    ).order_by('-active_members')[:5].values('id', 'name', 'active_members')
    
    # Top events by participants
    top_events = events_queryset.annotate(
        participants=Count('participations')
    ).order_by('-participants')[:5].values('id', 'title', 'participants', 'start_date')
    
    # Verification rate
    total_students = students_queryset.count()
    verified_count = students_queryset.filter(is_verified=True).count()
    verification_rate = (verified_count / total_students * 100) if total_students > 0 else 0
    
    # Activity rate (students active in last 30 days)
    active_in_30_days = students_queryset.filter(
        is_active=True,
        last_activity__gte=last_30_days
    ).count()
    activity_rate = (active_in_30_days / total_students * 100) if total_students > 0 else 0
    
    stats = {
        # Basic counts
        'pending_students_count': students_queryset.filter(is_active=False).count(),
        'active_students_count': students_queryset.filter(is_active=True).count(),
        'total_students_count': total_students,
        'verified_students_count': verified_count,
        'unverified_students_count': students_queryset.filter(is_verified=False).count(),
        'events_count': events_queryset.count(),
        'groups_count': groups_queryset.count(),
        'posts_count': posts_queryset.count(),
        
        # Trends
        'registrations_last_7_days': registrations_last_7_days,
        'registrations_last_30_days': registrations_last_30_days,
        'registrations_this_month': registrations_this_month,
        
        # Activity metrics
        'active_students_last_7_days': active_students_last_7_days,
        'active_students_last_30_days': active_in_30_days,
        'activity_rate': round(activity_rate, 2),
        'verification_rate': round(verification_rate, 2),
        
        # Events details
        'upcoming_events': upcoming_events,
        'past_events': past_events,
        'events_this_month': events_this_month,
        
        # Groups details
        'verified_groups': verified_groups,
        'public_groups': public_groups,
        'groups_this_month': groups_this_month,
        
        # Top content
        'top_groups': list(top_groups),
        'top_events': list(top_events),
        
        # University and class info
        'university': {
            'id': str(user_university.id),
            'name': user_university.name,
            'short_name': user_university.short_name
        },
        'class_info': {
            'field_of_study': user_profile.field_of_study if user_profile else None,
            'academic_year': user_profile.academic_year if user_profile else None
        },
        
        # Recent registrations
        'recent_registrations': list(students_queryset.order_by('-date_joined')[:10].values('id', 'username', 'email', 'date_joined', 'is_active', 'is_verified'))
    }
    
    return Response(stats)


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsUniversityAdmin])
def university_admin_dashboard_stats(request):
    """Get dashboard statistics for university admin (filtered by their managed university)."""
    # Additional check: ensure managed_university exists
    if not request.user.managed_university:
        return Response(
            {'error': 'University admin must have a managed university assigned.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    from events.models import Event, Participation
    from groups.models import Group, Membership
    from social.models import Post
    from django.db.models import Count, Q
    from django.utils import timezone
    from datetime import timedelta
    
    # Get university admin's managed university
    user_university = request.user.managed_university
    
    # Filter by university admin's managed university
    students_queryset = User.objects.filter(
        role='student',
        profile__university=user_university
    )
    events_queryset = Event.objects.filter(
        Q(university=user_university) | Q(university__isnull=True, organizer__profile__university=user_university)
    )
    groups_queryset = Group.objects.filter(university=user_university)
    posts_queryset = Post.objects.filter(author__profile__university=user_university)
    
    # Time-based statistics
    now = timezone.now()
    last_7_days = now - timedelta(days=7)
    last_30_days = now - timedelta(days=30)
    this_month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    
    # Registration trends
    registrations_last_7_days = students_queryset.filter(date_joined__gte=last_7_days).count()
    registrations_last_30_days = students_queryset.filter(date_joined__gte=last_30_days).count()
    registrations_this_month = students_queryset.filter(date_joined__gte=this_month_start).count()
    
    # Activity statistics
    active_students_last_7_days = students_queryset.filter(
        is_active=True,
        last_activity__gte=last_7_days
    ).count()
    
    # Events statistics
    upcoming_events = events_queryset.filter(start_date__gte=now, status='published').count()
    past_events = events_queryset.filter(start_date__lt=now).count()
    events_this_month = events_queryset.filter(created_at__gte=this_month_start).count()
    
    # Groups statistics
    verified_groups = groups_queryset.filter(is_verified=True).count()
    public_groups = groups_queryset.filter(is_public=True).count()
    groups_this_month = groups_queryset.filter(created_at__gte=this_month_start).count()
    
    # Top groups by members
    top_groups = groups_queryset.annotate(
        active_members=Count('memberships', filter=Q(memberships__status='active'))
    ).order_by('-active_members')[:5].values('id', 'name', 'active_members')
    
    # Top events by participants
    top_events = events_queryset.annotate(
        participants=Count('participations')
    ).order_by('-participants')[:5].values('id', 'title', 'participants', 'start_date')
    
    # Verification rate
    total_students = students_queryset.count()
    verified_count = students_queryset.filter(is_verified=True).count()
    verification_rate = (verified_count / total_students * 100) if total_students > 0 else 0
    
    # Activity rate (students active in last 30 days)
    active_in_30_days = students_queryset.filter(
        is_active=True,
        last_activity__gte=last_30_days
    ).count()
    activity_rate = (active_in_30_days / total_students * 100) if total_students > 0 else 0
    
    # Class leaders count for this university
    class_leaders_count = User.objects.filter(
        role='class_leader',
        profile__university=user_university
    ).count()
    
    stats = {
        # Basic counts
        'pending_students_count': students_queryset.filter(is_active=False).count(),
        'active_students_count': students_queryset.filter(is_active=True).count(),
        'total_students_count': total_students,
        'verified_students_count': verified_count,
        'unverified_students_count': students_queryset.filter(is_verified=False).count(),
        'events_count': events_queryset.count(),
        'groups_count': groups_queryset.count(),
        'posts_count': posts_queryset.count(),
        'class_leaders_count': class_leaders_count,
        
        # Trends
        'registrations_last_7_days': registrations_last_7_days,
        'registrations_last_30_days': registrations_last_30_days,
        'registrations_this_month': registrations_this_month,
        
        # Activity metrics
        'active_students_last_7_days': active_students_last_7_days,
        'active_students_last_30_days': active_in_30_days,
        'activity_rate': round(activity_rate, 2),
        'verification_rate': round(verification_rate, 2),
        
        # Events details
        'upcoming_events': upcoming_events,
        'past_events': past_events,
        'events_this_month': events_this_month,
        
        # Groups details
        'verified_groups': verified_groups,
        'public_groups': public_groups,
        'groups_this_month': groups_this_month,
        
        # Top content
        'top_groups': list(top_groups),
        'top_events': list(top_events),
        
        # University info
        'university': {
            'id': str(user_university.id),
            'name': user_university.name,
            'short_name': user_university.short_name
        },
        
        # Recent registrations
        'recent_registrations': list(students_queryset.order_by('-date_joined')[:10].values('id', 'username', 'email', 'date_joined', 'is_active', 'is_verified'))
    }
    
    return Response(stats)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_profile_stats(request):
    """Get personal statistics for the current user (events, groups, friends)."""
    from events.models import Event, Participation
    from groups.models import Group, Membership
    
    user = request.user
    
    # Events statistics
    events_organized = Event.objects.filter(organizer=user).count()
    events_participated = Participation.objects.filter(user=user).count()
    upcoming_participations = Participation.objects.filter(
        user=user,
        event__start_date__gte=timezone.now(),
        event__status='published'
    ).count()
    
    # Groups statistics
    groups_created = Group.objects.filter(creator=user).count()
    groups_member = Membership.objects.filter(
        user=user,
        status='active'
    ).count()
    
    # Friends statistics
    friends_count = Friendship.objects.filter(
        (Q(from_user=user) | Q(to_user=user)),
        status='accepted'
    ).count()
    
    # Recent activity
    recent_events_raw = Event.objects.filter(
        organizer=user
    ).order_by('-created_at')[:5].values('id', 'title', 'start_date', 'status')
    
    # Convert UUIDs to strings for proper JSON serialization
    recent_events = [
        {
            'id': str(event['id']),
            'title': event['title'],
            'start_date': event['start_date'].isoformat() if event['start_date'] else None,
            'status': event['status']
        }
        for event in recent_events_raw
    ]
    
    recent_participations_raw = Participation.objects.filter(
        user=user
    ).select_related('event').order_by('-created_at')[:5].values(
        'id', 'event__id', 'event__title', 'event__start_date', 'created_at'
    )
    
    # Convert UUIDs to strings for proper JSON serialization
    recent_participations = [
        {
            'id': str(part['id']),
            'event__id': str(part['event__id']) if part['event__id'] else None,
            'event__title': part['event__title'],
            'event__start_date': part['event__start_date'].isoformat() if part['event__start_date'] else None,
            'created_at': part['created_at'].isoformat() if part['created_at'] else None
        }
        for part in recent_participations_raw
    ]
    
    stats = {
        'events': {
            'organized': events_organized,
            'participated': events_participated,
            'upcoming': upcoming_participations,
        },
        'groups': {
            'created': groups_created,
            'member': groups_member,
        },
        'friends': {
            'count': friends_count,
        },
        'recent_events': recent_events,
        'recent_participations': recent_participations,
    }
    
    return Response(stats)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_profile_stats_detailed(request):
    """Get detailed statistics for graphs and charts."""
    from events.models import Event, Participation
    from groups.models import Group, Membership
    from django.db.models import Count, Q
    from django.db.models.functions import TruncMonth, TruncDate
    from datetime import datetime, timedelta
    
    user = request.user
    
    # Get date range (last 12 months)
    now = timezone.now()
    twelve_months_ago = now - timedelta(days=365)
    
    # Monthly participation stats (last 12 months)
    participations_by_month = Participation.objects.filter(
        user=user,
        created_at__gte=twelve_months_ago
    ).annotate(
        month=TruncMonth('created_at')
    ).values('month').annotate(count=Count('id')).order_by('month')
    
    monthly_participations = []
    for item in participations_by_month:
        monthly_participations.append({
            'month': item['month'].strftime('%Y-%m') if item['month'] else None,
            'count': item['count']
        })
    
    # Events organized by month
    events_organized_by_month = Event.objects.filter(
        organizer=user,
        created_at__gte=twelve_months_ago
    ).annotate(
        month=TruncMonth('created_at')
    ).values('month').annotate(count=Count('id')).order_by('month')
    
    monthly_organized = []
    for item in events_organized_by_month:
        monthly_organized.append({
            'month': item['month'].strftime('%Y-%m') if item['month'] else None,
            'count': item['count']
        })
    
    # Participation by category
    participations_by_category = Participation.objects.filter(
        user=user
    ).select_related('event__category').values(
        'event__category__name'
    ).annotate(count=Count('id')).order_by('-count')[:10]
    
    category_stats = [
        {
            'category': item['event__category__name'] or 'Sans catégorie',
            'count': item['count']
        }
        for item in participations_by_category
    ]
    
    # Activity heatmap data (last 30 days)
    thirty_days_ago = now - timedelta(days=30)
    daily_activity = Participation.objects.filter(
        user=user,
        created_at__gte=thirty_days_ago
    ).annotate(
        day=TruncDate('created_at')
    ).values('day').annotate(count=Count('id')).order_by('day')
    
    heatmap_data = []
    for item in daily_activity:
        heatmap_data.append({
            'date': item['day'].strftime('%Y-%m-%d') if item['day'] else None,
            'count': item['count']
        })
    
    # Friends activity (friends who participate in same events)
    # Get user's friends
    friends = User.objects.filter(
        Q(friendship_requests_sent__to_user=user, friendship_requests_sent__status='accepted') |
        Q(friendship_requests_received__from_user=user, friendship_requests_received__status='accepted')
    )
    
    # Get events where friends participate
    friends_participations = Participation.objects.filter(
        user__in=friends,
        event__participations__user=user
    ).exclude(user=user).values('event__id', 'event__title').annotate(
        friends_count=Count('user', distinct=True)
    ).order_by('-friends_count')[:5]
    
    friends_activity = [
        {
            'event_id': str(item['event__id']),
            'event_title': item['event__title'],
            'friends_count': item['friends_count']
        }
        for item in friends_participations
    ]
    
    stats = {
        'monthly_participations': monthly_participations,
        'monthly_organized': monthly_organized,
        'category_distribution': category_stats,
        'activity_heatmap': heatmap_data,
        'friends_activity': friends_activity,
    }
    
    return Response(stats)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def friend_suggestions(request):
    """Get friend suggestions based on common interests, university, groups, and mutual friends."""
    from events.models import Participation
    from groups.models import Membership
    
    user = request.user
    limit = int(request.query_params.get('limit', 10))
    
    # Get user's current friends and pending requests (to exclude)
    existing_friendships = Friendship.objects.filter(
        Q(from_user=user) | Q(to_user=user)
    ).values_list('from_user_id', 'to_user_id')
    
    excluded_user_ids = {user.id}
    for friendship in existing_friendships:
        excluded_user_ids.add(friendship[0] if friendship[0] != user.id else friendship[1])
    
    # Get user's profile data
    user_university = None
    user_academic_year = None
    user_department = None
    if hasattr(user, 'profile') and user.profile:
        user_university = user.profile.university
        user_academic_year = user.profile.academic_year_obj
        user_department = user.profile.department
    
    # Base queryset: verified and active users, excluding current user and existing friends
    base_queryset = User.objects.filter(
        is_verified=True,
        is_active=True
    ).exclude(
        id__in=excluded_user_ids
    ).select_related('profile')
    
    # Scoring system for suggestions
    suggestions = []
    
    for candidate in base_queryset[:limit * 5]:  # Get more to score
        if not hasattr(candidate, 'profile') or not candidate.profile:
            continue
            
        score = 0
        reasons = []
        
        # 1. Same university (high weight)
        if user_university and candidate.profile.university == user_university:
            score += 50
            reasons.append('Même université')
        
        # 2. Same academic year
        if user_academic_year and candidate.profile.academic_year_obj == user_academic_year:
            score += 30
            reasons.append('Même année académique')
        
        # 3. Same department
        if user_department and candidate.profile.department == user_department:
            score += 25
            reasons.append('Même département')
        
        # 4. Mutual friends
        # Get user's friends
        user_friends = User.objects.filter(
            Q(friendship_requests_sent__to_user=user, friendship_requests_sent__status='accepted') |
            Q(friendship_requests_received__from_user=user, friendship_requests_received__status='accepted')
        )
        
        # Get candidate's friends
        candidate_friends = User.objects.filter(
            Q(friendship_requests_sent__to_user=candidate, friendship_requests_sent__status='accepted') |
            Q(friendship_requests_received__from_user=candidate, friendship_requests_received__status='accepted')
        )
        
        # Count mutual friends
        mutual_friends = (set(user_friends.values_list('id', flat=True)) & 
                          set(candidate_friends.values_list('id', flat=True)))
        mutual_friends_count = len(mutual_friends)
        
        if mutual_friends_count > 0:
            score += mutual_friends_count * 10
            reasons.append(f'{mutual_friends_count} ami(s) en commun')
        
        # 5. Common groups
        user_groups = Membership.objects.filter(
            user=user,
            status='active'
        ).values_list('group_id', flat=True)
        
        candidate_groups = Membership.objects.filter(
            user=candidate,
            status='active'
        ).values_list('group_id', flat=True)
        
        common_groups = set(user_groups) & set(candidate_groups)
        if common_groups:
            score += len(common_groups) * 15
            reasons.append(f'{len(common_groups)} groupe(s) en commun')
        
        # 6. Common event participations
        user_events = Participation.objects.filter(user=user).values_list('event_id', flat=True)
        candidate_events = Participation.objects.filter(user=candidate).values_list('event_id', flat=True)
        
        common_events = set(user_events) & set(candidate_events)
        if common_events:
            score += len(common_events) * 5
            reasons.append(f'{len(common_events)} événement(s) en commun')
        
        # 7. Similar interests (if available)
        if hasattr(user.profile, 'interests') and hasattr(candidate.profile, 'interests'):
            user_interests = user.profile.interests or []
            candidate_interests = candidate.profile.interests or []
            if isinstance(user_interests, list) and isinstance(candidate_interests, list):
                common_interests = set(user_interests) & set(candidate_interests)
                if common_interests:
                    score += len(common_interests) * 8
                    reasons.append(f'{len(common_interests)} intérêt(s) commun(s)')
        
        if score > 0:
            suggestions.append({
                'user': candidate,
                'score': score,
                'reasons': reasons[:3]  # Top 3 reasons
            })
    
    # Sort by score
    suggestions.sort(key=lambda x: x['score'], reverse=True)
    
    # Serialize top suggestions
    serializer = UserBasicSerializer([s['user'] for s in suggestions[:limit]], many=True)
    result = serializer.data
    
    # Add reasons to each suggestion
    for i, suggestion in enumerate(suggestions[:limit]):
        result[i]['suggestion_reasons'] = suggestion['reasons']
        result[i]['suggestion_score'] = suggestion['score']
    
    return Response(result, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def class_leaders_list(request):
    """Get list of class leaders (for admin or university admin)."""
    # Admin can see all class leaders, university admin only their university's
    if not (request.user.is_staff or request.user.role == 'admin' or 
            (request.user.role == 'university_admin' and request.user.managed_university)):
        return Response(
            {'error': 'Permission denied. Admin or university admin access required.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    queryset = User.objects.filter(role='class_leader').select_related('profile')
    
    # University admin can only see class leaders from their managed university
    if request.user.role == 'university_admin' and request.user.managed_university:
        queryset = queryset.filter(profile__university=request.user.managed_university)
    
    # Filtres
    university = request.query_params.get('university')
    search = request.query_params.get('search')
    is_active = request.query_params.get('is_active')
    ordering = request.query_params.get('ordering', '-date_joined')  # Tri
    
    if university:
        queryset = queryset.filter(profile__university__name__icontains=university)
    
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
    """Assign class leader role to a user (admin or university admin)."""
    if not (request.user.is_staff or request.user.role == 'admin' or 
            (request.user.role == 'university_admin' and request.user.managed_university)):
        return Response(
            {'error': 'Permission denied. Admin or university admin access required.'},
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
    
    # University admin can only assign class leaders from their managed university
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(user, 'profile') or not user.profile.university:
            return Response(
                {'error': 'Cet utilisateur n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if user.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez assigner que les étudiants de votre université comme responsables de classe.'},
                status=status.HTTP_403_FORBIDDEN
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
    """Revoke class leader role from a user (admin or university admin)."""
    if not (request.user.is_staff or request.user.role == 'admin' or 
            (request.user.role == 'university_admin' and request.user.managed_university)):
        return Response(
            {'error': 'Permission denied. Admin or university admin access required.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = User.objects.get(id=user_id, role='class_leader')
    except User.DoesNotExist:
        return Response({'error': 'Responsable de classe non trouvé.'}, 
                       status=status.HTTP_404_NOT_FOUND)
    
    # University admin can only revoke class leaders from their managed university
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(user, 'profile') or not user.profile.university:
            return Response(
                {'error': 'Cet utilisateur n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if user.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez révoquer que les responsables de classe de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
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


class CampusViewSet(viewsets.ModelViewSet):
    """ViewSet for managing campuses."""
    queryset = Campus.objects.all()
    serializer_class = CampusSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Filter campuses based on user role."""
        university_id = self.request.query_params.get('university')
        
        if university_id:
            queryset = Campus.objects.filter(university_id=university_id)
        elif self.request.user.role == 'university_admin' and self.request.user.managed_university:
            # University admin can only see campuses of their university
            queryset = Campus.objects.filter(university=self.request.user.managed_university)
        elif self.request.user.role == 'admin' or self.request.user.is_staff:
            # Global admin can see all campuses
            queryset = Campus.objects.all()
        else:
            # Regular users can only see active campuses
            queryset = Campus.objects.filter(is_active=True)
        
        return queryset.order_by('-is_main', 'name')
    
    def perform_create(self, serializer):
        """Create campus with university validation."""
        from .permissions import IsUniversityAdminOrGlobalAdmin
        permission = IsUniversityAdminOrGlobalAdmin()
        
        if not permission.has_permission(self.request, self):
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied(permission.message)
        
        # If university admin, ensure they can only create for their university
        if (self.request.user.role == 'university_admin' and 
            self.request.user.managed_university):
            # Auto-assign university for university admins
            serializer.validated_data['university'] = self.request.user.managed_university
            serializer.validated_data.pop('university_id', None)
        
        serializer.save()
    
    def perform_update(self, serializer):
        """Update campus with university validation."""
        from .permissions import IsUniversityAdminOrGlobalAdmin
        permission = IsUniversityAdminOrGlobalAdmin()
        
        if not permission.has_permission(self.request, self):
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied(permission.message)
        
        campus = self.get_object()
        
        # If university admin, ensure they can only update campuses of their university
        if (self.request.user.role == 'university_admin' and 
            self.request.user.managed_university):
            if campus.university != self.request.user.managed_university:
                from rest_framework.exceptions import PermissionDenied
                raise PermissionDenied('Vous ne pouvez modifier que les campus de votre université.')
            
            # Prevent changing university
            if 'university' in serializer.validated_data:
                new_university = serializer.validated_data['university']
                if new_university != self.request.user.managed_university:
                    from rest_framework.exceptions import PermissionDenied
                    raise PermissionDenied('Vous ne pouvez pas changer l\'université d\'un campus.')
        
        serializer.save()
    
    def get_permissions(self):
        """Set permissions based on action."""
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        else:
            # Only global admins and university admins can create/update/delete
            from .permissions import IsUniversityAdminOrGlobalAdmin
            return [IsUniversityAdminOrGlobalAdmin()]


class DepartmentViewSet(viewsets.ModelViewSet):
    """ViewSet for managing departments."""
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Filter departments based on user role."""
        university_id = self.request.query_params.get('university')
        
        if university_id:
            queryset = Department.objects.filter(university_id=university_id)
        elif self.request.user.role == 'university_admin' and self.request.user.managed_university:
            # University admin can only see departments of their university
            queryset = Department.objects.filter(university=self.request.user.managed_university)
        elif self.request.user.role == 'admin' or self.request.user.is_staff:
            # Global admin can see all departments
            queryset = Department.objects.all()
        else:
            # Regular users can only see active departments
            queryset = Department.objects.filter(is_active=True)
        
        return queryset.order_by('name')
    
    def get_permissions(self):
        """Set permissions based on action."""
        from .permissions import IsUniversityAdminOrReadOnly
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        else:
            # University admins can manage departments of their university, global admins can manage all
            from .permissions import IsUniversityAdminOrGlobalAdmin
            return [IsUniversityAdminOrGlobalAdmin()]
    
    def perform_create(self, serializer):
        """Create department with university validation."""
        from .permissions import IsUniversityAdminOrGlobalAdmin
        permission = IsUniversityAdminOrGlobalAdmin()
        
        if not permission.has_permission(self.request, self):
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied(permission.message)
        
        # If university admin, ensure they can only create for their university
        if (self.request.user.role == 'university_admin' and 
            self.request.user.managed_university):
            # Auto-assign university for university admins
            serializer.validated_data['university'] = self.request.user.managed_university
            serializer.validated_data.pop('university_id', None)
        
        serializer.save()
    
    def perform_update(self, serializer):
        """Update department with university validation."""
        from .permissions import IsUniversityAdminOrGlobalAdmin
        permission = IsUniversityAdminOrGlobalAdmin()
        
        if not permission.has_permission(self.request, self):
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied(permission.message)
        
        department = self.get_object()
        
        # If university admin, ensure they can only update departments of their university
        if (self.request.user.role == 'university_admin' and 
            self.request.user.managed_university):
            if department.university != self.request.user.managed_university:
                from rest_framework.exceptions import PermissionDenied
                raise PermissionDenied('Vous ne pouvez modifier que les départements de votre université.')
            
            # Prevent changing university
            if 'university' in serializer.validated_data:
                new_university = serializer.validated_data['university']
                if new_university != self.request.user.managed_university:
                    from rest_framework.exceptions import PermissionDenied
                    raise PermissionDenied('Vous ne pouvez pas changer l\'université d\'un département.')
        
        serializer.save()


class UniversityViewSet(viewsets.ModelViewSet):
    """ViewSet for managing universities (admin only)."""
    queryset = University.objects.all()
    serializer_class = UniversitySerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Filter universities based on user role."""
        if self.request.user.role == 'admin':
            # Global admin can see all universities
            return University.objects.all().order_by('name')
        elif self.request.user.role == 'university_admin':
            # University admin can only see their own university
            if self.request.user.managed_university:
                return University.objects.filter(id=self.request.user.managed_university.id)
            return University.objects.none()
        else:
            # Regular users can only see active universities
            return University.objects.filter(is_active=True).order_by('name')
    
    def get_permissions(self):
        """Set permissions based on action."""
        if self.action in ['list', 'retrieve', 'my_university']:
            # Anyone authenticated can view, university admins can see their university
            return [IsAuthenticated()]
        else:
            # Only global admins can create/update/delete
            from .permissions import IsAdmin
            return [IsAdmin()]
    
    @action(detail=True, methods=['get', 'put', 'patch'], permission_classes=[IsAuthenticated])
    def settings(self, request, pk=None):
        """Get or update university settings."""
        from .models import UniversitySettings
        from .serializers import UniversitySettingsSerializer
        from .permissions import IsUniversityAdminOrGlobalAdmin
        
        university = self.get_object()
        
        # Check permissions
        permission = IsUniversityAdminOrGlobalAdmin()
        if not permission.has_permission(request, self):
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied(permission.message)
        
        # If university admin, ensure they can only manage their own university
        if (request.user.role == 'university_admin' and 
            request.user.managed_university != university):
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied('Vous ne pouvez modifier que les paramètres de votre université.')
        
        # Get or create settings
        settings, created = UniversitySettings.objects.get_or_create(university=university)
        
        if request.method == 'GET':
            serializer = UniversitySettingsSerializer(settings)
            return Response(serializer.data)
        
        # Update settings
        serializer = UniversitySettingsSerializer(settings, data=request.data, partial=request.method == 'PATCH')
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def assign_admin(self, request, pk=None):
        """Assign a university admin to this university (global admin only)."""
        if request.user.role != 'admin':
            return Response(
                {'error': 'Only global admins can assign university admins.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        university = self.get_object()
        user_id = request.data.get('user_id')
        
        if not user_id:
            return Response(
                {'error': 'user_id is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {'error': 'User not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Check if user is already admin of another university
        if user.managed_university and user.managed_university != university:
            return Response(
                {'error': f'User is already admin of {user.managed_university.name}.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Assign university admin role
        user.role = 'university_admin'
        user.managed_university = university
        user.is_active = True
        user.is_verified = True
        user.save()
        
        serializer = UserSerializer(user)
        return Response({
            'message': f'{user.username} is now admin of {university.name}',
            'user': serializer.data
        }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['delete'], permission_classes=[IsAuthenticated])
    def remove_admin(self, request, pk=None):
        """Remove university admin from this university (global admin only)."""
        if request.user.role != 'admin':
            return Response(
                {'error': 'Only global admins can remove university admins.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        university = self.get_object()
        user_id = request.data.get('user_id')
        
        if not user_id:
            return Response(
                {'error': 'user_id is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user = User.objects.get(id=user_id, managed_university=university, role='university_admin')
        except User.DoesNotExist:
            return Response(
                {'error': 'University admin not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Remove university admin role
        user.role = 'student'  # Or keep as is, just remove managed_university
        user.managed_university = None
        user.save()
        
        return Response({
            'message': f'{user.username} is no longer admin of {university.name}'
        }, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def my_university(self, request):
        """Get current user's university (for university admins)."""
        if request.user.role != 'university_admin' or not request.user.managed_university:
            return Response(
                {'error': 'You are not a university admin.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        try:
            university = request.user.managed_university
            if not university:
                return Response(
                    {'error': 'No managed university found.'},
                    status=status.HTTP_404_NOT_FOUND
                )
            serializer = UniversitySerializer(university, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            import traceback
            logger.error(f"Error in my_university endpoint: {e}\n{traceback.format_exc()}")
            return Response(
                {'error': f'An error occurred while retrieving university information: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

