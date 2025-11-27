"""
Admin configuration for messaging app.
"""
from django.contrib import admin
from .models import Conversation, Participant, Message


@admin.register(Conversation)
class ConversationAdmin(admin.ModelAdmin):
    """Admin interface for Conversation model."""
    list_display = ['id', 'conversation_type', 'name', 'created_by', 'created_at', 'last_message_at']
    list_filter = ['conversation_type', 'created_at']
    search_fields = ['name', 'created_by__username']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(Participant)
class ParticipantAdmin(admin.ModelAdmin):
    """Admin interface for Participant model."""
    list_display = ['id', 'conversation', 'user', 'is_active', 'joined_at', 'unread_count']
    list_filter = ['is_active', 'joined_at']
    search_fields = ['user__username', 'conversation__id']
    readonly_fields = ['id', 'joined_at']


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    """Admin interface for Message model."""
    list_display = ['id', 'conversation', 'sender', 'content_preview', 'created_at', 'is_read']
    list_filter = ['is_read', 'message_type', 'created_at']
    search_fields = ['content', 'sender__username']
    readonly_fields = ['id', 'created_at']
    
    def content_preview(self, obj):
        return obj.content[:50] + '...' if len(obj.content) > 50 else obj.content
    content_preview.short_description = 'Content'
