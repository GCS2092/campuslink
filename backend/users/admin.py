from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Profile, Friendship, Follow


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['username', 'email', 'role', 'is_verified', 'verification_status', 'is_active', 'date_joined']
    list_filter = ['role', 'is_verified', 'verification_status', 'is_active', 'date_joined']
    search_fields = ['username', 'email', 'phone_number']
    ordering = ['-date_joined']
    
    fieldsets = BaseUserAdmin.fieldsets + (
        ('CampusLink Info', {
            'fields': ('role', 'phone_number', 'phone_verified', 'is_verified', 'verification_status', 'last_activity')
        }),
    )


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'university', 'email_verified', 'reputation_score', 'created_at']
    list_filter = ['university', 'email_verified', 'verification_method']
    search_fields = ['user__username', 'user__email', 'university', 'student_id']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(Friendship)
class FriendshipAdmin(admin.ModelAdmin):
    list_display = ['from_user', 'to_user', 'status', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['from_user__username', 'to_user__username']


@admin.register(Follow)
class FollowAdmin(admin.ModelAdmin):
    list_display = ['follower', 'following', 'created_at']
    list_filter = ['created_at']
    search_fields = ['follower__username', 'following__username']

