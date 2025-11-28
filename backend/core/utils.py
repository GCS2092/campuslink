"""
Utility functions for CampusLink.
"""
import re
from django.conf import settings


def is_university_email(email):
    """
    Check if email is from a valid university domain.
    Supports exact matches and subdomain matching (e.g., @dakar.esmt.sn matches @esmt.sn).
    """
    if not email or '@' not in email:
        return False
    
    email_domain = '@' + email.split('@')[1] if '@' in email else ''
    
    # Check exact matches first
    for domain in settings.UNIVERSITY_EMAIL_DOMAINS:
        if email_domain == domain:
            return True
    
    # Check subdomain matches (e.g., @dakar.esmt.sn should match @esmt.sn)
    for domain in settings.UNIVERSITY_EMAIL_DOMAINS:
        if email_domain.endswith('.' + domain.lstrip('@')):
            return True
    
    # Also check against database universities (for dynamic domains)
    try:
        from users.models import University
        universities = University.objects.filter(is_active=True)
        for uni in universities:
            if email_domain in (uni.email_domains or []):
                return True
            # Check subdomain matches
            for uni_domain in (uni.email_domains or []):
                if email_domain.endswith('.' + uni_domain.lstrip('@')):
                    return True
    except Exception:
        pass  # If database not ready, fallback to settings
    
    return False


def get_university_from_email(email):
    """
    Get University object from email domain.
    Returns University instance or None.
    """
    if not email or '@' not in email:
        return None
    
    email_domain = '@' + email.split('@')[1] if '@' in email else ''
    
    try:
        from users.models import University
        universities = University.objects.filter(is_active=True)
        for uni in universities:
            if email_domain in (uni.email_domains or []):
                return uni
            # Check subdomain matches
            for uni_domain in (uni.email_domains or []):
                if email_domain.endswith('.' + uni_domain.lstrip('@')):
                    return uni
    except Exception:
        pass
    
    return None


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

