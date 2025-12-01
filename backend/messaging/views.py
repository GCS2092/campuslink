"""
Views for messaging app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q, Count
from django.utils import timezone
from .models import Conversation, Participant, Message
from .serializers import ConversationSerializer, MessageSerializer, ParticipantSerializer
from users.models import User
from users.permissions import IsActiveAndVerified, IsActiveAndVerifiedOrReadOnly


class ConversationViewSet(viewsets.ModelViewSet):
    """ViewSet for conversations."""
    serializer_class = ConversationSerializer
    permission_classes = [IsAuthenticated, IsActiveAndVerifiedOrReadOnly]
    
    def get_queryset(self):
        """Return conversations where user is a participant."""
        try:
            queryset = Conversation.objects.filter(
                participants__user=self.request.user,
                participants__is_active=True
            ).distinct().select_related('created_by', 'group').prefetch_related(
                'participants',
                'participants__user',
                'messages'
            )
            
            # Filter by conversation type if requested
            conversation_type = self.request.query_params.get('type')
            if conversation_type in ['private', 'group']:
                queryset = queryset.filter(conversation_type=conversation_type)
            
            return queryset
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error in get_queryset for conversations: {str(e)}")
            # Return empty queryset on error
            return Conversation.objects.none()
    
    def perform_create(self, serializer):
        """Create conversation and add creator as participant."""
        conversation = serializer.save(created_by=self.request.user)
        
        # Add creator as participant
        Participant.objects.create(
            conversation=conversation,
            user=self.request.user
        )
    
    @action(detail=False, methods=['post'])
    def create_private(self, request):
        """Create a private conversation with another user."""
        other_user_id = request.data.get('user_id')
        
        if not other_user_id:
            return Response(
                {'error': 'user_id is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            other_user = User.objects.get(id=other_user_id)
        except User.DoesNotExist:
            return Response(
                {'error': 'User not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Check if private conversation already exists
        existing = Conversation.objects.filter(
            conversation_type='private',
            participants__user=request.user,
            participants__is_active=True
        ).filter(
            participants__user=other_user,
            participants__is_active=True
        ).distinct().first()
        
        if existing:
            serializer = self.get_serializer(existing)
            return Response(serializer.data, status=status.HTTP_200_OK)
        
        # Create new private conversation
        conversation = Conversation.objects.create(
            conversation_type='private',
            created_by=request.user
        )
        
        # Add both users as participants
        Participant.objects.create(conversation=conversation, user=request.user)
        Participant.objects.create(conversation=conversation, user=other_user)
        
        serializer = self.get_serializer(conversation)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'])
    def add_participant(self, request, pk=None):
        """Add participant to group conversation."""
        conversation = self.get_object()
        
        if conversation.conversation_type != 'group':
            return Response(
                {'error': 'Can only add participants to group conversations.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
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
        
        participant, created = Participant.objects.get_or_create(
            conversation=conversation,
            user=user,
            defaults={'is_active': True}
        )
        
        if not created:
            participant.is_active = True
            participant.left_at = None
            participant.save()
        
        serializer = ParticipantSerializer(participant)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=False, methods=['get'])
    def group_conversation(self, request):
        """Get conversation for a specific group."""
        group_id = request.query_params.get('group_id')
        if not group_id:
            return Response(
                {'error': 'group_id is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            from groups.models import Group, Membership
            group = Group.objects.select_related('creator').get(id=group_id)
            
            # Check if user is a member
            is_member = Membership.objects.filter(
                group=group,
                user=request.user,
                status='active'
            ).exists()
            
            if not is_member:
                return Response(
                    {'error': 'You must be a member of this group to access its conversation.'},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Get or create conversation
            # Use group.creator if available, otherwise use request.user as fallback
            creator = group.creator if group.creator else request.user
            conversation, created = Conversation.objects.get_or_create(
                group=group,
                conversation_type='group',
                defaults={
                    'name': group.name,
                    'created_by': creator
                }
            )
            
            # Ensure user is a participant
            participant, part_created = Participant.objects.get_or_create(
                conversation=conversation,
                user=request.user,
                defaults={'is_active': True}
            )
            if not part_created and not participant.is_active:
                participant.is_active = True
                participant.left_at = None
                participant.save()
            
            # Refresh conversation from DB to ensure participant is included
            conversation.refresh_from_db()
            
            # Reload conversation with all necessary relations for serialization
            conversation = Conversation.objects.select_related(
                'created_by', 'created_by__profile', 'group', 'group__creator'
            ).prefetch_related(
                'participants',
                'participants__user',
                'participants__user__profile',
                'messages',
                'messages__sender',
                'messages__sender__profile'
            ).get(id=conversation.id)
            
            # Serialize with proper context
            serializer = self.get_serializer(conversation, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Group.DoesNotExist:
            return Response(
                {'error': 'Group not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error in group_conversation for group_id {group_id}: {str(e)}", exc_info=True)
            return Response(
                {'error': f'Erreur lors de l\'ouverture de la conversation: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark all messages in conversation as read."""
        conversation = self.get_object()
        
        participant = Participant.objects.get(
            conversation=conversation,
            user=request.user,
            is_active=True
        )
        
        # Mark all messages as read
        Message.objects.filter(
            conversation=conversation
        ).exclude(sender=request.user).update(is_read=True)
        
        # Update participant
        participant.last_read_at = timezone.now()
        participant.unread_count = 0
        participant.save()
        
        return Response({'message': 'Conversation marked as read.'}, status=status.HTTP_200_OK)


class MessageViewSet(viewsets.ModelViewSet):
    """ViewSet for messages."""
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated, IsActiveAndVerifiedOrReadOnly]
    
    def get_queryset(self):
        """Return messages for conversations where user is a participant."""
        conversation_id = self.request.query_params.get('conversation')
        
        if conversation_id:
            # Check if user is participant
            is_participant = Participant.objects.filter(
                conversation_id=conversation_id,
                user=self.request.user,
                is_active=True
            ).exists()
            
            if not is_participant:
                return Message.objects.none()
            
            return Message.objects.filter(
                conversation_id=conversation_id,
                deleted_at__isnull=True
            ).select_related('sender').order_by('-created_at')
        
        return Message.objects.none()
    
    def perform_create(self, serializer):
        """Create message and check participant."""
        conversation = serializer.validated_data['conversation']
        
        # Check if user is participant
        is_participant = Participant.objects.filter(
            conversation=conversation,
            user=self.request.user,
            is_active=True
        ).exists()
        
        if not is_participant:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You are not a participant in this conversation.")
        
        message = serializer.save(sender=self.request.user)
        
        # Create notification for other participants (except sender)
        from notifications.utils import create_bulk_notifications
        
        other_participants = Participant.objects.filter(
            conversation=conversation,
            is_active=True
        ).exclude(user=self.request.user).values_list('user', flat=True)
        
        if other_participants:
            create_bulk_notifications(
                recipients=list(other_participants),
                notification_type='message',
                title=f'Nouveau message de {self.request.user.username}',
                message=f'{self.request.user.username}: {message.content[:100]}{"..." if len(message.content) > 100 else ""}',
                related_object_type='conversation',
                related_object_id=conversation.id,
                use_async=True
            )
    
    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def broadcast(self, request):
        """Send broadcast message to all students or specific class (for class leaders/admins)."""
        import logging
        logger = logging.getLogger(__name__)
        
        try:
            from users.permissions import IsAdminOrClassLeader
            
            # Check permissions
            if not (request.user.role == 'admin' or request.user.role == 'class_leader'):
                return Response(
                    {'error': 'Permission denied. Only admins and class leaders can send broadcast messages.'},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            content = request.data.get('content')
            if not content:
                return Response(
                    {'error': 'Content is required.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            broadcast_type = request.data.get('type', 'all')  # 'all', 'class', 'university'
            target_university = request.data.get('university')
            target_field_of_study = request.data.get('field_of_study')
            target_academic_year = request.data.get('academic_year')
            
            logger.info(f"Broadcast request from user {request.user.id}, type: {broadcast_type}")
            
            # Get target users
            target_users = User.objects.filter(role='student', is_active=True, is_verified=True)
            
            if broadcast_type == 'class':
                # Send to students in the same class as the class leader
                if request.user.role == 'class_leader' and hasattr(request.user, 'profile'):
                    user_profile = request.user.profile
                    if user_profile.university:
                        target_users = target_users.filter(profile__university=user_profile.university)
                    if user_profile.field_of_study:
                        target_users = target_users.filter(profile__field_of_study=user_profile.field_of_study)
                    if user_profile.academic_year:
                        target_users = target_users.filter(profile__academic_year=user_profile.academic_year)
                elif target_field_of_study or target_academic_year:
                    if target_field_of_study:
                        target_users = target_users.filter(profile__field_of_study__icontains=target_field_of_study)
                    if target_academic_year:
                        target_users = target_users.filter(profile__academic_year__icontains=target_academic_year)
            elif broadcast_type == 'university':
                if request.user.role == 'class_leader' and hasattr(request.user, 'profile'):
                    user_profile = request.user.profile
                    if user_profile.university:
                        target_users = target_users.filter(profile__university=user_profile.university)
                elif target_university:
                    target_users = target_users.filter(profile__university__icontains=target_university)
            # 'all' - send to all students (only for admins)
            elif broadcast_type == 'all' and request.user.role != 'admin':
                return Response(
                    {'error': 'Only admins can send messages to all students.'},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Limit to prevent too many operations
            target_users_count = target_users.count()
            target_users = list(target_users[:1000])  # Limit to 1000 users max
            
            logger.info(f"Broadcast will be sent to {len(target_users)} users (out of {target_users_count} total)")
            
            # Create individual conversations for each target user
            created_conversations = []
            for user in target_users:
                # Check if conversation already exists
                existing = Conversation.objects.filter(
                    conversation_type='private',
                    participants__user=request.user,
                    participants__is_active=True
                ).filter(
                    participants__user=user,
                    participants__is_active=True
                ).distinct().first()
                
                if not existing:
                    # Create new conversation
                    conversation = Conversation.objects.create(
                        conversation_type='private',
                        created_by=request.user
                    )
                    Participant.objects.create(conversation=conversation, user=request.user)
                    Participant.objects.create(conversation=conversation, user=user)
                    existing = conversation
                
                # Send message
                message = Message.objects.create(
                    conversation=existing,
                    sender=request.user,
                    content=content,
                    message_type='text'
                )
                
                # Update conversation last_message_at
                existing.last_message_at = timezone.now()
                existing.save()
                
                created_conversations.append({
                    'conversation_id': str(existing.id),
                    'user_id': str(user.id),
                    'username': user.username
                })
                
                # Create notification for broadcast message
                try:
                    from notifications.utils import create_notification
                    broadcast_type_label = {
                        'all': 'tous les étudiants',
                        'university': 'votre école',
                        'class': 'votre classe'
                    }.get(broadcast_type, 'vos contacts')
                    
                    create_notification(
                        recipient=user,
                        notification_type='message_broadcast',
                        title='Nouveau message de votre responsable',
                        message=f'{request.user.username} vous a envoyé un message: {content[:100]}{"..." if len(content) > 100 else ""}',
                        related_object_type='conversation',
                        related_object_id=str(existing.id) if existing.id else None
                    )
                except Exception as notif_error:
                    # Log notification error but don't fail the broadcast
                    import logging
                    logger = logging.getLogger(__name__)
                    logger.warning(f"Error creating notification for broadcast: {str(notif_error)}")
            
            return Response({
                'message': f'Broadcast message sent to {len(created_conversations)} users.',
                'conversations': created_conversations
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            logger.error(f"Error in broadcast message: {str(e)}", exc_info=True)
            import traceback
            logger.error(f"Traceback: {traceback.format_exc()}")
            return Response(
                {
                    'error': 'Erreur lors de l\'envoi du message de diffusion.',
                    'details': str(e) if logger.level <= logging.DEBUG else None
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def add_reaction(self, request, pk=None):
        """Add reaction to a message."""
        message = self.get_object()
        emoji = request.data.get('emoji')
        
        if not emoji:
            return Response(
                {'error': 'Emoji is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        from .models import MessageReaction
        reaction, created = MessageReaction.objects.get_or_create(
            message=message,
            user=request.user,
            emoji=emoji
        )
        
        if not created:
            return Response(
                {'error': 'Reaction already exists.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        from .serializers import MessageReactionSerializer
        serializer = MessageReactionSerializer(reaction)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['delete'], permission_classes=[IsAuthenticated])
    def remove_reaction(self, request, pk=None):
        """Remove reaction from a message."""
        message = self.get_object()
        emoji = request.data.get('emoji')
        
        if not emoji:
            return Response(
                {'error': 'Emoji is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        from .models import MessageReaction
        MessageReaction.objects.filter(
            message=message,
            user=request.user,
            emoji=emoji
        ).delete()
        
        return Response({'message': 'Reaction removed.'}, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def mark_read(self, request, pk=None):
        """Mark a specific message as read."""
        message = self.get_object()
        
        # Don't mark own messages as read
        if message.sender == request.user:
            return Response({'message': 'Cannot mark own message as read.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if user is participant
        is_participant = Participant.objects.filter(
            conversation=message.conversation,
            user=request.user,
            is_active=True
        ).exists()
        
        if not is_participant:
            return Response(
                {'error': 'You are not a participant in this conversation.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Mark as read
        message.read_by.add(request.user)
        
        # Update participant last_read_at
        participant = Participant.objects.get(
            conversation=message.conversation,
            user=request.user,
            is_active=True
        )
        participant.last_read_at = timezone.now()
        if participant.unread_count > 0:
            participant.unread_count -= 1
        participant.save()
        
        return Response({'message': 'Message marked as read.'}, status=status.HTTP_200_OK)