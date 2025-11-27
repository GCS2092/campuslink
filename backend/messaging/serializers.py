"""
Serializers for messaging app.
"""
from rest_framework import serializers
from .models import Conversation, Participant, Message
from users.serializers import UserSerializer


class MessageSerializer(serializers.ModelSerializer):
    """Serializer for Message model."""
    sender = UserSerializer(read_only=True)
    
    class Meta:
        model = Message
        fields = [
            'id', 'conversation', 'sender', 'content', 'message_type',
            'is_read', 'created_at', 'edited_at'
        ]
        read_only_fields = ['id', 'sender', 'is_read', 'created_at', 'edited_at']


class ParticipantSerializer(serializers.ModelSerializer):
    """Serializer for Participant model."""
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Participant
        fields = [
            'id', 'conversation', 'user', 'joined_at', 'left_at',
            'is_active', 'last_read_at', 'unread_count'
        ]
        read_only_fields = ['id', 'joined_at', 'left_at', 'unread_count']


class ConversationSerializer(serializers.ModelSerializer):
    """Serializer for Conversation model."""
    created_by = UserSerializer(read_only=True)
    participants = ParticipantSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    group = serializers.SerializerMethodField()
    
    class Meta:
        model = Conversation
        fields = [
            'id', 'conversation_type', 'name', 'group', 'created_by', 'created_at',
            'updated_at', 'last_message_at', 'participants', 'last_message', 'unread_count'
        ]
        read_only_fields = ['id', 'created_by', 'created_at', 'updated_at', 'last_message_at']
    
    def get_group(self, obj):
        """Get group information if this is a group conversation."""
        if obj.group:
            return {
                'id': str(obj.group.id),
                'name': obj.group.name,
                'slug': obj.group.slug,
                'profile_image': obj.group.profile_image
            }
        return None
    
    def get_last_message(self, obj):
        """Get last message in conversation."""
        last_message = obj.messages.filter(deleted_at__isnull=True).last()
        if last_message:
            return MessageSerializer(last_message).data
        return None
    
    def get_unread_count(self, obj):
        """Get unread count for current user."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                participant = obj.participants.get(user=request.user, is_active=True)
                return participant.unread_count
            except Participant.DoesNotExist:
                return 0
        return 0

