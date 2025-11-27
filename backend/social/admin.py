from django.contrib import admin
from .models import Post, PostComment, PostLike


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ['author', 'post_type', 'is_public', 'likes_count', 'created_at']
    list_filter = ['post_type', 'is_public', 'created_at']
    search_fields = ['content', 'author__username']
    readonly_fields = ['likes_count', 'comments_count', 'shares_count', 'created_at', 'updated_at']


@admin.register(PostComment)
class PostCommentAdmin(admin.ModelAdmin):
    list_display = ['post', 'user', 'created_at']
    list_filter = ['created_at']
    search_fields = ['content', 'user__username']


@admin.register(PostLike)
class PostLikeAdmin(admin.ModelAdmin):
    list_display = ['post', 'user', 'created_at']
    list_filter = ['created_at']
    search_fields = ['post__content', 'user__username']

