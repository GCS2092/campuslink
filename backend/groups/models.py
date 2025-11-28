"""
Groups/Clubs models for CampusLink.
"""
import uuid
from django.db import models
from django.utils import timezone
from users.models import User


class Group(models.Model):
    """Group/Club model."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200, db_index=True)
    slug = models.SlugField(unique=True, db_index=True)
    description = models.TextField()
    
    # Image fields - Use CloudinaryField if available, otherwise use regular ImageField
    try:
        from cloudinary.models import CloudinaryField
        CLOUDINARY_AVAILABLE = True
    except ImportError:
        CLOUDINARY_AVAILABLE = False
        CloudinaryField = None
    
    if CLOUDINARY_AVAILABLE and CloudinaryField:
        profile_image = CloudinaryField('image', folder='campuslink/group_profile_images', null=True, blank=True, help_text="Image de profil du groupe")
        cover_image = CloudinaryField('image', folder='campuslink/group_cover_images', null=True, blank=True, help_text="Image de couverture du groupe")
    else:
        profile_image = models.ImageField(upload_to='group_profile_images/', null=True, blank=True, help_text="Image de profil du groupe")
        cover_image = models.ImageField(upload_to='group_cover_images/', null=True, blank=True, help_text="Image de couverture du groupe")
    
    # Legacy URL fields for migration
    profile_image_url_legacy = models.URLField(max_length=500, blank=True, help_text="Ancienne URL de l'image de profil (pour migration)")
    cover_image_url_legacy = models.URLField(max_length=500, blank=True, help_text="Ancienne URL de l'image de couverture (pour migration)")
    
    creator = models.ForeignKey(User, on_delete=models.CASCADE, related_name='groups_created', db_index=True)
    university = models.ForeignKey(
        'users.University',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='groups',
        db_index=True,
        help_text="Université associée au groupe"
    )
    university_name_legacy = models.CharField(max_length=200, blank=True, help_text="Ancien nom (pour migration)")
    category = models.CharField(max_length=100, blank=True)  # Sport, Culture, Académique, etc.
    is_public = models.BooleanField(default=True, db_index=True)
    is_verified = models.BooleanField(default=False, db_index=True)
    members_count = models.IntegerField(default=0)
    posts_count = models.IntegerField(default=0)
    events_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'groups_group'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['creator']),
            models.Index(fields=['university']),
            models.Index(fields=['is_public']),
            models.Index(fields=['is_verified']),
            models.Index(fields=['slug']),
        ]
    
    def __str__(self):
        return self.name


class Membership(models.Model):
    """Membership in a group."""
    
    ROLE_CHOICES = [
        ('admin', 'Administrateur'),
        ('moderator', 'Modérateur'),
        ('member', 'Membre'),
        ('invited', 'Invité'),
    ]
    
    STATUS_CHOICES = [
        ('active', 'Actif'),
        ('pending', 'En attente'),
        ('banned', 'Banni'),
        ('left', 'Parti'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    group = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='memberships', db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='group_memberships', db_index=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='member', db_index=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True)
    joined_at = models.DateTimeField(default=timezone.now)
    left_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'groups_membership'
        unique_together = ['group', 'user']
        indexes = [
            models.Index(fields=['group']),
            models.Index(fields=['user']),
            models.Index(fields=['role']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return f"{self.user.username} - {self.group.name} ({self.role})"


class GroupPost(models.Model):
    """Post in a group."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    group = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='posts', db_index=True)
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='group_posts', db_index=True)
    content = models.TextField()
    post_type = models.CharField(max_length=20, default='text')  # text, image, video, event
    image_url = models.URLField(max_length=500, blank=True)
    video_url = models.URLField(max_length=500, blank=True)
    likes_count = models.IntegerField(default=0)
    comments_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'groups_grouppost'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['group']),
            models.Index(fields=['author']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"{self.author.username} in {self.group.name}"
