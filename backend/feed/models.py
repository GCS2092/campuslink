"""
Feed models for campus news and updates.
"""
import uuid
from django.db import models
from django.utils import timezone
from users.models import User

# Try to import Cloudinary, fallback to regular ImageField
try:
    from cloudinary.models import CloudinaryField
    CLOUDINARY_AVAILABLE = True
except ImportError:
    CLOUDINARY_AVAILABLE = False
    CloudinaryField = None


class FeedItem(models.Model):
    """Model for feed items (actualités)."""
    
    TYPE_CHOICES = [
        ('event', 'Événement'),
        ('group', 'Groupe'),
        ('announcement', 'Annonce'),
        ('news', 'Actualité'),
    ]
    
    VISIBILITY_CHOICES = [
        ('public', 'Publique'),
        ('private', 'Privée (École)'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='feed_items')
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='news')
    title = models.CharField(max_length=200)
    content = models.TextField()
    
    # Image field - Use CloudinaryField if available, otherwise use regular ImageField
    if CLOUDINARY_AVAILABLE and CloudinaryField:
        image = CloudinaryField('image', folder='campuslink/feed_images', null=True, blank=True)
    else:
        image = models.ImageField(upload_to='feed_images/', null=True, blank=True)
    
    # Visibility settings
    visibility = models.CharField(
        max_length=10,
        choices=VISIBILITY_CHOICES,
        default='public',
        help_text="Publique: visible par tous. Privée: visible uniquement par les étudiants de l'école de l'auteur"
    )
    
    # University filter (for private visibility)
    university = models.CharField(max_length=200, blank=True, null=True)
    
    # Metadata
    is_published = models.BooleanField(default=True)
    is_hidden = models.BooleanField(default=False, db_index=True, help_text="Hidden by admin moderation")
    is_deleted = models.BooleanField(default=False, db_index=True, help_text="Soft delete flag")
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='feed_items_deleted',
        help_text="Admin who deleted this feed item"
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
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'feed_feeditem'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['-created_at']),
            models.Index(fields=['author', '-created_at']),
            models.Index(fields=['visibility', 'university', '-created_at']),
            models.Index(fields=['is_hidden']),
            models.Index(fields=['is_deleted']),
            models.Index(fields=['moderation_status']),
        ]
    
    def __str__(self):
        return f"{self.title} by {self.author.username}"
