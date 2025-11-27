"""
Admin configuration for feed app.
"""
from django.contrib import admin
from .models import FeedItem


@admin.register(FeedItem)
class FeedItemAdmin(admin.ModelAdmin):
    list_display = ['title', 'author', 'type', 'visibility', 'university', 'is_published', 'created_at']
    list_filter = ['type', 'visibility', 'is_published', 'created_at']
    search_fields = ['title', 'content', 'author__username', 'author__email', 'university']
    readonly_fields = ['id', 'created_at', 'updated_at']
    date_hierarchy = 'created_at'

