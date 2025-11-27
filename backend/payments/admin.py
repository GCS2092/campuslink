"""
Admin configuration for payments app.
"""
from django.contrib import admin
from .models import Payment, Ticket


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    """Admin interface for Payment model."""
    list_display = ['transaction_id', 'user', 'event', 'amount', 'status', 'payment_method', 'created_at']
    list_filter = ['status', 'payment_method', 'created_at']
    search_fields = ['transaction_id', 'user__email', 'user__username', 'event__title']
    readonly_fields = ['transaction_id', 'created_at', 'completed_at', 'refunded_at']
    date_hierarchy = 'created_at'


@admin.register(Ticket)
class TicketAdmin(admin.ModelAdmin):
    """Admin interface for Ticket model."""
    list_display = ['ticket_code', 'user', 'event', 'is_used', 'created_at']
    list_filter = ['is_used', 'created_at']
    search_fields = ['ticket_code', 'user__email', 'user__username', 'event__title']
    readonly_fields = ['ticket_code', 'created_at', 'used_at']
    date_hierarchy = 'created_at'
