"""
User models for CampusLink.
"""
import uuid
import base64
import hashlib
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone
from cryptography.fernet import Fernet
from django.conf import settings


class UserManager(BaseUserManager):
    """Custom user manager."""
    
    def create_user(self, email, username, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        if not username:
            raise ValueError('The Username field must be set')
        
        # Par défaut, les nouveaux utilisateurs sont désactivés
        extra_fields.setdefault('is_active', False)
        
        email = self.normalize_email(email)
        user = self.model(email=email, username=username, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, email, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_verified', True)
        extra_fields.setdefault('verification_status', 'verified')
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')
        
        return self.create_user(email, username, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Custom user model."""
    
    ROLE_CHOICES = [
        ('student', 'Étudiant'),
        ('class_leader', 'Responsable de Classe'),
        ('association', 'Association/Club'),
        ('sponsor', 'Partenaire/Sponsor'),
        ('admin', 'Administrateur'),
    ]
    
    VERIFICATION_STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('verified', 'Vérifié'),
        ('rejected', 'Rejeté'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True, db_index=True)
    username = models.CharField(max_length=150, unique=True, db_index=True)
    first_name = models.CharField(max_length=100, blank=True)
    last_name = models.CharField(max_length=100, blank=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='student')
    phone_number = models.CharField(max_length=20, db_index=True)
    phone_verified = models.BooleanField(default=False)
    is_active = models.BooleanField(default=False, db_index=True)  # Désactivé par défaut jusqu'à validation
    is_staff = models.BooleanField(default=False)
    is_verified = models.BooleanField(default=False, db_index=True)
    verification_status = models.CharField(
        max_length=20,
        choices=VERIFICATION_STATUS_CHOICES,
        default='pending',
        db_index=True
    )
    last_activity = models.DateTimeField(null=True, blank=True, db_index=True)
    date_joined = models.DateTimeField(default=timezone.now)
    last_login = models.DateTimeField(null=True, blank=True)
    
    # Banning fields
    is_banned = models.BooleanField(default=False, db_index=True)
    banned_at = models.DateTimeField(null=True, blank=True)
    banned_until = models.DateTimeField(null=True, blank=True, help_text="For temporary bans")
    ban_reason = models.TextField(blank=True, help_text="Reason for ban")
    banned_by = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='users_banned',
        help_text="Admin who banned this user"
    )
    
    objects = UserManager()
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']
    
    class Meta:
        db_table = 'users_user'
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['username']),
            models.Index(fields=['phone_number']),
            models.Index(fields=['verification_status']),
            models.Index(fields=['is_verified']),
            models.Index(fields=['is_active']),
            models.Index(fields=['last_activity']),
            models.Index(fields=['role']),
        ]
    
    def __str__(self):
        return self.username
    
    def get_full_name(self):
        return f"{self.first_name} {self.last_name}".strip() or self.username


class Profile(models.Model):
    """User profile with additional information."""
    
    VERIFICATION_METHOD_CHOICES = [
        ('email', 'Email'),
        ('phone', 'Téléphone'),
        ('matricule', 'Matricule'),
        ('manual', 'Manuel'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile', db_index=True)
    university = models.CharField(max_length=200, blank=True, db_index=True)
    campus = models.CharField(max_length=200, blank=True)
    field_of_study = models.CharField(max_length=200, blank=True)
    academic_year = models.CharField(max_length=50, blank=True)
    bio = models.TextField(blank=True)
    profile_picture = models.URLField(max_length=500, blank=True)
    cover_picture = models.URLField(max_length=500, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    interests = models.JSONField(default=list, blank=True)
    website = models.URLField(max_length=500, blank=True)
    facebook = models.CharField(max_length=100, blank=True)
    instagram = models.CharField(max_length=100, blank=True)
    twitter = models.CharField(max_length=100, blank=True)
    followers_count = models.IntegerField(default=0)
    following_count = models.IntegerField(default=0)
    friends_count = models.IntegerField(default=0)
    university_email = models.EmailField(blank=True, db_index=True)
    email_verified = models.BooleanField(default=False, db_index=True)
    student_id = models.CharField(max_length=500, blank=True, db_index=True)  # Encrypted (needs more space for encrypted data)
    verification_method = models.CharField(
        max_length=20,
        choices=VERIFICATION_METHOD_CHOICES,
        blank=True
    )
    reputation_score = models.IntegerField(default=0, db_index=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'users_profile'
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['university']),
            models.Index(fields=['student_id']),
            models.Index(fields=['email_verified']),
            models.Index(fields=['reputation_score']),
        ]
    
    def __str__(self):
        return f"{self.user.username}'s Profile"
    
    def encrypt_student_id(self, student_id):
        """Encrypt student ID before storing using a stable key."""
        if not student_id:
            return ''
        
        # Generate a stable key from SECRET_KEY
        # In production, use a dedicated encryption key from secrets manager
        key = base64.urlsafe_b64encode(
            hashlib.sha256(settings.SECRET_KEY.encode()).digest()
        )
        f = Fernet(key)
        try:
            return f.encrypt(student_id.encode()).decode()
        except Exception:
            # If encryption fails, return empty string
            return ''
    
    def decrypt_student_id(self):
        """Decrypt student ID."""
        if not self.student_id:
            return ''
        
        try:
            # Generate the same key used for encryption
            key = base64.urlsafe_b64encode(
                hashlib.sha256(settings.SECRET_KEY.encode()).digest()
            )
            f = Fernet(key)
            return f.decrypt(self.student_id.encode()).decode()
        except Exception:
            # If decryption fails, return empty string
            return ''


class Friendship(models.Model):
    """Friendship relationship between users."""
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('accepted', 'Accepté'),
        ('rejected', 'Rejeté'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    from_user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='friendship_requests_sent',
        db_index=True
    )
    to_user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='friendship_requests_received',
        db_index=True
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'users_friendship'
        unique_together = ['from_user', 'to_user']
        indexes = [
            models.Index(fields=['from_user']),
            models.Index(fields=['to_user']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return f"{self.from_user.username} -> {self.to_user.username} ({self.status})"


class Follow(models.Model):
    """Follow relationship (one-way)."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    follower = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='following',
        db_index=True
    )
    following = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='followers',
        db_index=True
    )
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'users_follow'
        unique_together = ['follower', 'following']
        indexes = [
            models.Index(fields=['follower']),
            models.Index(fields=['following']),
        ]
    
    def __str__(self):
        return f"{self.follower.username} follows {self.following.username}"

