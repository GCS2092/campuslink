"""
Tests for custom exception handler.
"""
from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from users.models import User


class ExceptionHandlerTestCase(TestCase):
    """Test custom exception handler."""
    
    def setUp(self):
        self.client = APIClient()
    
    def test_404_error_format(self):
        """Test that 404 errors have consistent format."""
        response = self.client.get('/api/events/99999999-9999-9999-9999-999999999999/')
        
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', response.data)
        self.assertIn('status_code', response.data['error'])
        self.assertIn('message', response.data['error'])
        self.assertIn('timestamp', response.data['error'])
    
    def test_400_error_format(self):
        """Test that 400 errors have consistent format."""
        # Try to register with invalid data
        response = self.client.post('/api/auth/register/', {
            'email': 'invalid-email',  # Invalid email
            'username': 'test',
            'password': 'test123',
        })
        
        self.assertEqual(response.status_code, 400)
        self.assertIn('error', response.data)
        self.assertIn('status_code', response.data['error'])
        self.assertIn('timestamp', response.data['error'])
    
    def test_401_error_format(self):
        """Test that 401 errors have consistent format."""
        # Try to access protected endpoint without auth
        response = self.client.get('/api/auth/profile/')
        
        self.assertEqual(response.status_code, 401)
        self.assertIn('error', response.data)
        self.assertIn('status_code', response.data['error'])

