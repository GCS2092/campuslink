"""
Tests for student ID encryption/decryption.
"""
from django.test import TestCase
from users.models import User, Profile


class EncryptionTestCase(TestCase):
    """Test encryption and decryption of student IDs."""
    
    def setUp(self):
        """Create a test user and profile."""
        self.user = User.objects.create_user(
            email='test@esmt.sn',
            username='testuser',
            password='testpass123',
            phone_number='+221771234567'
        )
        self.profile = self.user.profile
    
    def test_encrypt_decrypt_student_id(self):
        """Test that encryption and decryption work correctly."""
        original_id = 'ESMT2024001'
        
        # Encrypt
        encrypted = self.profile.encrypt_student_id(original_id)
        self.assertNotEqual(encrypted, original_id)
        self.assertNotEqual(encrypted, '')
        
        # Save encrypted ID
        self.profile.student_id = encrypted
        self.profile.save()
        
        # Decrypt
        decrypted = self.profile.decrypt_student_id()
        self.assertEqual(decrypted, original_id)
    
    def test_encrypt_empty_string(self):
        """Test encryption of empty string."""
        encrypted = self.profile.encrypt_student_id('')
        self.assertEqual(encrypted, '')
    
    def test_decrypt_empty_string(self):
        """Test decryption when student_id is empty."""
        self.profile.student_id = ''
        self.profile.save()
        decrypted = self.profile.decrypt_student_id()
        self.assertEqual(decrypted, '')
    
    def test_encryption_decryption_works(self):
        """Test that encryption and decryption work correctly for same input."""
        original_id = 'ESMT2024001'
        
        # Encrypt twice (Fernet uses random IV, so encrypted values will differ)
        encrypted1 = self.profile.encrypt_student_id(original_id)
        encrypted2 = self.profile.encrypt_student_id(original_id)
        
        # Encrypted values will be different (due to random IV)
        # But both should decrypt to the same value
        self.profile.student_id = encrypted1
        decrypted1 = self.profile.decrypt_student_id()
        
        self.profile.student_id = encrypted2
        decrypted2 = self.profile.decrypt_student_id()
        
        # Both should decrypt to the original value
        self.assertEqual(decrypted1, original_id)
        self.assertEqual(decrypted2, original_id)
        self.assertEqual(decrypted1, decrypted2)

