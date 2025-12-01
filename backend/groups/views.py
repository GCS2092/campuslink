"""
Views for groups app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from django.db.models import Q, Count
from django.utils import timezone
from .models import Group, Membership, GroupPost
from .serializers import GroupSerializer, MembershipSerializer, GroupPostSerializer
from users.permissions import IsActiveAndVerified, IsActiveAndVerifiedOrReadOnly, IsAdminOrClassLeader


class GroupViewSet(viewsets.ModelViewSet):
    """ViewSet for groups."""
    serializer_class = GroupSerializer
    permission_classes = [IsActiveAndVerifiedOrReadOnly]  # Only active and verified users can create groups
    filterset_fields = ['university', 'category', 'is_public', 'is_verified']
    search_fields = ['name', 'description']
    ordering_fields = ['created_at', 'members_count', 'posts_count']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Return groups based on user role."""
        queryset = Group.objects.select_related('creator', 'university').prefetch_related('memberships__user')
        
        # Auto-filter for university admins
        if (hasattr(self.request, 'user') and 
            self.request.user.is_authenticated and
            self.request.user.role == 'university_admin' and
            self.request.user.managed_university):
            queryset = queryset.filter(university=self.request.user.managed_university)
        # Admins can see all groups (including private ones)
        elif (hasattr(self.request, 'user') and 
            self.request.user.is_authenticated and 
            (self.request.user.is_staff or 
             self.request.user.is_superuser or 
             self.request.user.role == 'admin')):
            # Admins see everything, but can filter
            is_public_filter = self.request.query_params.get('is_public')
            if is_public_filter is not None:
                is_public_bool = is_public_filter.lower() == 'true'
                queryset = queryset.filter(is_public=is_public_bool)
            
            is_verified_filter = self.request.query_params.get('is_verified')
            if is_verified_filter is not None:
                is_verified_bool = is_verified_filter.lower() == 'true'
                queryset = queryset.filter(is_verified=is_verified_bool)
        elif hasattr(self.request, 'user') and self.request.user.is_authenticated:
            # Regular users: public groups + groups where user is member
            queryset = queryset.filter(
                Q(is_public=True) | Q(memberships__user=self.request.user, memberships__status='active')
            ).distinct()
        else:
            # Only public groups for anonymous users
            queryset = queryset.filter(is_public=True)
        
        return queryset
    
    def get_permissions(self):
        """Set permissions based on action."""
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        elif self.action in ['destroy', 'moderate']:
            # Only admins can delete/moderate
            return [IsAuthenticated(), IsAdminOrClassLeader()]
        elif self.action == 'create':
            # Only verified users can create (admins shouldn't create directly)
            return [IsAuthenticated(), IsActiveAndVerified()]
        elif self.action in ['update', 'partial_update']:
            # Only creator or admin can update
            return [IsAuthenticated(), IsActiveAndVerifiedOrReadOnly()]
        return [IsActiveAndVerifiedOrReadOnly()]
    
    def perform_create(self, serializer):
        """Create group and add creator as admin (only verified users, not admins)."""
        # Prevent admins from creating groups directly
        if (self.request.user.is_staff or 
            self.request.user.is_superuser or 
            self.request.user.role == 'admin'):
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied('Les administrateurs ne peuvent pas créer de groupes directement. Les étudiants et responsables de classe gèrent les groupes.')
        
        # Auto-assign university from creator's profile
        user_university = None
        if hasattr(self.request.user, 'profile') and self.request.user.profile:
            user_university = self.request.user.profile.university
        
        group = serializer.save(creator=self.request.user, university=user_university)
        
        # Add creator as admin
        Membership.objects.create(
            group=group,
            user=self.request.user,
            role='admin',
            status='active'
        )
        
        group.members_count = 1
        group.save(update_fields=['members_count'])
        
        # Create group conversation automatically
        from messaging.models import Conversation, Participant
        conversation = Conversation.objects.create(
            conversation_type='group',
            name=group.name,
            group=group,
            created_by=self.request.user
        )
        # Add creator as participant
        Participant.objects.create(
            conversation=conversation,
            user=self.request.user
        )
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def join(self, request, pk=None):
        """Join a group."""
        group = self.get_object()
        
        if not group.is_public:
            return Response(
                {'error': 'This group is private. You need an invitation.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        membership, created = Membership.objects.get_or_create(
            group=group,
            user=request.user,
            defaults={'status': 'active', 'role': 'member'}
        )
        
        # Get or create group conversation
        from messaging.models import Conversation, Participant
        conversation, conv_created = Conversation.objects.get_or_create(
            group=group,
            conversation_type='group',
            defaults={
                'name': group.name,
                'created_by': group.creator
            }
        )
        
        # Add user to conversation if not already a participant
        participant, part_created = Participant.objects.get_or_create(
            conversation=conversation,
            user=request.user,
            defaults={'is_active': True}
        )
        if not part_created and not participant.is_active:
            participant.is_active = True
            participant.left_at = None
            participant.save()
        
        if created:
            group.members_count += 1
            group.save(update_fields=['members_count'])
            return Response({'message': 'Joined group successfully.'}, status=status.HTTP_201_CREATED)
        elif membership.status != 'active':
            membership.status = 'active'
            membership.left_at = None
            membership.save()
            group.members_count += 1
            group.save(update_fields=['members_count'])
            return Response({'message': 'Rejoined group successfully.'}, status=status.HTTP_200_OK)
        
        return Response({'message': 'Already a member.'}, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def leave(self, request, pk=None):
        """Leave a group."""
        group = self.get_object()
        
        try:
            membership = Membership.objects.get(group=group, user=request.user, status='active')
            membership.status = 'left'
            membership.left_at = timezone.now()
            membership.save()
            
            group.members_count = max(0, group.members_count - 1)
            group.save(update_fields=['members_count'])
            
            # Remove user from group conversation
            from messaging.models import Conversation, Participant
            try:
                conversation = Conversation.objects.get(group=group, conversation_type='group')
                participant = Participant.objects.get(conversation=conversation, user=request.user)
                participant.is_active = False
                participant.left_at = timezone.now()
                participant.save()
            except (Conversation.DoesNotExist, Participant.DoesNotExist):
                pass  # Conversation might not exist yet
            
            return Response({'message': 'Left group successfully.'}, status=status.HTTP_200_OK)
        except Membership.DoesNotExist:
            return Response(
                {'error': 'You are not a member of this group.'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=True, methods=['get'])
    def members(self, request, pk=None):
        """Get group members."""
        group = self.get_object()
        memberships = Membership.objects.filter(
            group=group,
            status='active'
        ).select_related('user').order_by('-role', 'joined_at')
        
        serializer = MembershipSerializer(memberships, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def posts(self, request, pk=None):
        """Get group posts."""
        group = self.get_object()
        
        # Check if user can view posts (member or public group)
        if not group.is_public:
            is_member = Membership.objects.filter(
                group=group,
                user=request.user,
                status='active'
            ).exists()
            if not is_member:
                return Response(
                    {'error': 'You must be a member to view posts.'},
                    status=status.HTTP_403_FORBIDDEN
                )
        
        posts = GroupPost.objects.filter(group=group).select_related('author').order_by('-created_at')
        serializer = GroupPostSerializer(posts, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def invite(self, request, pk=None):
        """Invite users to a group (for group admins/moderators)."""
        group = self.get_object()
        
        # Check if user is admin or moderator of the group
        try:
            membership = Membership.objects.get(group=group, user=request.user, status='active')
            if membership.role not in ['admin', 'moderator']:
                return Response(
                    {'error': 'Only group admins and moderators can invite users.'},
                    status=status.HTTP_403_FORBIDDEN
                )
        except Membership.DoesNotExist:
            return Response(
                {'error': 'You are not a member of this group.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        user_ids = request.data.get('user_ids', [])
        if not user_ids or not isinstance(user_ids, list):
            return Response(
                {'error': 'user_ids must be a list of user IDs.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        from users.models import User
        invited_users = []
        errors = []
        
        for user_id in user_ids:
            try:
                user = User.objects.get(id=user_id)
                
                # Check if user is already a member
                existing_membership = Membership.objects.filter(
                    group=group,
                    user=user
                ).first()
                
                if existing_membership:
                    if existing_membership.status == 'active':
                        errors.append(f'{user.username} is already a member.')
                    elif existing_membership.status == 'pending':
                        errors.append(f'{user.username} already has a pending invitation.')
                    else:
                        # Re-invite user who left
                        existing_membership.status = 'pending'
                        existing_membership.role = 'member'
                        existing_membership.joined_at = timezone.now()
                        existing_membership.left_at = None
                        existing_membership.save()
                    invited_users.append({
                        'user_id': str(user.id),
                        'username': user.username,
                        'status': 'reinvited'
                    })
                    # Create notification for reinvitation
                    from notifications.utils import create_notification
                    create_notification(
                        recipient=user,
                        notification_type='group_invitation',
                        title=f'Nouvelle invitation - {group.name}',
                        message=f'{request.user.username} vous a réinvité à rejoindre le groupe "{group.name}"',
                        related_object_type='group',
                        related_object_id=group.id
                    )
                else:
                    # Create new invitation
                    Membership.objects.create(
                        group=group,
                        user=user,
                        role='member',
                        status='pending'
                    )
                    invited_users.append({
                        'user_id': str(user.id),
                        'username': user.username,
                        'status': 'invited'
                    })
                    # Create notification
                    from notifications.utils import create_notification
                    create_notification(
                        recipient=user,
                        notification_type='group_invitation',
                        title=f'Invitation à {group.name}',
                        message=f'{request.user.username} vous a invité à rejoindre le groupe "{group.name}"',
                        related_object_type='group',
                        related_object_id=group.id
                    )
            except User.DoesNotExist:
                errors.append(f'User with ID {user_id} not found.')
        
        return Response({
            'message': f'Invited {len(invited_users)} users.',
            'invited': invited_users,
            'errors': errors
        }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def accept_invitation(self, request, pk=None):
        """Accept a group invitation."""
        group = self.get_object()
        
        try:
            membership = Membership.objects.get(
                group=group,
                user=request.user,
                status='pending'
            )
            membership.status = 'active'
            membership.joined_at = timezone.now()
            membership.save()
            
            group.members_count += 1
            group.save(update_fields=['members_count'])
            
            # Get or create group conversation and add user as participant
            from messaging.models import Conversation, Participant
            conversation, conv_created = Conversation.objects.get_or_create(
                group=group,
                conversation_type='group',
                defaults={
                    'name': group.name,
                    'created_by': group.creator
                }
            )
            # Add user to conversation if not already a participant
            participant, part_created = Participant.objects.get_or_create(
                conversation=conversation,
                user=request.user,
                defaults={'is_active': True}
            )
            if not part_created and not participant.is_active:
                participant.is_active = True
                participant.left_at = None
                participant.save()
            
            # Create notification for group admins
            from notifications.utils import create_bulk_notifications
            
            admins = Membership.objects.filter(
                group=group,
                status='active',
                role__in=['admin', 'moderator']
            ).exclude(user=request.user).values_list('user', flat=True)
            
            if admins:
                create_bulk_notifications(
                    recipients=list(admins),
                    notification_type='group_invitation',
                    title=f'{request.user.username} a rejoint {group.name}',
                    message=f'{request.user.username} a accepté l\'invitation et rejoint le groupe "{group.name}"',
                    related_object_type='group',
                    related_object_id=group.id
                )
            
            return Response({'message': 'Invitation accepted successfully.'}, status=status.HTTP_200_OK)
        except Membership.DoesNotExist:
            return Response(
                {'error': 'No pending invitation found for this group.'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def reject_invitation(self, request, pk=None):
        """Reject a group invitation."""
        group = self.get_object()
        
        try:
            membership = Membership.objects.get(
                group=group,
                user=request.user,
                status='pending'
            )
            membership.delete()
            
            return Response({'message': 'Invitation rejected successfully.'}, status=status.HTTP_200_OK)
        except Membership.DoesNotExist:
            return Response(
                {'error': 'No pending invitation found for this group.'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated()])
    def my_invitations(self, request):
        """Get all pending group invitations for the current user."""
        invitations = Membership.objects.filter(
            user=request.user,
            status='pending'
        ).select_related('group', 'group__creator').order_by('-joined_at')
        
        serializer = MembershipSerializer(invitations, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated(), IsAdminOrClassLeader()])
    def moderate(self, request, pk=None):
        """Moderate group (admin only): delete, verify/unverify."""
        if not pk:
            return Response({
                'error': 'ID du groupe manquant.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Check permissions first
        if not (request.user.is_staff or 
                request.user.is_superuser or 
                request.user.role == 'admin' or 
                request.user.role == 'class_leader'):
            return Response({
                'error': 'Vous devez être administrateur ou responsable de classe pour effectuer cette action.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        try:
            # For moderation, admins should be able to access any group, even private ones
            # So we use a queryset that doesn't filter by visibility
            group = Group.objects.get(pk=pk)
        except Group.DoesNotExist:
            return Response({
                'error': 'Groupe introuvable.'
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error retrieving group {pk}: {str(e)}", exc_info=True)
            return Response({
                'error': 'Erreur lors de la récupération du groupe.',
                'details': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        action = request.data.get('action')  # 'delete', 'verify', 'unverify'
        
        if not action:
            return Response({
                'error': 'Action requise. Utilisez: delete, verify, ou unverify.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            if action == 'delete':
                group.delete()
                return Response({'message': 'Groupe supprimé avec succès.'}, status=status.HTTP_200_OK)
            elif action == 'verify':
                group.is_verified = True
                group.save(update_fields=['is_verified'])
                return Response({
                    'message': 'Groupe vérifié avec succès.',
                    'is_verified': True
                }, status=status.HTTP_200_OK)
            elif action == 'unverify':
                group.is_verified = False
                group.save(update_fields=['is_verified'])
                return Response({
                    'message': 'Vérification du groupe retirée.',
                    'is_verified': False
                }, status=status.HTTP_200_OK)
            else:
                return Response({
                    'error': 'Action invalide. Utilisez: delete, verify, ou unverify.'
                }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error moderating group {pk} with action {action}: {str(e)}", exc_info=True)
            return Response({
                'error': 'Erreur lors de la modération du groupe.',
                'details': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class GroupPostViewSet(viewsets.ModelViewSet):
    """ViewSet for group posts."""
    serializer_class = GroupPostSerializer
    permission_classes = [IsAuthenticated]
    
    def get_serializer_context(self):
        """Add request to serializer context."""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    def get_queryset(self):
        """Return posts for groups where user is member."""
        group_id = self.request.query_params.get('group')
        
        if group_id:
            # Check membership
            is_member = Membership.objects.filter(
                group_id=group_id,
                user=self.request.user,
                status='active'
            ).exists()
            
            if not is_member:
                return GroupPost.objects.none()
            
            return GroupPost.objects.filter(group_id=group_id).select_related('author', 'group')
        
        return GroupPost.objects.none()
    
    def perform_create(self, serializer):
        """Create post and check membership."""
        group = serializer.validated_data['group']
        
        # Check if user is member
        is_member = Membership.objects.filter(
            group=group,
            user=self.request.user,
            status='active'
        ).exists()
        
        if not is_member:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You must be a member to post in this group.")
        
        post = serializer.save(author=self.request.user)
        
        # Update group posts count
        group.posts_count += 1
        group.save(update_fields=['posts_count'])
        
        # Create notifications for group members (except the author)
        from notifications.utils import create_bulk_notifications
        from .models import Membership
        
        members = Membership.objects.filter(
            group=group,
            status='active'
        ).exclude(user=self.request.user).values_list('user', flat=True)
        
        if members:
            create_bulk_notifications(
                recipients=list(members),
                notification_type='group_post',
                title=f'Nouveau post dans {group.name}',
                message=f'{self.request.user.username} a publié dans le groupe "{group.name}": {post.content[:100]}{"..." if len(post.content) > 100 else ""}',
                related_object_type='group_post',
                related_object_id=post.id
            )
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def like(self, request, pk=None):
        """Like a group post."""
        from .models import GroupPostLike, Membership
        
        post = self.get_object()
        user = request.user
        
        # Check if user is member of the group
        is_member = Membership.objects.filter(
            group=post.group,
            user=user,
            status='active'
        ).exists()
        
        if not is_member:
            return Response(
                {'error': 'Vous devez être membre du groupe pour liker un post.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        like, created = GroupPostLike.objects.get_or_create(user=user, post=post)
        
        if created:
            post.likes_count += 1
            post.save(update_fields=['likes_count'])
            return Response({'message': 'Post liké.'}, status=status.HTTP_201_CREATED)
        
        return Response({'message': 'Déjà liké.'}, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['delete'], permission_classes=[IsAuthenticated])
    def unlike(self, request, pk=None):
        """Unlike a group post."""
        from .models import GroupPostLike
        
        post = self.get_object()
        user = request.user
        
        try:
            like = GroupPostLike.objects.get(user=user, post=post)
            like.delete()
            post.likes_count = max(0, post.likes_count - 1)
            post.save(update_fields=['likes_count'])
            return Response({'message': 'Like retiré.'}, status=status.HTTP_200_OK)
        except GroupPostLike.DoesNotExist:
            return Response({'error': 'Like non trouvé.'}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['get', 'post'], permission_classes=[IsAuthenticated])
    def comments(self, request, pk=None):
        """Get or create comments on a group post."""
        from .models import GroupPostComment, Membership
        from .serializers import GroupPostCommentSerializer
        
        post = self.get_object()
        user = request.user
        
        # Check if user is member of the group
        is_member = Membership.objects.filter(
            group=post.group,
            user=user,
            status='active'
        ).exists()
        
        if not is_member:
            return Response(
                {'error': 'Vous devez être membre du groupe pour voir/commenter les posts.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if request.method == 'GET':
            comments = GroupPostComment.objects.filter(post=post).select_related('user', 'user__profile').order_by('created_at')
            serializer = GroupPostCommentSerializer(comments, many=True, context={'request': request})
            return Response(serializer.data)
        
        # POST - Create comment
        serializer = GroupPostCommentSerializer(data=request.data)
        if serializer.is_valid():
            comment = serializer.save(post=post, user=user)
            post.comments_count += 1
            post.save(update_fields=['comments_count'])
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)