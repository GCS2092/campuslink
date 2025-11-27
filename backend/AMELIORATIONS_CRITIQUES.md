# 🔧 AMÉLIORATIONS CRITIQUES À IMPLÉMENTER

## 🔴 1. CORRECTION DU CHIFFREMENT DES MATRICULES

### Problème Actuel
```python
# users/models.py - LIGNE 154-167
def encrypt_student_id(self, student_id):
    f = Fernet(Fernet.generate_key())  # ❌ Génère nouvelle clé à chaque fois !
    return f.encrypt(student_id.encode()).decode()
```

### Solution
```python
# users/models.py
from cryptography.fernet import Fernet
from django.conf import settings
import base64
import hashlib

class Profile(models.Model):
    # ... autres champs ...
    
    def encrypt_student_id(self, student_id):
        """Encrypt student ID before storing."""
        if not student_id:
            return ''
        
        # Générer une clé stable à partir de SECRET_KEY
        key = base64.urlsafe_b64encode(
            hashlib.sha256(settings.SECRET_KEY.encode()).digest()
        )
        f = Fernet(key)
        return f.encrypt(student_id.encode()).decode()
    
    def decrypt_student_id(self):
        """Decrypt student ID."""
        if not self.student_id:
            return ''
        
        try:
            key = base64.urlsafe_b64encode(
                hashlib.sha256(settings.SECRET_KEY.encode()).digest()
            )
            f = Fernet(key)
            return f.decrypt(self.student_id.encode()).decode()
        except Exception:
            return ''  # En cas d'erreur, retourner vide
```

**⚠️ IMPORTANT** : En production, utiliser une clé de chiffrement dédiée stockée dans un gestionnaire de secrets (AWS Secrets Manager, HashiCorp Vault, etc.)

---

## 🔴 2. SYSTÈME DE LOGGING STRUCTURÉ

### Fichier à créer : `campuslink/logging_config.py`
```python
import logging
import logging.handlers
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'json': {
            '()': 'pythonjsonlogger.jsonlogger.JsonFormatter',
            'format': '%(asctime)s %(name)s %(levelname)s %(message)s %(pathname)s %(lineno)d',
        },
    },
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': BASE_DIR / 'logs' / 'campuslink.log',
            'maxBytes': 1024 * 1024 * 10,  # 10 MB
            'backupCount': 5,
            'formatter': 'verbose',
        },
        'error_file': {
            'level': 'ERROR',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': BASE_DIR / 'logs' / 'errors.log',
            'maxBytes': 1024 * 1024 * 10,
            'backupCount': 5,
            'formatter': 'verbose',
        },
        'security_file': {
            'level': 'WARNING',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': BASE_DIR / 'logs' / 'security.log',
            'maxBytes': 1024 * 1024 * 10,
            'backupCount': 10,
            'formatter': 'json',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file', 'console'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.security': {
            'handlers': ['security_file'],
            'level': 'WARNING',
            'propagate': False,
        },
        'users': {
            'handlers': ['file', 'error_file'],
            'level': 'INFO',
            'propagate': False,
        },
        'events': {
            'handlers': ['file', 'error_file'],
            'level': 'INFO',
            'propagate': False,
        },
    },
    'root': {
        'handlers': ['console', 'file'],
        'level': 'INFO',
    },
}
```

### Ajouter dans `settings.py` :
```python
from .logging_config import LOGGING
```

---

## 🔴 3. GESTION CENTRALISÉE DES EXCEPTIONS

### Améliorer `core/exceptions.py` :
```python
from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
import logging

logger = logging.getLogger(__name__)

def custom_exception_handler(exc, context):
    """
    Custom exception handler for consistent error responses.
    """
    # Appeler le handler par défaut de DRF
    response = exception_handler(exc, context)
    
    # Logger l'erreur
    logger.error(f"Exception: {exc}", exc_info=True, extra={'context': context})
    
    if response is not None:
        # Personnaliser la réponse d'erreur
        custom_response_data = {
            'error': {
                'status_code': response.status_code,
                'message': response.data.get('detail', 'An error occurred'),
                'details': response.data if isinstance(response.data, dict) else {'error': str(response.data)},
                'timestamp': timezone.now().isoformat(),
            }
        }
        response.data = custom_response_data
    
    # Gérer les exceptions non gérées par DRF
    else:
        logger.exception("Unhandled exception")
        return Response(
            {
                'error': {
                    'status_code': 500,
                    'message': 'Une erreur interne s\'est produite.',
                    'details': {},
                    'timestamp': timezone.now().isoformat(),
                }
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    
    return response
```

### Ajouter dans `settings.py` :
```python
REST_FRAMEWORK = {
    # ... autres configs ...
    'EXCEPTION_HANDLER': 'core.exceptions.custom_exception_handler',
}
```

---

## 🔴 4. VALIDATION RENFORCÉE DES MOTS DE PASSE

### Créer `users/validators.py` (améliorer) :
```python
from django.core.exceptions import ValidationError
import re

def validate_password_strength(password):
    """
    Validate password strength.
    - Minimum 8 characters
    - At least one uppercase letter
    - At least one lowercase letter
    - At least one digit
    - At least one special character
    """
    if len(password) < 8:
        raise ValidationError('Le mot de passe doit contenir au moins 8 caractères.')
    
    if not re.search(r'[A-Z]', password):
        raise ValidationError('Le mot de passe doit contenir au moins une majuscule.')
    
    if not re.search(r'[a-z]', password):
        raise ValidationError('Le mot de passe doit contenir au moins une minuscule.')
    
    if not re.search(r'\d', password):
        raise ValidationError('Le mot de passe doit contenir au moins un chiffre.')
    
    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        raise ValidationError('Le mot de passe doit contenir au moins un caractère spécial.')
```

### Ajouter dans `settings.py` :
```python
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        'OPTIONS': {
            'min_length': 8,
        }
    },
    {
        'NAME': 'users.validators.validate_password_strength',  # Nouveau
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]
```

---

## 🔴 5. PROTECTION CONTRE LES ATTAQUES PAR FORCE BRUTE

### Créer `users/security.py` :
```python
from django.core.cache import cache
from django.utils import timezone
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)

MAX_LOGIN_ATTEMPTS = 5
LOCKOUT_DURATION = 15  # minutes

def check_account_lockout(email):
    """Check if account is locked due to failed login attempts."""
    lockout_key = f'account_lockout:{email}'
    attempts_key = f'login_attempts:{email}'
    
    # Vérifier si le compte est verrouillé
    if cache.get(lockout_key):
        logger.warning(f"Account lockout attempt for {email}")
        return True, cache.ttl(lockout_key)
    
    # Vérifier le nombre de tentatives
    attempts = cache.get(attempts_key, 0)
    if attempts >= MAX_LOGIN_ATTEMPTS:
        # Verrouiller le compte
        cache.set(lockout_key, True, timeout=LOCKOUT_DURATION * 60)
        cache.delete(attempts_key)
        logger.warning(f"Account {email} locked due to too many failed attempts")
        return True, LOCKOUT_DURATION * 60
    
    return False, 0

def record_failed_login_attempt(email):
    """Record a failed login attempt."""
    attempts_key = f'login_attempts:{email}'
    attempts = cache.get(attempts_key, 0)
    cache.set(attempts_key, attempts + 1, timeout=15 * 60)  # 15 minutes
    logger.warning(f"Failed login attempt for {email}. Attempts: {attempts + 1}")

def clear_login_attempts(email):
    """Clear login attempts after successful login."""
    attempts_key = f'login_attempts:{email}'
    lockout_key = f'account_lockout:{email}'
    cache.delete(attempts_key)
    cache.delete(lockout_key)
```

### Modifier `users/views.py` :
```python
from .security import check_account_lockout, record_failed_login_attempt, clear_login_attempts

class CustomTokenObtainPairView(TokenObtainPairView):
    """Custom token obtain view with throttling and lockout."""
    throttle_classes = [LoginThrottle]
    
    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        
        # Vérifier le verrouillage de compte
        if email:
            is_locked, remaining_time = check_account_lockout(email)
            if is_locked:
                return Response(
                    {
                        'error': f'Compte verrouillé. Réessayez dans {remaining_time // 60} minutes.',
                        'lockout_remaining': remaining_time
                    },
                    status=status.HTTP_423_LOCKED
                )
        
        try:
            response = super().post(request, *args, **kwargs)
            # Succès - effacer les tentatives
            if email:
                clear_login_attempts(email)
            return response
        except Exception as e:
            # Échec - enregistrer la tentative
            if email:
                record_failed_login_attempt(email)
            raise
```

---

## 🔴 6. HEADERS DE SÉCURITÉ

### Ajouter dans `settings.py` :
```python
# Security Headers
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000 if not DEBUG else 0  # 1 year in production
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_SSL_REDIRECT = not DEBUG
SESSION_COOKIE_SECURE = not DEBUG
CSRF_COOKIE_SECURE = not DEBUG
```

---

## 🔴 7. SANITIZATION DES INPUTS (Protection XSS)

### Ajouter dans `requirements.txt` :
```
bleach==6.1.0
```

### Créer `core/sanitizers.py` :
```python
import bleach
from django.conf import settings

ALLOWED_TAGS = ['p', 'br', 'strong', 'em', 'u', 'a', 'ul', 'ol', 'li']
ALLOWED_ATTRIBUTES = {
    'a': ['href', 'title'],
}

def sanitize_html(content):
    """Sanitize HTML content to prevent XSS."""
    if not content:
        return ''
    
    return bleach.clean(
        content,
        tags=ALLOWED_TAGS,
        attributes=ALLOWED_ATTRIBUTES,
        strip=True
    )

def sanitize_text(content):
    """Sanitize text content (remove all HTML)."""
    if not content:
        return ''
    
    return bleach.clean(content, tags=[], strip=True)
```

### Utiliser dans les serializers :
```python
from core.sanitizers import sanitize_html

class EventSerializer(serializers.ModelSerializer):
    def validate_description(self, value):
        return sanitize_html(value)
```

---

## 🔴 8. SYSTÈME DE PAIEMENT/BILLETTERIE (CRITIQUE MVP)

### Créer `payments/models.py` :
```python
import uuid
from django.db import models
from django.utils import timezone
from users.models import User
from events.models import Event

class Payment(models.Model):
    """Payment model for event tickets."""
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('completed', 'Complété'),
        ('failed', 'Échoué'),
        ('refunded', 'Remboursé'),
    ]
    
    PAYMENT_METHOD_CHOICES = [
        ('stripe', 'Stripe'),
        ('paypal', 'PayPal'),
        ('mobile_money', 'Mobile Money'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payments', db_index=True)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='payments', db_index=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    commission = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)  # 5-10%
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHOD_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True)
    transaction_id = models.CharField(max_length=255, unique=True, db_index=True)
    stripe_payment_intent_id = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(default=timezone.now, db_index=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'payments_payment'
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['event']),
            models.Index(fields=['status']),
            models.Index(fields=['transaction_id']),
        ]
    
    def __str__(self):
        return f"Payment {self.transaction_id} - {self.amount} FCFA"


class Ticket(models.Model):
    """Ticket model for event participation."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    payment = models.OneToOneField(Payment, on_delete=models.CASCADE, related_name='ticket')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tickets', db_index=True)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='tickets', db_index=True)
    ticket_code = models.CharField(max_length=50, unique=True, db_index=True)
    qr_code_url = models.URLField(max_length=500, blank=True)
    is_used = models.BooleanField(default=False)
    used_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'payments_ticket'
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['event']),
            models.Index(fields=['ticket_code']),
            models.Index(fields=['is_used']),
        ]
    
    def __str__(self):
        return f"Ticket {self.ticket_code} for {self.event.title}"
```

---

## 🔴 9. SYSTÈME DE FAVORIS

### Ajouter dans `events/models.py` :
```python
class EventFavorite(models.Model):
    """User favorites for events."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favorite_events', db_index=True)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='favorited_by', db_index=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        db_table = 'events_eventfavorite'
        unique_together = ['user', 'event']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['event']),
        ]
    
    def __str__(self):
        return f"{self.user.username} favorited {self.event.title}"
```

---

## 🔴 10. OPTIMISATION DES REQUÊTES (N+1)

### Améliorer `events/views.py` :
```python
class EventViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        queryset = super().get_queryset()
        # Optimiser avec select_related et prefetch_related
        queryset = queryset.select_related(
            'organizer',
            'organizer__profile',
            'category'
        ).prefetch_related(
            'participations__user',
            'comments__user',
            'likes__user'
        )
        # ... reste du code ...
```

---

## 📊 RÉSUMÉ DES AMÉLIORATIONS PRIORITAIRES

### 🔴 À FAIRE IMMÉDIATEMENT (Semaine 1)
1. ✅ Corriger chiffrement matricules
2. ✅ Configurer logging
3. ✅ Améliorer gestion d'erreurs
4. ✅ Validation mots de passe renforcée
5. ✅ Protection force brute

### 🟡 À FAIRE RAPIDEMENT (Semaine 2-3)
6. ✅ Headers de sécurité
7. ✅ Sanitization inputs
8. ✅ Système de paiement/billetterie
9. ✅ Système de favoris
10. ✅ Optimisation requêtes

### 🟢 À PLANIFIER (Semaine 4+)
11. Tests unitaires et intégration
12. Messagerie temps réel
13. Système de groupes
14. Dashboard analytics
15. Recommandations personnalisées

---

**Score actuel** : 4.1/10
**Score cible après améliorations** : 8.5/10

