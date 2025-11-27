"""
Views for payments app.
"""
from django.utils import timezone
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Payment, Ticket
from .serializers import PaymentSerializer, TicketSerializer
from .tasks import generate_ticket_qr_code
from events.models import Event
from users.permissions import IsVerified


class PaymentViewSet(viewsets.ModelViewSet):
    """ViewSet for payments."""
    serializer_class = PaymentSerializer
    permission_classes = [IsAuthenticated, IsVerified]
    
    def get_queryset(self):
        """Return payments for the current user."""
        return Payment.objects.filter(user=self.request.user).select_related('event', 'user')
    
    def perform_create(self, serializer):
        """Create payment for an event."""
        event_id = self.request.data.get('event_id')
        event = get_object_or_404(Event, id=event_id, status='published')
        
        # Calculate commission (5-10% based on event price)
        amount = float(event.price)
        commission_rate = 0.10 if amount >= 5000 else 0.05  # 10% for >= 5000 FCFA, 5% otherwise
        commission = amount * commission_rate
        net_amount = amount - commission
        
        payment = serializer.save(
            user=self.request.user,
            event=event,
            amount=amount,
            commission=commission,
            net_amount=net_amount,
            status='pending'
        )
        
        # Create ticket automatically
        ticket = Ticket.objects.create(
            payment=payment,
            user=self.request.user,
            event=event
        )
        
        # Generate QR code asynchronously
        generate_ticket_qr_code.delay(str(ticket.id))
    
    @action(detail=True, methods=['post'])
    def confirm(self, request, pk=None):
        """Confirm payment (webhook or manual confirmation)."""
        payment = self.get_object()
        
        if payment.status != 'pending':
            return Response(
                {'error': 'Payment is not in pending status.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        payment.status = 'completed'
        payment.completed_at = timezone.now()
        payment.save()
        
        return Response({'message': 'Payment confirmed.'}, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'])
    def refund(self, request, pk=None):
        """Refund a payment."""
        payment = self.get_object()
        
        if payment.status != 'completed':
            return Response(
                {'error': 'Only completed payments can be refunded.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        payment.status = 'refunded'
        payment.refunded_at = timezone.now()
        payment.save()
        
        # Mark ticket as unused
        if hasattr(payment, 'ticket'):
            payment.ticket.is_used = False
            payment.ticket.used_at = None
            payment.ticket.save()
        
        return Response({'message': 'Payment refunded.'}, status=status.HTTP_200_OK)


class TicketViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for tickets (read-only)."""
    serializer_class = TicketSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return tickets for the current user."""
        return Ticket.objects.filter(user=self.request.user).select_related('event', 'user', 'payment')
    
    @action(detail=True, methods=['post'])
    def use(self, request, pk=None):
        """Mark ticket as used."""
        ticket = self.get_object()
        
        if ticket.is_used:
            return Response(
                {'error': 'Ticket already used.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        ticket.is_used = True
        ticket.used_at = timezone.now()
        ticket.save()
        
        return Response({'message': 'Ticket marked as used.'}, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def validate_by_code(self, request):
        """
        Validate ticket by scanning QR code.
        Only event organizers can validate tickets.
        """
        ticket_code = request.data.get('ticket_code')
        event_id = request.data.get('event_id')
        
        if not ticket_code or not event_id:
            return Response(
                {'error': 'ticket_code and event_id are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            ticket = Ticket.objects.select_related('event', 'user').get(
                ticket_code=ticket_code,
                event_id=event_id
            )
            
            # Check if user is the organizer
            if ticket.event.organizer != request.user:
                return Response(
                    {'error': 'Only event organizer can validate tickets.'},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            if ticket.is_used:
                return Response({
                    'valid': False,
                    'message': 'Ticket already used.',
                    'used_at': ticket.used_at.isoformat() if ticket.used_at else None
                }, status=status.HTTP_200_OK)
            
            # Mark as used
            ticket.is_used = True
            ticket.used_at = timezone.now()
            ticket.save()
            
            return Response({
                'valid': True,
                'message': 'Ticket validated successfully.',
                'ticket': TicketSerializer(ticket).data
            }, status=status.HTTP_200_OK)
            
        except Ticket.DoesNotExist:
            return Response(
                {'error': 'Invalid ticket code or event ID.'},
                status=status.HTTP_404_NOT_FOUND
            )
