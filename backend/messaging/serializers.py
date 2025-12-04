"""
Serializers for messaging app.
"""
from rest_framework import serializers
from .models import Conversation, Participant, Message, MessageReaction
from users.serializers import UserSerializer, UserBasicSerializer


class MessageReactionSerializer(serializers.ModelSerializer):
    """Serializer for MessageReaction model."""
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = MessageReaction
        fields = ['id', 'user', 'emoji', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']


class MessageSerializer(serializers.ModelSerializer):
    """Serializer for Message model."""
    sender = serializers.SerializerMethodField()
    read_by = serializers.SerializerMethodField()
    reactions = serializers.SerializerMethodField()
    is_read_by_me = serializers.SerializerMethodField()
    
    class Meta:
        model = Message
        fields = [
            'id', 'conversation', 'sender', 'content', 'message_type',
            'attachment_url', 'attachment_name', 'attachment_size',
            'is_read', 'read_by', 'reactions', 'is_read_by_me', 'created_at', 'edited_at',
            'is_deleted_for_all', 'deleted_at'
        ]
        read_only_fields = ['id', 'sender', 'is_read', 'read_by', 'reactions', 'created_at', 'edited_at', 'deleted_at']
    
    def get_sender(self, obj):
        """Get sender with error handling."""
        try:
            if obj.sender:
                # Use UserBasicSerializer for better performance and error handling
                return UserBasicSerializer(obj.sender, context=self.context).data
            return None
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error serializing sender for message {obj.id}: {str(e)}", exc_info=True)
            # Return minimal data if serialization fails
            try:
                return {
                    'id': str(obj.sender.id) if obj.sender and hasattr(obj.sender, 'id') else None,
                    'username': obj.sender.username if obj.sender and hasattr(obj.sender, 'username') else 'Unknown',
                    'email': getattr(obj.sender, 'email', ''),
                }
            except:
                return {'id': None, 'username': 'Unknown', 'email': ''}
    
    def get_read_by(self, obj):
        """Get read_by users with error handling."""
        try:
            if hasattr(obj, 'read_by'):
                # Use prefetched data if available, otherwise query
                if hasattr(obj, '_prefetched_objects_cache') and 'read_by' in obj._prefetched_objects_cache:
                    read_by_users = obj._prefetched_objects_cache['read_by'][:10]
                else:
                    read_by_users = list(obj.read_by.all()[:10])  # Limit to 10 to avoid performance issues
                
                result = []
                for user in read_by_users:
                    try:
                        if user:  # Check if user exists
                            result.append(UserBasicSerializer(user, context=self.context).data)
                    except Exception as e:
                        import logging
                        logger = logging.getLogger(__name__)
                        logger.warning(f"Error serializing read_by user {user.id if user and hasattr(user, 'id') else 'unknown'}: {str(e)}")
                        # Skip this user but continue with others
                        continue
                return result
            return []
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error serializing read_by for message {obj.id}: {str(e)}", exc_info=True)
            return []
    
    def get_reactions(self, obj):
        """Get reactions with error handling."""
        try:
            if hasattr(obj, 'reactions'):
                # Use prefetched data if available, otherwise query
                if hasattr(obj, '_prefetched_objects_cache') and 'reactions' in obj._prefetched_objects_cache:
                    reactions = obj._prefetched_objects_cache['reactions']
                else:
                    reactions = list(obj.reactions.all())
                
                result = []
                for reaction in reactions:
                    try:
                        if reaction:  # Check if reaction exists
                            result.append(MessageReactionSerializer(reaction, context=self.context).data)
                    except Exception as e:
                        import logging
                        logger = logging.getLogger(__name__)
                        logger.warning(f"Error serializing reaction {reaction.id if reaction and hasattr(reaction, 'id') else 'unknown'}: {str(e)}")
                        # Skip this reaction but continue with others
                        continue
                return result
            return []
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error serializing reactions for message {obj.id}: {str(e)}", exc_info=True)
            return []
    
    def get_is_read_by_me(self, obj):
        """Check if message is read by current user."""
        try:
            request = self.context.get('request')
            if request and request.user.is_authenticated:
                return obj.read_by.filter(id=request.user.id).exists()
            return False
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error checking is_read_by_me for message {obj.id}: {str(e)}")
            return False


class ParticipantSerializer(serializers.ModelSerializer):
    """Serializer for Participant model."""
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Participant
        fields = [
            'id', 'conversation', 'user', 'joined_at', 'left_at',
            'is_active', 'last_read_at', 'unread_count',
            'is_pinned', 'is_archived', 'is_favorite', 'mute_notifications'
        ]
        read_only_fields = ['id', 'joined_at', 'left_at', 'unread_count']


class ConversationSerializer(serializers.ModelSerializer):
    """Serializer for Conversation model."""
    created_by = UserSerializer(read_only=True)
    participants = ParticipantSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    group = serializers.SerializerMethodField()
    # User-specific conversation settings
    is_pinned = serializers.SerializerMethodField()
    is_archived = serializers.SerializerMethodField()
    is_favorite = serializers.SerializerMethodField()
    mute_notifications = serializers.SerializerMethodField()
    
    class Meta:
        model = Conversation
        fields = [
            'id', 'conversation_type', 'name', 'group', 'created_by', 'created_at',
            'updated_at', 'last_message_at', 'participants', 'last_message', 'unread_count',
            'is_pinned', 'is_archived', 'is_favorite', 'mute_notifications'
        ]
        read_only_fields = ['id', 'created_by', 'created_at', 'updated_at', 'last_message_at']
    
    def get_group(self, obj):
        """Get group information if this is a group conversation."""
        try:
            if obj.group:
                # Safely get profile image URL
                profile_image = None
                try:
                    if hasattr(obj.group, 'profile_image') and obj.group.profile_image:
                        if hasattr(obj.group.profile_image, 'url'):
                            profile_image = obj.group.profile_image.url
                        elif isinstance(obj.group.profile_image, str):
                            profile_image = obj.group.profile_image
                except Exception:
                    pass
                
                return {
                    'id': str(obj.group.id),
                    'name': obj.group.name,
                    'slug': getattr(obj.group, 'slug', None),
                    'profile_image': profile_image
                }
            return None
        except Exception as e:
            # Log error but don't break the serializer
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error getting group for conversation {obj.id}: {str(e)}", exc_info=True)
            return None
    
    def get_last_message(self, obj):
        """Get last message in conversation."""
        try:
            # Use the prefetched messages if available, otherwise query
            if hasattr(obj, '_prefetched_objects_cache') and 'messages' in obj._prefetched_objects_cache:
                messages = obj._prefetched_objects_cache['messages']
                last_message = [m for m in messages if m.deleted_at is None]
                if last_message:
                    last_message = max(last_message, key=lambda m: m.created_at)
                else:
                    last_message = None
            else:
                last_message = obj.messages.filter(deleted_at__isnull=True).order_by('-created_at').first()
            
            if last_message:
                return MessageSerializer(last_message, context=self.context).data
            return None
        except Exception as e:
            # Log error but don't break the serializer
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error getting last message for conversation {obj.id}: {str(e)}")
            return None
    
    def get_unread_count(self, obj):
        """Get unread count for current user."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                # Use prefetched participants if available
                if hasattr(obj, '_prefetched_objects_cache') and 'participants' in obj._prefetched_objects_cache:
                    participants = obj._prefetched_objects_cache['participants']
                    participant = next(
                        (p for p in participants if p.user.id == request.user.id and p.is_active),
                        None
                    )
                    if participant:
                        return participant.unread_count
                else:
                    participant = obj.participants.get(user=request.user, is_active=True)
                    return participant.unread_count
            except (Participant.DoesNotExist, StopIteration, AttributeError):
                return 0
            except Exception as e:
                # Log error but don't break the serializer
                import logging
                logger = logging.getLogger(__name__)
                logger.error(f"Error getting unread count for conversation {obj.id}: {str(e)}")
                return 0
        return 0
    
    def get_is_pinned(self, obj):
        """Get is_pinned status for current user."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                participant = obj.participants.get(user=request.user, is_active=True)
                return participant.is_pinned
            except Participant.DoesNotExist:
                return False
        return False
    
    def get_is_archived(self, obj):
        """Get is_archived status for current user."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                participant = obj.participants.get(user=request.user, is_active=True)
                return participant.is_archived
            except Participant.DoesNotExist:
                return False
        return False
    
    def get_is_favorite(self, obj):
        """Get is_favorite status for current user."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                participant = obj.participants.get(user=request.user, is_active=True)
                return participant.is_favorite
            except Participant.DoesNotExist:
                return False
        return False
    
    def get_mute_notifications(self, obj):
        """Get mute_notifications status for current user."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                participant = obj.participants.get(user=request.user, is_active=True)
                return participant.mute_notifications
            except Participant.DoesNotExist:
                return False
        return False

