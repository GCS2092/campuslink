"""
Social models for CampusLink.
"""
import uuid
from django.db import models
from django.utils import timezone
from users.models import User


class Post(models.Model):
    """Social post."""
    
    POST_TYPE_CHOICES = [
        ('text', 'Texte'),
        ('image', 'Image'),
        ('video', 'Vidéo'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts', db_index=True)
    content = models.TextField()
    post_type = models.CharField(max_length=20, choices=POST_TYPE_CHOICES, default='text')
    image_url = models.URLField(max_length=500, blank=True)
    video_url = models.URLField(max_length=500, blank=True)
    is_public = models.BooleanField(default=True)
    is_hidden = models.BooleanField(default=False, db_index=True, help_text="Hidden by admin moderation")
    is_deleted = models.BooleanField(default=False, db_index=True, help_text="Soft delete flag")
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='posts_deleted',
        help_text="Admin who deleted this post"
    )
    moderation_status = models.CharField(
        max_length=20,
        choices=[
            ('approved', 'Approuvé'),
            ('pending', 'En attente'),
            ('rejected', 'Rejeté'),
            ('hidden', 'Masqué'),
        ],
        default='approved',
        db_index=True
    )
    likes_count = models.IntegerField(default=0)
    comments_count = models.IntegerField(default=0)
    shares_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'social_post'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['author']),
            models.Index(fields=['created_at']),
            models.Index(fields=['is_public']),
            models.Index(fields=['is_hidden']),
            models.Index(fields=['is_deleted']),
            models.Index(fields=['moderation_status']),
        ]
    
    def __str__(self):
        return f"{self.author.username}: {self.content[:50]}"


class PostComment(models.Model):
    """Comments on posts."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments', db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='post_comments', db_index=True)
    content = models.TextField()
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'social_postcomment'
        indexes = [
            models.Index(fields=['post']),
            models.Index(fields=['user']),
        ]
    
    def __str__(self):
        return f"{self.user.username} on {self.post.id}"


class PostLike(models.Model):
    """Likes on posts."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='likes', db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='post_likes', db_index=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'social_postlike'
        unique_together = ['post', 'user']
        indexes = [
            models.Index(fields=['post']),
            models.Index(fields=['user']),
        ]
    
    def __str__(self):
        return f"{self.user.username} likes {self.post.id}"

