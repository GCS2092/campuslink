"""
Models for User app.
"""
import uuid
import base64
import hashlib
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.utils import timezone
from django.conf import settings
from cryptography.fernet import Fernet


class UserManager(BaseUserManager):
    """Custom user manager."""
    
    def create_user(self, email, username, password=None, **extra_fields):
        """Create and save a regular user."""
        if not email:
            raise ValueError('The Email field must be set')
        if not username:
            raise ValueError('The Username field must be set')
        
        email = self.normalize_email(email)
        user = self.model(email=email, username=username, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, email, username, password=None, **extra_fields):
        """Create and save a superuser."""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('is_verified', True)
        extra_fields.setdefault('verification_status', 'verified')
        extra_fields.setdefault('role', 'admin')
        
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
        ('university_admin', 'Administrateur d\'Université'),
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
        help_text='Admin who banned this user'
    )
    
    # University admin field
    managed_university = models.ForeignKey(
        'University',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='admins',
        help_text='Université gérée par cet administrateur (si role=university_admin)'
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
        ]
    
    def __str__(self):
        return self.username


class University(models.Model):
    """University/École model."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200, unique=True, db_index=True, help_text="Nom officiel de l'université")
    slug = models.SlugField(unique=True, db_index=True, help_text="Slug pour les URLs")
    short_name = models.CharField(max_length=50, blank=True, help_text="Nom court (ex: ESMT, UCAD)")
    email_domains = models.JSONField(default=list, help_text="Domaines email autorisés (ex: ['@esmt.sn', '@esmt.sn.dakar'])")
    
    # Image fields - Use CloudinaryField if available, otherwise use regular ImageField
    try:
        from cloudinary.models import CloudinaryField
        CLOUDINARY_AVAILABLE = True
    except ImportError:
        CLOUDINARY_AVAILABLE = False
        CloudinaryField = None
    
    if CLOUDINARY_AVAILABLE and CloudinaryField:
        logo = CloudinaryField('image', folder='campuslink/university_logos', null=True, blank=True, help_text="Logo de l'université")
        cover_image = CloudinaryField('image', folder='campuslink/university_covers', null=True, blank=True, help_text="Image de couverture de l'université")
    else:
        logo = models.ImageField(upload_to='university_logos/', null=True, blank=True, help_text="Logo de l'université")
        cover_image = models.ImageField(upload_to='university_covers/', null=True, blank=True, help_text="Image de couverture de l'université")
    
    # Legacy URL fields for migration
    logo_url_legacy = models.URLField(max_length=500, blank=True, help_text="Ancienne URL du logo (pour migration)")
    cover_image_url_legacy = models.URLField(max_length=500, blank=True, help_text="Ancienne URL de l'image de couverture (pour migration)")
    
    description = models.TextField(blank=True, help_text="Description de l'université")
    website = models.URLField(max_length=500, blank=True)
    address = models.TextField(blank=True, help_text="Adresse de l'université")
    phone = models.CharField(max_length=20, blank=True)
    is_active = models.BooleanField(default=True, db_index=True, help_text="Université active ou non")
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'users_university'
        ordering = ['name']
        verbose_name = 'Université'
        verbose_name_plural = 'Universités'
        indexes = [
            models.Index(fields=['name']),
            models.Index(fields=['slug']),
            models.Index(fields=['is_active']),
        ]
    
    def __str__(self):
        return self.name
    
    def get_admin(self):
        """Get the university admin user."""
        return self.admins.filter(role='university_admin', is_active=True).first()


class UniversitySettings(models.Model):
    """Settings/Configuration model for each university."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    university = models.OneToOneField(
        University,
        on_delete=models.CASCADE,
        related_name='settings',
        db_index=True,
        help_text="Université associée à ces paramètres"
    )
    
    # Registration and verification settings
    require_email_verification = models.BooleanField(
        default=True,
        help_text="Exiger la vérification de l'email lors de l'inscription"
    )
    require_phone_verification = models.BooleanField(
        default=False,
        help_text="Exiger la vérification du numéro de téléphone"
    )
    auto_verify_students = models.BooleanField(
        default=False,
        help_text="Vérifier automatiquement les étudiants lors de l'inscription"
    )
    require_admin_approval = models.BooleanField(
        default=True,
        help_text="Exiger l'approbation d'un administrateur pour activer les comptes"
    )
    
    # Content moderation settings
    moderate_posts = models.BooleanField(
        default=True,
        help_text="Modérer les posts avant publication"
    )
    moderate_events = models.BooleanField(
        default=False,
        help_text="Modérer les événements avant publication"
    )
    moderate_groups = models.BooleanField(
        default=False,
        help_text="Modérer les groupes avant publication"
    )
    
    # Group and event settings
    allow_student_groups = models.BooleanField(
        default=True,
        help_text="Permettre aux étudiants de créer des groupes"
    )
    allow_student_events = models.BooleanField(
        default=True,
        help_text="Permettre aux étudiants de créer des événements"
    )
    max_groups_per_student = models.IntegerField(
        default=5,
        help_text="Nombre maximum de groupes qu'un étudiant peut créer"
    )
    
    # Notification settings
    send_welcome_email = models.BooleanField(
        default=True,
        help_text="Envoyer un email de bienvenue aux nouveaux étudiants"
    )
    send_verification_email = models.BooleanField(
        default=True,
        help_text="Envoyer un email lors de la vérification du compte"
    )
    send_event_reminders = models.BooleanField(
        default=True,
        help_text="Envoyer des rappels pour les événements"
    )
    
    # Display settings
    show_phone_numbers = models.BooleanField(
        default=False,
        help_text="Afficher les numéros de téléphone dans les profils publics"
    )
    show_email_addresses = models.BooleanField(
        default=False,
        help_text="Afficher les adresses email dans les profils publics"
    )
    primary_color = models.CharField(
        max_length=7,
        default='#3B82F6',
        help_text="Couleur primaire de l'université (hex)"
    )
    secondary_color = models.CharField(
        max_length=7,
        default='#8B5CF6',
        help_text="Couleur secondaire de l'université (hex)"
    )
    custom_css = models.TextField(
        blank=True,
        help_text="CSS personnalisé pour l'université"
    )
    
    # Academic settings
    academic_year_start_month = models.IntegerField(
        choices=[(i, i) for i in range(1, 13)],
        default=9,
        help_text="Mois de début de l'année académique (1-12)"
    )
    academic_year_end_month = models.IntegerField(
        choices=[(i, i) for i in range(1, 13)],
        default=6,
        help_text="Mois de fin de l'année académique (1-12)"
    )
    
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'users_university_settings'
        verbose_name = "Paramètres d'Université"
        verbose_name_plural = "Paramètres d'Universités"
    
    def __str__(self):
        return f"Paramètres de {self.university.name}"


class Campus(models.Model):
    """Campus model for universities with multiple locations."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    university = models.ForeignKey(
        University,
        on_delete=models.CASCADE,
        related_name='campuses',
        db_index=True,
        help_text="Université à laquelle appartient ce campus"
    )
    name = models.CharField(max_length=200, db_index=True, help_text="Nom du campus (ex: Campus Principal, Campus Dakar)")
    slug = models.SlugField(db_index=True, help_text="Slug pour les URLs")
    address = models.TextField(blank=True, help_text="Adresse complète du campus")
    city = models.CharField(max_length=100, blank=True, db_index=True, help_text="Ville du campus")
    country = models.CharField(max_length=100, default='Sénégal', help_text="Pays du campus")
    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(blank=True, help_text="Email de contact du campus")
    
    # Image field - Use CloudinaryField if available, otherwise use regular ImageField
    try:
        from cloudinary.models import CloudinaryField
        CLOUDINARY_AVAILABLE = True
    except ImportError:
        CLOUDINARY_AVAILABLE = False
        CloudinaryField = None
    
    if CLOUDINARY_AVAILABLE and CloudinaryField:
        image = CloudinaryField('image', folder='campuslink/campus_images', null=True, blank=True, help_text="Image du campus")
    else:
        image = models.ImageField(upload_to='campus_images/', null=True, blank=True, help_text="Image du campus")
    
    is_main = models.BooleanField(default=False, db_index=True, help_text="Campus principal de l'université")
    is_active = models.BooleanField(default=True, db_index=True, help_text="Campus actif ou non")
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True, help_text="Latitude GPS")
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True, help_text="Longitude GPS")
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'users_campus'
        verbose_name = 'Campus'
        verbose_name_plural = 'Campus'
        ordering = ['-is_main', 'name']
        unique_together = ['university', 'slug']
        indexes = [
            models.Index(fields=['university']),
            models.Index(fields=['name']),
            models.Index(fields=['city']),
            models.Index(fields=['is_main']),
            models.Index(fields=['is_active']),
        ]

    def __str__(self):
        return f"{self.university.short_name or self.university.name} - {self.name}"


class Department(models.Model):
    """Department/Field of Study model for universities."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    university = models.ForeignKey(
        University,
        on_delete=models.CASCADE,
        related_name='departments',
        db_index=True,
        help_text="Université à laquelle appartient ce département"
    )
    name = models.CharField(max_length=200, db_index=True, help_text="Nom du département (ex: Informatique, Génie Civil)")
    slug = models.SlugField(db_index=True, help_text="Slug pour les URLs")
    code = models.CharField(max_length=50, blank=True, help_text="Code du département (ex: INFO, GC)")
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True, db_index=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'users_department'
        ordering = ['name']
        verbose_name = 'Département'
        verbose_name_plural = 'Départements'
        unique_together = ['university', 'code']  # Code unique par université
        indexes = [
            models.Index(fields=['university']),
            models.Index(fields=['name']),
            models.Index(fields=['code']),
            models.Index(fields=['is_active']),
        ]

    def save(self, *args, **kwargs):
        """Auto-generate slug from name if not provided."""
        if not self.slug:
            from django.utils.text import slugify
            base_slug = slugify(self.name)
            self.slug = base_slug
            # Ensure uniqueness within university
            counter = 1
            while Department.objects.filter(university=self.university, slug=self.slug).exclude(id=self.id).exists():
                self.slug = f"{base_slug}-{counter}"
                counter += 1
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.university.short_name or self.university.name} - {self.name}"


class AcademicYear(models.Model):
    """Academic year/promotion model."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    university = models.ForeignKey(
        University,
        on_delete=models.CASCADE,
        related_name='academic_years',
        db_index=True,
        help_text="Université à laquelle appartient cette année académique"
    )
    year = models.CharField(max_length=20, db_index=True, help_text="Année académique (ex: 2024-2025)")
    start_date = models.DateField(help_text="Date de début de l'année académique")
    end_date = models.DateField(help_text="Date de fin de l'année académique")
    is_current = models.BooleanField(default=False, db_index=True, help_text="Année académique actuelle")
    is_active = models.BooleanField(default=True, db_index=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'users_academic_year'
        ordering = ['-start_date']
        verbose_name = 'Année Académique'
        verbose_name_plural = 'Années Académiques'
        unique_together = ['university', 'year']
        indexes = [
            models.Index(fields=['university']),
            models.Index(fields=['year']),
            models.Index(fields=['is_current']),
            models.Index(fields=['is_active']),
        ]

    def __str__(self):
        return f"{self.university.short_name or self.university.name} - {self.year}"


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
    university = models.ForeignKey(
        University,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='students',
        db_index=True,
        help_text="Université de l'étudiant"
    )
    university_name_legacy = models.CharField(max_length=200, blank=True, help_text="Ancien nom (pour migration)")
    campus = models.ForeignKey(
        Campus,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='students',
        db_index=True,
        help_text="Campus de l'étudiant"
    )
    campus_name_legacy = models.CharField(max_length=200, blank=True, help_text="Ancien nom de campus (pour migration)")
    department = models.ForeignKey(
        Department,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='students',
        help_text="Département/Filière de l'étudiant"
    )
    field_of_study = models.CharField(max_length=200, blank=True, help_text="Ancien champ (pour migration)")
    field_of_study_legacy = models.CharField(max_length=200, blank=True, help_text="Ancien nom de filière (pour migration)")
    academic_year_obj = models.ForeignKey(
        AcademicYear,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='students',
        db_index=True,
        help_text="Année académique de l'étudiant"
    )
    academic_year = models.CharField(max_length=50, blank=True, help_text="Ancien champ (pour migration)")
    academic_year_legacy = models.CharField(max_length=50, blank=True, help_text="Ancienne année académique (pour migration)")
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
    """Friendship model."""
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('accepted', 'Accepté'),
        ('rejected', 'Rejeté'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    from_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='friendship_requests_sent')
    to_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='friendship_requests_received')
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
    """Follow model."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    follower = models.ForeignKey(User, on_delete=models.CASCADE, related_name='following')
    following = models.ForeignKey(User, on_delete=models.CASCADE, related_name='followers')
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
