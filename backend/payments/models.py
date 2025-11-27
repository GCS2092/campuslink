"""
Payment and ticket models for CampusLink.
"""
import uuid
import secrets
from django.db import models
from django.utils import timezone
from users.models import User
from events.models import Event


class Payment(models.Model):
    """Payment model for event tickets."""
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('completed', 'Complété'),
        ('failed', 'Échoué'),
        ('refunded', 'Remboursé'),
        ('cancelled', 'Annulé'),
    ]
    
    PAYMENT_METHOD_CHOICES = [
        ('stripe', 'Stripe'),
        ('paypal', 'PayPal'),
        ('mobile_money', 'Mobile Money'),
        ('bank_transfer', 'Virement Bancaire'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payments', db_index=True)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='payments', db_index=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    commission = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)  # 5-10% commission
    net_amount = models.DecimalField(max_digits=10, decimal_places=2)  # Amount after commission
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHOD_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True)
    transaction_id = models.CharField(max_length=255, unique=True, db_index=True)
    stripe_payment_intent_id = models.CharField(max_length=255, blank=True)
    paypal_order_id = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    refunded_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'payments_payment'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['event']),
            models.Index(fields=['status']),
            models.Index(fields=['transaction_id']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"Payment {self.transaction_id} - {self.amount} FCFA"
    
    def save(self, *args, **kwargs):
        """Generate transaction ID if not set."""
        if not self.transaction_id:
            self.transaction_id = f"TXN{secrets.token_hex(8).upper()}"
        super().save(*args, **kwargs)


class Ticket(models.Model):
    """Ticket model for event participation."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    payment = models.OneToOneField(Payment, on_delete=models.CASCADE, related_name='ticket', db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tickets', db_index=True)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='tickets', db_index=True)
    ticket_code = models.CharField(max_length=50, unique=True, db_index=True)
    qr_code_url = models.URLField(max_length=500, blank=True)
    is_used = models.BooleanField(default=False)
    used_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'payments_ticket'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['event']),
            models.Index(fields=['ticket_code']),
            models.Index(fields=['is_used']),
            models.Index(fields=['payment']),
        ]
    
    def __str__(self):
        return f"Ticket {self.ticket_code} for {self.event.title}"
    
    def save(self, *args, **kwargs):
        """Generate ticket code if not set."""
        if not self.ticket_code:
            # Generate unique ticket code: EVENT-XXXX-YYYY
            event_prefix = self.event.title[:4].upper().replace(' ', '')
            self.ticket_code = f"{event_prefix}-{secrets.token_hex(4).upper()}-{secrets.token_hex(4).upper()}"
        super().save(*args, **kwargs)
