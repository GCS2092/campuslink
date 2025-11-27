"""
Admin configuration for groups app.
"""
from django.contrib import admin
from .models import Group, Membership, GroupPost


@admin.register(Group)
class GroupAdmin(admin.ModelAdmin):
    """Admin interface for Group model."""
    list_display = ['name', 'slug', 'creator', 'university', 'is_public', 'is_verified', 'members_count', 'created_at']
    list_filter = ['is_public', 'is_verified', 'university', 'created_at']
    search_fields = ['name', 'description', 'creator__username']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(Membership)
class MembershipAdmin(admin.ModelAdmin):
    """Admin interface for Membership model."""
    list_display = ['group', 'user', 'role', 'status', 'joined_at']
    list_filter = ['role', 'status', 'joined_at']
    search_fields = ['group__name', 'user__username']
    readonly_fields = ['id', 'joined_at']


@admin.register(GroupPost)
class GroupPostAdmin(admin.ModelAdmin):
    """Admin interface for GroupPost model."""
    list_display = ['group', 'author', 'content_preview', 'post_type', 'created_at']
    list_filter = ['post_type', 'created_at']
    search_fields = ['content', 'group__name', 'author__username']
    readonly_fields = ['id', 'created_at', 'updated_at']
    
    def content_preview(self, obj):
        return obj.content[:50] + '...' if len(obj.content) > 50 else obj.content
    content_preview.short_description = 'Content'
