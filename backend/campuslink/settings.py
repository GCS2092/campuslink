"""
Django settings for CampusLink project.
"""

import os
import warnings
from pathlib import Path
import environ

# Suppress pkg_resources deprecation warning from djangorestframework-simplejwt
warnings.filterwarnings('ignore', message='.*pkg_resources is deprecated.*', category=UserWarning)

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# Initialize environment variables
env = environ.Env(
    DEBUG=(bool, False)
)

# Read .env file
environ.Env.read_env(os.path.join(BASE_DIR, '.env'))

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = env('SECRET_KEY', default='django-insecure-change-this-in-production')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = env('DEBUG', default=True)

# Allow all hosts in development for mobile testing
if DEBUG:
    # Get local IP for network access automatically
    def get_local_ip():
        """Get the local IP address."""
        try:
            import socket
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception:
            return None
    
    local_ip = get_local_ip()
    ALLOWED_HOSTS = ['*', 'localhost', '127.0.0.1']
    if local_ip:
        ALLOWED_HOSTS.append(local_ip)
    # Also add common network IPs
    ALLOWED_HOSTS.extend(['192.168.1.118', ' 192.168.1.118', '192.168.1.1', '192.168.0.1'])
else:
    ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=['localhost', '127.0.0.1'])

# Application definition
INSTALLED_APPS = [
    'daphne',  # Must be first for ASGI
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Note: 'django.contrib.gis' will be added conditionally if GeoDjango is available
    # See database configuration below
    
    # Third party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'drf_yasg',
    'django_filters',
    'cloudinary_storage',  # Must be before django.contrib.staticfiles
    'cloudinary',  # Cloudinary SDK
    
    # Local apps
    'feed',
    'core',
    'users',
    'events',
    'social',
    'notifications',
    'moderation',
    'payments',
    'messaging',
    'groups',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Must be at the top, before SecurityMiddleware
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'campuslink.middleware.AuditLogMiddleware',
]

ROOT_URLCONF = 'campuslink.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'campuslink.wsgi.application'
ASGI_APPLICATION = 'campuslink.asgi.application'

# Database
# Use DATABASE_URL if available (for Railway, Render, etc.)
if 'DATABASE_URL' in os.environ:
    import dj_database_url
    DATABASES = {
        'default': dj_database_url.config(
            conn_max_age=600,
            conn_health_checks=True,
        )
    }
else:
    # Check if GeoDjango/PostGIS is available
    GEODJANGO_AVAILABLE = False
    try:
        # Try to import GeoDjango components
        from django.contrib.gis.geos import Point
        from django.contrib.gis.db.backends.postgis import base as postgis_base
        GEODJANGO_AVAILABLE = True
    except (ImportError, Exception):
        GEODJANGO_AVAILABLE = False
    
    if GEODJANGO_AVAILABLE:
        # Use PostGIS if GeoDjango is available
        INSTALLED_APPS.append('django.contrib.gis')
        DATABASES = {
            'default': {
                'ENGINE': 'django.contrib.gis.db.backends.postgis',
                'NAME': env('DB_DATABASE', default='campuslink'),
                'USER': env('DB_USERNAME', default='postgres'),
                'PASSWORD': env('DB_PASSWORD', default='password123'),
                'HOST': env('DB_HOST', default='localhost'),
                'PORT': env('DB_PORT', default='5432'),
            }
        }
    else:
        # Use regular PostgreSQL if GeoDjango is not available
        DATABASES = {
            'default': {
                'ENGINE': 'django.db.backends.postgresql',
                'NAME': env('DB_DATABASE', default='campuslink'),
                'USER': env('DB_USERNAME', default='postgres'),
                'PASSWORD': env('DB_PASSWORD', default='password123'),
                'HOST': env('DB_HOST', default='localhost'),
                'PORT': env('DB_PORT', default='5432'),
            }
        }

# Password validation
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
        'NAME': 'users.validators.PasswordStrengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'fr-fr'

# Encoding settings
DEFAULT_CHARSET = 'utf-8'
FILE_CHARSET = 'utf-8'

# External Student Database Verification Settings
# Configuration pour la vérification des étudiants avec une base de données externe
EXTERNAL_STUDENT_VERIFICATION_ENABLED = env.bool('EXTERNAL_STUDENT_VERIFICATION_ENABLED', default=False)
EXTERNAL_STUDENT_VERIFIER_CLASS = env.str(
    'EXTERNAL_STUDENT_VERIFIER_CLASS',
    default='users.external_student_verification.MockExternalStudentVerifier'
)

# Configuration de la base de données externe (à configurer selon votre système)
EXTERNAL_STUDENT_DB_CONFIG = {
    'host': env.str('EXTERNAL_STUDENT_DB_HOST', default=''),
    'port': env.int('EXTERNAL_STUDENT_DB_PORT', default=5432),
    'database': env.str('EXTERNAL_STUDENT_DB_NAME', default=''),
    'user': env.str('EXTERNAL_STUDENT_DB_USER', default=''),
    'password': env.str('EXTERNAL_STUDENT_DB_PASSWORD', default=''),
    'connection_timeout': env.int('EXTERNAL_STUDENT_DB_TIMEOUT', default=10),
    # Ajouter d'autres paramètres selon le type de base de données (PostgreSQL, MySQL, etc.)
}
TIME_ZONE = 'Africa/Dakar'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# WhiteNoise for static files in production
if not DEBUG:
    STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
    MIDDLEWARE.insert(1, 'whitenoise.middleware.WhiteNoiseMiddleware')

# Media files - Cloudinary for production
import cloudinary
import cloudinary.uploader
import cloudinary.api

# Cloudinary configuration
CLOUDINARY_STORAGE = {
    'CLOUD_NAME': env('CLOUDINARY_CLOUD_NAME', default=''),
    'API_KEY': env('CLOUDINARY_API_KEY', default=''),
    'API_SECRET': env('CLOUDINARY_API_SECRET', default=''),
}

# Use Cloudinary in production, local storage in development
if not DEBUG or env.bool('USE_CLOUDINARY', default=False):
    DEFAULT_FILE_STORAGE = 'cloudinary_storage.storage.MediaCloudinaryStorage'
    MEDIA_URL = '/media/'
else:
    MEDIA_URL = '/media/'
    MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Custom User Model
AUTH_USER_MODEL = 'users.User'

# REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'users.authentication.CustomJWTAuthentication',
        'rest_framework_simplejwt.authentication.JWTAuthentication',  # Fallback
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_PAGINATION_CLASS': 'core.pagination.CustomPageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/hour',
        'user': '1000/hour',
    },
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'EXCEPTION_HANDLER': 'core.exceptions.custom_exception_handler',
}

# JWT Settings
from datetime import timedelta

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'AUTH_HEADER_TYPES': ('Bearer',),
}

# CORS Settings - Permissive for mobile development
if DEBUG:
    # Auto-detect local IP for CORS
    def get_local_ip():
        """Get the local IP address."""
        try:
            import socket
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception:
            return None
    
    local_ip = get_local_ip()
    default_origins = [
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        'http://localhost:3001',
        'http://127.0.0.1:3001',
    ]
    
    if local_ip:
        default_origins.extend([
            f'http://{local_ip}:3000',
            f'http://{local_ip}:3001',
        ])
    
    # Add common network IPs and ports
    default_origins.extend([
        'http://192.168.1.118:3000',
        'http://192.168.1.118:3001',
        'http:// 192.168.1.118:3000',
        'http:// 192.168.1.118:3001',
        'http://192.168.1.1:3000',
        'http://192.168.0.1:3000',
        'http://10.0.2.2:3000',  # Android emulator
        'http://10.0.2.2:8000',  # Android emulator backend
    ])
    
    # In development, allow all origins for mobile testing
    # But also set specific origins for better compatibility
    CORS_ALLOW_ALL_ORIGINS = True
    CORS_ALLOW_CREDENTIALS = True
    CORS_ALLOW_HEADERS = [
        'accept',
        'accept-encoding',
        'authorization',
        'content-type',
        'dnt',
        'origin',
        'user-agent',
        'x-csrftoken',
        'x-requested-with',
        'cache-control',
    ]
    CORS_ALLOW_METHODS = [
        'DELETE',
        'GET',
        'OPTIONS',
        'PATCH',
        'POST',
        'PUT',
    ]
    CORS_EXPOSE_HEADERS = [
        'content-type',
        'x-total-count',
        'authorization',
    ]
    
    # Also set allowed origins for reference (even though ALLOW_ALL_ORIGINS takes precedence)
    CORS_ALLOWED_ORIGINS = env.list(
        'CORS_ALLOWED_ORIGINS',
        default=default_origins
    )
    
    # CSRF trusted origins for Django forms (if needed)
    CSRF_TRUSTED_ORIGINS = default_origins.copy()
    
    # Additional CORS settings for better compatibility
    CORS_PREFLIGHT_MAX_AGE = 86400  # 24 hours
else:
    # In production, use specific origins
    CORS_ALLOW_ALL_ORIGINS = False
    CORS_ALLOWED_ORIGINS = env.list(
        'CORS_ALLOWED_ORIGINS',
        default=[
            'http://localhost:3000', 
            'http://127.0.0.1:3000',
            'http://192.168.1.118:3000'
        ]
    )
    CORS_ALLOW_CREDENTIALS = True
    CSRF_TRUSTED_ORIGINS = CORS_ALLOWED_ORIGINS

# Redis Configuration (optional - for future use with Upstash Redis)
REDIS_URL = env('REDIS_URL', default=None)
USE_REDIS_CACHE = env.bool('USE_REDIS_CACHE', default=False)

# Cache Configuration
# Priority: Redis (if configured) > Database Cache > LocMemCache
if USE_REDIS_CACHE and REDIS_URL:
    # Use Redis if explicitly configured (e.g., Upstash Redis)
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.redis.RedisCache',
            'LOCATION': REDIS_URL,
            'OPTIONS': {
                'CLIENT_CLASS': 'django_redis.client.DefaultClient',
                'SOCKET_CONNECT_TIMEOUT': 5,
                'SOCKET_TIMEOUT': 5,
            }
        }
    }
elif not DEBUG:
    # Production: Use Database Cache (persistent, uses PostgreSQL)
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.db.DatabaseCache',
            'LOCATION': 'cache_table',
            'OPTIONS': {
                'MAX_ENTRIES': 10000,
                'CULL_FREQUENCY': 3,  # Remove 1/3 of entries when MAX_ENTRIES reached
            },
            'TIMEOUT': 300,  # Default timeout: 5 minutes
        }
    }
else:
    # Development: Use local memory cache (fast, no setup required)
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
            'LOCATION': 'unique-snowflake',
        }
    }

# Celery Configuration
CELERY_BROKER_URL = REDIS_URL
CELERY_RESULT_BACKEND = REDIS_URL
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = TIME_ZONE

# Channels Configuration (WebSockets)
# Use in-memory channel layer in development if Redis is not available
if DEBUG:
    try:
        import redis
        redis_client = redis.Redis(
            host=env('REDIS_HOST', default='localhost'), 
            port=env.int('REDIS_PORT', default=6379), 
            socket_connect_timeout=1
        )
        redis_client.ping()
        # Redis is available, use it
        CHANNEL_LAYERS = {
            'default': {
                'BACKEND': 'channels_redis.core.RedisChannelLayer',
                'CONFIG': {
                    "hosts": [(env('REDIS_HOST', default='localhost'), env.int('REDIS_PORT', default=6379))],
                },
            },
        }
    except Exception:
        # Redis not available (ConnectionError, TimeoutError, ImportError, etc.)
        # Use in-memory channel layer for development
        import logging
        logger = logging.getLogger(__name__)
        logger.warning("Redis not available, using InMemoryChannelLayer for WebSockets")
        CHANNEL_LAYERS = {
            'default': {
                'BACKEND': 'channels.layers.InMemoryChannelLayer',
            },
        }
else:
    # Production: always use Redis
    CHANNEL_LAYERS = {
        'default': {
            'BACKEND': 'channels_redis.core.RedisChannelLayer',
            'CONFIG': {
                "hosts": [(env('REDIS_HOST', default='localhost'), env.int('REDIS_PORT', default=6379))],
            },
        },
    }

# Email Configuration
EMAIL_BACKEND = env('EMAIL_BACKEND', default='django.core.mail.backends.console.EmailBackend')
EMAIL_HOST = env('EMAIL_HOST', default='smtp.gmail.com')
EMAIL_PORT = env.int('EMAIL_PORT', default=587)
EMAIL_USE_TLS = env.bool('EMAIL_USE_TLS', default=True)
EMAIL_HOST_USER = env('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = env('EMAIL_HOST_PASSWORD', default='')
DEFAULT_FROM_EMAIL = env('DEFAULT_FROM_EMAIL', default='noreply@campuslink.sn')

# Frontend URL (for email links)
FRONTEND_URL = env('FRONTEND_URL', default='http://localhost:3000')

# SMS Configuration (Twilio)
TWILIO_ACCOUNT_SID = env('TWILIO_ACCOUNT_SID', default='')
TWILIO_AUTH_TOKEN = env('TWILIO_AUTH_TOKEN', default='')
TWILIO_PHONE_NUMBER = env('TWILIO_PHONE_NUMBER', default='')

# Cloudinary Configuration (Media Storage)
CLOUDINARY_URL = env('CLOUDINARY_URL', default='')

# Sentry Configuration (Error Tracking)
SENTRY_DSN = env('SENTRY_DSN', default='')
if SENTRY_DSN:
    import sentry_sdk
    from sentry_sdk.integrations.django import DjangoIntegration
    
    sentry_sdk.init(
        dsn=SENTRY_DSN,
        integrations=[DjangoIntegration()],
        traces_sample_rate=1.0,
        send_default_pii=True
    )

# University Email Domains (for verification)
UNIVERSITY_EMAIL_DOMAINS = [
    '@esmt.sn',
    '@ucad.sn',
    '@ugb.sn',
    '@esp.sn',
    '@uasz.sn',
    '@univ-thies.sn',
]

# Rate Limiting Custom Rates
CUSTOM_THROTTLE_RATES = {
    'register': '3/hour',
    'otp': '5/hour',
    'login': '5/15min',
}

# Swagger/OpenAPI Documentation
SWAGGER_SETTINGS = {
    'SECURITY_DEFINITIONS': {
        'Bearer': {
            'type': 'apiKey',
            'name': 'Authorization',
            'in': 'header'
        }
    },
    'USE_SESSION_AUTH': False,
}

# Security Headers
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000 if not DEBUG else 0  # 1 year in production
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_SSL_REDIRECT = not DEBUG
# In development, allow insecure cookies for mobile testing
SESSION_COOKIE_SECURE = False if DEBUG else True
CSRF_COOKIE_SECURE = False if DEBUG else True
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = True
# CSRF is handled by JWT for API, so we don't need CSRF_TRUSTED_ORIGINS

# Production Settings (Railway, Render, etc.)
if not DEBUG:
    # Use Cloudinary for media files in production
    DEFAULT_FILE_STORAGE = 'cloudinary_storage.storage.MediaCloudinaryStorage'
    
    # Ensure ALLOWED_HOSTS is set
    if not ALLOWED_HOSTS or ALLOWED_HOSTS == ['*']:
        # Get from environment or use default
        allowed_hosts_str = env('ALLOWED_HOSTS', default='')
        if allowed_hosts_str:
            ALLOWED_HOSTS = [host.strip() for host in allowed_hosts_str.split(',')]
        else:
            # Default to common production patterns
            ALLOWED_HOSTS = ['localhost', '127.0.0.1']

# Logging Configuration
from .logging_config import LOGGING
