"""
Tests for input sanitization.
"""
from django.test import TestCase
from core.sanitizers import sanitize_html, sanitize_text, sanitize_url


class SanitizerTestCase(TestCase):
    """Test input sanitization functions."""
    
    def test_sanitize_html_removes_script(self):
        """Test that script tags are removed."""
        malicious = '<script>alert("XSS")</script><p>Safe content</p>'
        cleaned = sanitize_html(malicious)
        self.assertNotIn('<script>', cleaned)
        self.assertIn('<p>Safe content</p>', cleaned)
    
    def test_sanitize_html_allows_safe_tags(self):
        """Test that safe HTML tags are preserved."""
        content = '<p>Paragraph</p><strong>Bold</strong><em>Italic</em>'
        cleaned = sanitize_html(content)
        self.assertIn('<p>', cleaned)
        self.assertIn('<strong>', cleaned)
        self.assertIn('<em>', cleaned)
    
    def test_sanitize_html_removes_dangerous_attributes(self):
        """Test that dangerous attributes are removed."""
        malicious = '<a href="javascript:alert(1)">Click</a>'
        cleaned = sanitize_html(malicious)
        # JavaScript protocol should be removed or link should be sanitized
        self.assertNotIn('javascript:', cleaned.lower())
    
    def test_sanitize_text_removes_all_html(self):
        """Test that sanitize_text removes all HTML."""
        content = '<p>Text</p><script>alert(1)</script>'
        cleaned = sanitize_text(content)
        self.assertNotIn('<', cleaned)
        self.assertNotIn('>', cleaned)
        self.assertIn('Text', cleaned)
    
    def test_sanitize_url_allows_http_https(self):
        """Test that sanitize_url allows http and https."""
        url1 = 'https://example.com'
        url2 = 'http://example.com'
        
        self.assertEqual(sanitize_url(url1), 'https://example.com')
        self.assertEqual(sanitize_url(url2), 'http://example.com')
    
    def test_sanitize_url_blocks_javascript(self):
        """Test that sanitize_url blocks javascript protocol."""
        malicious = 'javascript:alert(1)'
        cleaned = sanitize_url(malicious)
        self.assertEqual(cleaned, '')
    
    def test_sanitize_url_allows_mailto(self):
        """Test that sanitize_url allows mailto protocol."""
        url = 'mailto:test@example.com'
        self.assertEqual(sanitize_url(url), 'mailto:test@example.com')
    
    def test_sanitize_empty_strings(self):
        """Test that empty strings are handled correctly."""
        self.assertEqual(sanitize_html(''), '')
        self.assertEqual(sanitize_text(''), '')
        self.assertEqual(sanitize_url(''), '')
        self.assertEqual(sanitize_html(None), '')
        self.assertEqual(sanitize_text(None), '')
        self.assertEqual(sanitize_url(None), '')

