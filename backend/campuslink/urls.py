"""
URL configuration for CampusLink project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

schema_view = get_schema_view(
   openapi.Info(
      title="CampusLink API",
      default_version='v1',
      description="API documentation for CampusLink - Réseau Social Étudiant",
      terms_of_service="https://www.campuslink.sn/terms/",
      contact=openapi.Contact(email="contact@campuslink.sn"),
      license=openapi.License(name="MIT License"),
   ),
   public=True,
   permission_classes=(permissions.AllowAny,),
)

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # API Documentation
    path('api/docs/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('api/redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
    path('api/swagger/', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    
    # API Routes
    path('api/auth/', include('users.urls')),
    path('api/users/', include('users.urls')),
    path('api/events/', include('events.urls')),
    path('api/social/', include('social.urls')),
    path('api/notifications/', include('notifications.urls')),
    path('api/moderation/', include('moderation.urls')),
    path('api/', include('payments.urls')),
    path('api/messaging/', include('messaging.urls')),
    path('api/', include('groups.urls')),
    path('api/', include('feed.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

