"""
URLs for feed app.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import FeedItemViewSet

router = DefaultRouter()
router.register(r'feed', FeedItemViewSet, basename='feeditem')

urlpatterns = [
    path('', include(router.urls)),
]

