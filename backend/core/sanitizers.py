"""
Input sanitization utilities to prevent XSS attacks.
"""
import bleach
from django.conf import settings

# Allowed HTML tags for rich text content
ALLOWED_TAGS = ['p', 'br', 'strong', 'em', 'u', 'a', 'ul', 'ol', 'li', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6']

# Allowed attributes for HTML tags
ALLOWED_ATTRIBUTES = {
    'a': ['href', 'title', 'target'],
    'img': ['src', 'alt', 'title'],
}

# Allowed protocols for links
ALLOWED_PROTOCOLS = ['http', 'https', 'mailto']


def sanitize_html(content):
    """
    Sanitize HTML content to prevent XSS attacks.
    
    Args:
        content: HTML string to sanitize
        
    Returns:
        Sanitized HTML string
    """
    if not content:
        return ''
    
    return bleach.clean(
        content,
        tags=ALLOWED_TAGS,
        attributes=ALLOWED_ATTRIBUTES,
        protocols=ALLOWED_PROTOCOLS,
        strip=True
    )


def sanitize_text(content):
    """
    Sanitize text content by removing all HTML tags.
    
    Args:
        content: Text string that may contain HTML
        
    Returns:
        Plain text string with all HTML removed
    """
    if not content:
        return ''
    
    return bleach.clean(content, tags=[], strip=True)


def sanitize_url(url):
    """
    Sanitize URL to prevent XSS and malicious links.
    
    Args:
        url: URL string to sanitize
        
    Returns:
        Sanitized URL or empty string if invalid
    """
    if not url:
        return ''
    
    # Only allow http, https, and mailto protocols
    if not url.startswith(('http://', 'https://', 'mailto:')):
        return ''
    
    # Clean the URL
    cleaned = bleach.clean(url, tags=[], strip=True)
    
    return cleaned

