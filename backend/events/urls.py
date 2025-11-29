"""
URLs for Events app.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CategoryViewSet, EventViewSet, CalendarViewSet, EventFilterPreferenceViewSet

router = DefaultRouter()
router.register(r'categories', CategoryViewSet, basename='category')
router.register(r'calendar', CalendarViewSet, basename='calendar')
router.register(r'filter-preferences', EventFilterPreferenceViewSet, basename='event-filter-preference')
router.register(r'', EventViewSet, basename='event')

urlpatterns = [
    path('', include(router.urls)),
]

