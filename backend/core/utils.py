"""
Utility functions for CampusLink.
"""
import re
from django.conf import settings


def is_university_email(email):
    """
    Check if email is from a valid university domain.
    """
    if not email:
        return False
    
    for domain in settings.UNIVERSITY_EMAIL_DOMAINS:
        if email.endswith(domain):
            return True
    return False


def is_valid_phone(phone):
    """
    Validate phone number format (+221XXXXXXXXX).
    """
    if not phone:
        return False
    
    pattern = r'^\+221\d{9}$'
    return bool(re.match(pattern, phone))


def format_phone(phone):
    """
    Format phone number to standard format.
    """
    # Remove all non-digit characters except +
    cleaned = re.sub(r'[^\d+]', '', phone)
    
    # If starts with 0, replace with +221
    if cleaned.startswith('0'):
        cleaned = '+221' + cleaned[1:]
    # If starts with 221, add +
    elif cleaned.startswith('221'):
        cleaned = '+' + cleaned
    # If doesn't start with +, add +221
    elif not cleaned.startswith('+'):
        cleaned = '+221' + cleaned
    
    return cleaned

