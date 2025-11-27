"""
URLs for groups app.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import GroupViewSet, GroupPostViewSet

router = DefaultRouter()
router.register(r'groups', GroupViewSet, basename='group')
router.register(r'group-posts', GroupPostViewSet, basename='group-post')

urlpatterns = [
    path('', include(router.urls)),
]

