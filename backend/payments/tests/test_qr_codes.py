"""
Tests for QR code generation.
"""
from django.test import TestCase
from django.utils import timezone
from datetime import timedelta
from users.models import User
from events.models import Event, Category
from payments.models import Payment, Ticket
from payments.tasks import generate_ticket_qr_code


class QRCodeTestCase(TestCase):
    """Test QR code generation for tickets."""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='organizer@esmt.sn',
            username='organizer',
            password='Test123!',
            phone_number='+221771234567',
            is_verified=True
        )
        
        self.category = Category.objects.create(
            name='Test Category',
            slug='test-category'
        )
        
        self.event = Event.objects.create(
            title='Test Event',
            description='Test Description',
            organizer=self.user,
            category=self.category,
            start_date=timezone.now() + timedelta(days=7),
            location='Test Location',
            price=5000.00,
            is_free=False,
            status='published'
        )
    
    def test_qr_code_generation(self):
        """Test that QR code is generated for a ticket."""
        payment = Payment.objects.create(
            user=self.user,
            event=self.event,
            amount=5000.00,
            commission=250.00,
            net_amount=4750.00,
            payment_method='stripe',
            status='completed'
        )
        
        ticket = Ticket.objects.create(
            payment=payment,
            user=self.user,
            event=self.event
        )
        
        # Generate QR code
        result = generate_ticket_qr_code(str(ticket.id))
        
        # Refresh ticket
        ticket.refresh_from_db()
        
        # Check that QR code URL is set
        self.assertIsNotNone(ticket.qr_code_url)
        self.assertNotEqual(ticket.qr_code_url, '')
        
        # Check QR code data format
        if ticket.qr_code_url.startswith('data:image'):
            # Base64 format
            self.assertIn('base64', ticket.qr_code_url)
        else:
            # Cloudinary URL
            self.assertIn('http', ticket.qr_code_url)
    
    def test_ticket_validation(self):
        """Test ticket validation by code."""
        payment = Payment.objects.create(
            user=self.user,
            event=self.event,
            amount=5000.00,
            commission=250.00,
            net_amount=4750.00,
            payment_method='stripe',
            status='completed'
        )
        
        ticket = Ticket.objects.create(
            payment=payment,
            user=self.user,
            event=self.event
        )
        
        # Ticket should not be used initially
        self.assertFalse(ticket.is_used)
        
        # Validate ticket
        from payments.views import TicketViewSet
        from rest_framework.test import APIClient
        from rest_framework_simplejwt.tokens import RefreshToken
        
        client = APIClient()
        refresh = RefreshToken.for_user(self.user)
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        
        response = client.post('/api/tickets/validate/', {
            'ticket_code': ticket.ticket_code,
            'event_id': str(self.event.id)
        })
        
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.data['valid'])
        
        # Refresh ticket
        ticket.refresh_from_db()
        self.assertTrue(ticket.is_used)
        self.assertIsNotNone(ticket.used_at)

