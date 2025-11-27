"""
Tests for password validation.
"""
from django.test import TestCase
from django.core.exceptions import ValidationError
from users.validators import validate_password_strength


class PasswordValidationTestCase(TestCase):
    """Test password strength validation."""
    
    def test_valid_password(self):
        """Test that a valid password passes validation."""
        try:
            validate_password_strength('Test123!')
        except ValidationError:
            self.fail("Valid password should not raise ValidationError")
    
    def test_password_too_short(self):
        """Test that short passwords are rejected."""
        with self.assertRaises(ValidationError) as context:
            validate_password_strength('Test1!')
        
        self.assertIn('8 caractères', str(context.exception))
    
    def test_password_no_uppercase(self):
        """Test that passwords without uppercase are rejected."""
        with self.assertRaises(ValidationError) as context:
            validate_password_strength('test123!')
        
        self.assertIn('majuscule', str(context.exception))
    
    def test_password_no_lowercase(self):
        """Test that passwords without lowercase are rejected."""
        with self.assertRaises(ValidationError) as context:
            validate_password_strength('TEST123!')
        
        self.assertIn('minuscule', str(context.exception))
    
    def test_password_no_digit(self):
        """Test that passwords without digits are rejected."""
        with self.assertRaises(ValidationError) as context:
            validate_password_strength('TestPass!')
        
        self.assertIn('chiffre', str(context.exception))
    
    def test_password_no_special_char(self):
        """Test that passwords without special characters are rejected."""
        with self.assertRaises(ValidationError) as context:
            validate_password_strength('Test1234')
        
        self.assertIn('caractère spécial', str(context.exception))

