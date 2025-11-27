from django.contrib import admin
from .models import Category, Event, Participation, EventComment, EventLike


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'slug', 'created_at']
    prepopulated_fields = {'slug': ('name',)}


@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    list_display = ['title', 'organizer', 'category', 'start_date', 'status', 'is_featured', 'created_at']
    list_filter = ['status', 'is_featured', 'category', 'created_at']
    search_fields = ['title', 'description', 'organizer__username']
    readonly_fields = ['views_count', 'participants_count', 'likes_count', 'created_at', 'updated_at']


@admin.register(Participation)
class ParticipationAdmin(admin.ModelAdmin):
    list_display = ['user', 'event', 'created_at']
    list_filter = ['created_at']
    search_fields = ['user__username', 'event__title']


@admin.register(EventComment)
class EventCommentAdmin(admin.ModelAdmin):
    list_display = ['event', 'user', 'created_at']
    list_filter = ['created_at']
    search_fields = ['content', 'user__username', 'event__title']


@admin.register(EventLike)
class EventLikeAdmin(admin.ModelAdmin):
    list_display = ['event', 'user', 'created_at']
    list_filter = ['created_at']
    search_fields = ['event__title', 'user__username']

