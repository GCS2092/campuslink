"""
Tests for security features (account lockout, etc.).
"""
from django.test import TestCase, override_settings
from django.core.cache import cache
from rest_framework.test import APIClient
from users.models import User
from users.security import (
    check_account_lockout, record_failed_login_attempt, 
    clear_login_attempts, MAX_LOGIN_ATTEMPTS
)


@override_settings(CACHES={
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    }
})
class SecurityTestCase(TestCase):
    """Test security features."""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='test@esmt.sn',
            username='testuser',
            password='Test123!',
            phone_number='+221771234567'
        )
        # Clear cache before each test
        try:
            cache.clear()
        except Exception:
            pass  # Ignore if cache is not available
    
    def test_record_failed_login_attempt(self):
        """Test recording failed login attempts."""
        email = 'test@esmt.sn'
        
        # Record attempts
        for i in range(3):
            record_failed_login_attempt(email)
        
        attempts_key = f'login_attempts:{email}'
        attempts = cache.get(attempts_key, 0)
        self.assertEqual(attempts, 3)
    
    def test_account_lockout_after_max_attempts(self):
        """Test that account is locked after max attempts."""
        email = 'test@esmt.sn'
        
        # Record max attempts
        for i in range(MAX_LOGIN_ATTEMPTS):
            record_failed_login_attempt(email)
        
        # Check lockout
        is_locked, remaining = check_account_lockout(email)
        self.assertTrue(is_locked)
        self.assertGreater(remaining, 0)
    
    def test_clear_login_attempts(self):
        """Test clearing login attempts."""
        email = 'test@esmt.sn'
        
        # Record some attempts
        record_failed_login_attempt(email)
        record_failed_login_attempt(email)
        
        # Clear attempts
        clear_login_attempts(email)
        
        # Check that attempts are cleared
        attempts_key = f'login_attempts:{email}'
        attempts = cache.get(attempts_key, 0)
        self.assertEqual(attempts, 0)
        
        # Check that account is not locked
        is_locked, _ = check_account_lockout(email)
        self.assertFalse(is_locked)
    
    def test_login_with_locked_account(self):
        """Test that login fails when account is locked."""
        email = 'test@esmt.sn'
        
        # Lock the account
        for i in range(MAX_LOGIN_ATTEMPTS):
            record_failed_login_attempt(email)
        
        # Try to login - should be locked before even checking password
        # We need to override throttling for this test
        from django.test import override_settings
        with override_settings(REST_FRAMEWORK={
            'DEFAULT_THROTTLE_RATES': {
                'anon': '100/hour',
                'user': '1000/hour',
                'login': '100/hour',  # Override for test
            }
        }):
            response = self.client.post('/api/auth/login/', {
                'email': email,
                'password': 'Test123!'
            })
            
            # Should be locked (423) or at least not successful
            self.assertIn(response.status_code, [423, 400, 401])
            if response.status_code == 423:
                self.assertIn('verrouillé', response.data['error']['message'])

