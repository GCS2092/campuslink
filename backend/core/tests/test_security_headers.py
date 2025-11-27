"""
Tests for security headers.
"""
from django.test import TestCase, Client


class SecurityHeadersTestCase(TestCase):
    """Test security headers are set correctly."""
    
    def setUp(self):
        self.client = Client()
    
    def test_security_headers_present(self):
        """Test that security headers are present in responses."""
        response = self.client.get('/api/')
        
        # Check X-Frame-Options
        self.assertEqual(response.get('X-Frame-Options'), 'DENY')
        
        # Check X-Content-Type-Options
        self.assertEqual(response.get('X-Content-Type-Options'), 'nosniff')
        
        # X-XSS-Protection may not be set in newer browsers, but check if present
        if 'X-XSS-Protection' in response:
            self.assertIn('1', response['X-XSS-Protection'])

