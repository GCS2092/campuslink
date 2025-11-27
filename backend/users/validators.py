"""
Validators for User app.
"""
import re
from django.core.exceptions import ValidationError
from django.contrib.auth.password_validation import validate_password
from core.utils import is_university_email, is_valid_phone


def validate_university_email(email):
    """Validate that email is from a university domain."""
    if not is_university_email(email):
        raise ValidationError('Email must be from a valid university domain.')


def validate_phone_number(phone):
    """Validate phone number format."""
    if not is_valid_phone(phone):
        raise ValidationError('Phone number must be in format +221XXXXXXXXX.')


class PasswordStrengthValidator:
    """
    Validate password strength.
    Requirements:
    - Minimum 8 characters
    - At least one uppercase letter
    - At least one lowercase letter
    - At least one digit
    - At least one special character
    """
    def validate(self, password, user=None):
        """Validate password strength."""
        if len(password) < 8:
            raise ValidationError('Le mot de passe doit contenir au moins 8 caractères.')
        
        if not re.search(r'[A-Z]', password):
            raise ValidationError('Le mot de passe doit contenir au moins une majuscule.')
        
        if not re.search(r'[a-z]', password):
            raise ValidationError('Le mot de passe doit contenir au moins une minuscule.')
        
        if not re.search(r'\d', password):
            raise ValidationError('Le mot de passe doit contenir au moins un chiffre.')
        
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            raise ValidationError('Le mot de passe doit contenir au moins un caractère spécial (!@#$%^&*(),.?":{}|<>)')
    
    def get_help_text(self):
        """Return help text for password requirements."""
        return 'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre et un caractère spécial.'


# Keep function for backward compatibility in tests
def validate_password_strength(password):
    """Validate password strength (function version for tests)."""
    validator = PasswordStrengthValidator()
    validator.validate(password)

