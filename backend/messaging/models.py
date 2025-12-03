"""
Messaging models for CampusLink.
"""
import uuid
from django.db import models
from django.utils import timezone
from users.models import User


class Conversation(models.Model):
    """Conversation between users (private or group)."""
    
    TYPE_CHOICES = [
        ('private', 'Privé'),
        ('group', 'Groupe'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation_type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='private')
    name = models.CharField(max_length=200, blank=True)  # For group conversations
    # Link to Group if this is a group conversation
    group = models.ForeignKey(
        'groups.Group',
        on_delete=models.CASCADE,
        related_name='conversation',
        null=True,
        blank=True,
        db_index=True,
        help_text='Group associated with this conversation (only for group conversations)'
    )
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='conversations_created', db_index=True)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_message_at = models.DateTimeField(null=True, blank=True, db_index=True)
    
    class Meta:
        db_table = 'messaging_conversation'
        ordering = ['-last_message_at', '-created_at']
        indexes = [
            models.Index(fields=['created_by']),
            models.Index(fields=['conversation_type']),
            models.Index(fields=['last_message_at']),
            models.Index(fields=['group']),
        ]
        # Note: We don't enforce strict constraints here to allow flexibility
        # Group conversations should have a group, but we handle this in application logic
    
    def __str__(self):
        if self.conversation_type == 'group':
            return f"Group: {self.name}"
        return f"Private: {self.id}"


class Participant(models.Model):
    """Participants in a conversation."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='participants', db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='conversation_participations', db_index=True)
    joined_at = models.DateTimeField(default=timezone.now)
    left_at = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True, db_index=True)
    last_read_at = models.DateTimeField(null=True, blank=True)
    unread_count = models.IntegerField(default=0)
    # User-specific conversation settings
    is_pinned = models.BooleanField(default=False, db_index=True, help_text='User has pinned this conversation')
    is_archived = models.BooleanField(default=False, db_index=True, help_text='User has archived this conversation')
    is_favorite = models.BooleanField(default=False, db_index=True, help_text='User has marked this conversation as favorite')
    mute_notifications = models.BooleanField(default=False, help_text='User has muted notifications for this conversation')
    
    class Meta:
        db_table = 'messaging_participant'
        unique_together = ['conversation', 'user']
        indexes = [
            models.Index(fields=['conversation']),
            models.Index(fields=['user']),
            models.Index(fields=['is_active']),
            models.Index(fields=['is_pinned']),
            models.Index(fields=['is_archived']),
            models.Index(fields=['is_favorite']),
        ]
    
    def __str__(self):
        return f"{self.user.username} in {self.conversation}"


class Message(models.Model):
    """Message in a conversation."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages', db_index=True)
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='messages_sent', db_index=True)
    content = models.TextField()
    message_type = models.CharField(max_length=20, default='text')  # text, image, file, system
    is_read = models.BooleanField(default=False, db_index=True)
    read_by = models.ManyToManyField(User, related_name='messages_read', blank=True)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    edited_at = models.DateTimeField(null=True, blank=True)
    deleted_at = models.DateTimeField(null=True, blank=True)
    is_deleted_for_all = models.BooleanField(default=False, help_text='Message deleted for all participants')
    
    class Meta:
        db_table = 'messaging_message'
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['conversation']),
            models.Index(fields=['sender']),
            models.Index(fields=['is_read']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"{self.sender.username}: {self.content[:50]}"


class MessageReaction(models.Model):
    """Reaction to a message (emoji)."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='reactions', db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='message_reactions', db_index=True)
    emoji = models.CharField(max_length=10)  # Emoji unicode or shortcode
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'messaging_messagereaction'
        unique_together = ['message', 'user', 'emoji']  # One reaction per user per emoji per message
        indexes = [
            models.Index(fields=['message']),
            models.Index(fields=['user']),
        ]
    
    def __str__(self):
        return f"{self.user.username} reacted {self.emoji} to message {self.message.id}"
