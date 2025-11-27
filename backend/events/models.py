"""
Event models for CampusLink.
"""
import uuid
from django.db import models
from django.utils import timezone
from users.models import User


class Category(models.Model):
    """Event category."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(unique=True)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=50, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'events_category'
        verbose_name_plural = 'Categories'
    
    def __str__(self):
        return self.name


class Event(models.Model):
    """Event model."""
    
    STATUS_CHOICES = [
        ('draft', 'Brouillon'),
        ('published', 'Publié'),
        ('cancelled', 'Annulé'),
        ('completed', 'Terminé'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=200)
    description = models.TextField()
    organizer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='organized_events', db_index=True)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, db_index=True)
    start_date = models.DateTimeField(db_index=True)
    end_date = models.DateTimeField(null=True, blank=True)
    location = models.CharField(max_length=500)
    location_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    location_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    image_url = models.URLField(max_length=500, blank=True)
    capacity = models.IntegerField(null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    is_free = models.BooleanField(default=True)
    registration_link = models.URLField(max_length=500, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft', db_index=True)
    is_featured = models.BooleanField(default=False)
    views_count = models.IntegerField(default=0)
    participants_count = models.IntegerField(default=0)
    likes_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'events_event'
        indexes = [
            models.Index(fields=['organizer']),
            models.Index(fields=['category']),
            models.Index(fields=['start_date']),
            models.Index(fields=['status']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return self.title


class Participation(models.Model):
    """User participation in events."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='participations', db_index=True)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='participations', db_index=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'events_participation'
        unique_together = ['user', 'event']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['event']),
        ]
    
    def __str__(self):
        return f"{self.user.username} -> {self.event.title}"


class EventComment(models.Model):
    """Comments on events."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='comments', db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='event_comments', db_index=True)
    content = models.TextField()
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'events_eventcomment'
        indexes = [
            models.Index(fields=['event']),
            models.Index(fields=['user']),
        ]
    
    def __str__(self):
        return f"{self.user.username} on {self.event.title}"


class EventLike(models.Model):
    """Likes on events."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='likes', db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='event_likes', db_index=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'events_eventlike'
        unique_together = ['event', 'user']
        indexes = [
            models.Index(fields=['event']),
            models.Index(fields=['user']),
        ]
    
    def __str__(self):
        return f"{self.user.username} likes {self.event.title}"


class EventFavorite(models.Model):
    """User favorites for events."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favorite_events', db_index=True)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='favorited_by', db_index=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'events_eventfavorite'
        unique_together = ['user', 'event']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['event']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"{self.user.username} favorited {self.event.title}"


class EventInvitation(models.Model):
    """Invitation to an event."""
    import uuid
    import secrets
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='invitations', db_index=True)
    inviter = models.ForeignKey(User, on_delete=models.CASCADE, related_name='invitations_sent', db_index=True)
    invitee = models.ForeignKey(User, on_delete=models.CASCADE, related_name='invitations_received', db_index=True, null=True, blank=True)
    invitee_email = models.EmailField(blank=True, db_index=True)  # For non-registered users
    invitation_code = models.CharField(max_length=50, unique=True, db_index=True)
    status = models.CharField(max_length=20, default='pending', db_index=True)  # pending, accepted, declined
    created_at = models.DateTimeField(default=timezone.now)
    responded_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'events_eventinvitation'
        unique_together = ['event', 'invitee']  # One invitation per user per event
        indexes = [
            models.Index(fields=['event']),
            models.Index(fields=['inviter']),
            models.Index(fields=['invitee']),
            models.Index(fields=['invitation_code']),
            models.Index(fields=['status']),
        ]
    
    def save(self, *args, **kwargs):
        """Generate invitation code if not set."""
        if not self.invitation_code:
            self.invitation_code = f"INV{secrets.token_hex(8).upper()}"
        super().save(*args, **kwargs)
    
    def __str__(self):
        return f"Invitation to {self.event.title} for {self.invitee_email or self.invitee.username}"

