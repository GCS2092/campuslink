"""
Serializers for payments app.
"""
from rest_framework import serializers
from .models import Payment, Ticket
from users.serializers import UserSerializer
from events.serializers import EventSerializer


class PaymentSerializer(serializers.ModelSerializer):
    """Serializer for Payment model."""
    user = UserSerializer(read_only=True)
    event = EventSerializer(read_only=True)
    event_id = serializers.UUIDField(write_only=True)
    
    class Meta:
        model = Payment
        fields = [
            'id', 'user', 'event', 'event_id', 'amount', 'commission', 'net_amount',
            'payment_method', 'status', 'transaction_id', 'stripe_payment_intent_id',
            'paypal_order_id', 'created_at', 'completed_at', 'refunded_at'
        ]
        read_only_fields = [
            'id', 'user', 'transaction_id', 'status', 'created_at',
            'completed_at', 'refunded_at', 'commission', 'net_amount'
        ]


class TicketSerializer(serializers.ModelSerializer):
    """Serializer for Ticket model."""
    payment = PaymentSerializer(read_only=True)
    user = UserSerializer(read_only=True)
    event = EventSerializer(read_only=True)
    
    class Meta:
        model = Ticket
        fields = [
            'id', 'payment', 'user', 'event', 'ticket_code', 'qr_code_url',
            'is_used', 'used_at', 'created_at'
        ]
        read_only_fields = ['id', 'ticket_code', 'created_at', 'used_at']

