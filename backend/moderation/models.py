"""
Moderation models for CampusLink.
"""
import uuid
from django.db import models
from django.utils import timezone
from users.models import User


class Report(models.Model):
    """Content report."""
    
    REASON_CHOICES = [
        ('spam', 'Spam'),
        ('harassment', 'Harcèlement'),
        ('inappropriate', 'Contenu inapproprié'),
        ('fake', 'Faux'),
        ('other', 'Autre'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('reviewed', 'Examiné'),
        ('resolved', 'Résolu'),
        ('dismissed', 'Rejeté'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    reporter = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reports_made', db_index=True)
    content_type = models.CharField(max_length=50, db_index=True)  # 'event', 'post', 'user', etc.
    content_id = models.UUIDField(db_index=True)
    reason = models.CharField(max_length=50, choices=REASON_CHOICES)
    description = models.TextField(blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True)
    reviewed_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reports_reviewed'
    )
    reviewed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    
    class Meta:
        db_table = 'moderation_report'
        indexes = [
            models.Index(fields=['reporter']),
            models.Index(fields=['content_type', 'content_id']),
            models.Index(fields=['status']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"Report: {self.content_type} #{self.content_id} by {self.reporter.username}"


class AuditLog(models.Model):
    """Audit log for all user actions."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='audit_logs', db_index=True)
    action_type = models.CharField(max_length=50, db_index=True)
    resource_type = models.CharField(max_length=50, blank=True)
    resource_id = models.UUIDField(null=True, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    details = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    
    class Meta:
        db_table = 'moderation_auditlog'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['action_type']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"{self.action_type} by {self.user.username if self.user else 'Anonymous'}"

