"""
Notification models for CampusLink.
"""
import uuid
from django.db import models
from django.utils import timezone
from users.models import User


class Notification(models.Model):
    """User notification."""
    
    TYPE_CHOICES = [
        ('event_created', 'Événement créé'),
        ('event_reminder', 'Rappel événement'),
        ('event_invitation', 'Invitation à un événement'),
        ('participation', 'Participation'),
        ('comment', 'Commentaire'),
        ('like', 'Like'),
        ('friend_request', 'Demande d\'ami'),
        ('friend_request_accepted', 'Demande d\'ami acceptée'),
        ('message', 'Message'),
        ('message_broadcast', 'Message broadcast'),
        ('group_invitation', 'Invitation à un groupe'),
        ('group_post', 'Nouveau post dans un groupe'),
        ('account_activated', 'Compte activé'),
        ('account_deactivated', 'Compte désactivé'),
        ('class_leader_promoted', 'Promu responsable de classe'),
        ('system', 'Système'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications', db_index=True)
    notification_type = models.CharField(max_length=50, choices=TYPE_CHOICES)
    title = models.CharField(max_length=200)
    message = models.TextField()
    is_read = models.BooleanField(default=False, db_index=True)
    related_object_type = models.CharField(max_length=50, blank=True)
    related_object_id = models.UUIDField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    
    class Meta:
        db_table = 'notifications_notification'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['recipient']),
            models.Index(fields=['is_read']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"{self.recipient.username}: {self.title}"

