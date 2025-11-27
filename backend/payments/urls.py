"""
URLs for payments app.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PaymentViewSet, TicketViewSet

router = DefaultRouter()
router.register(r'payments', PaymentViewSet, basename='payment')
router.register(r'tickets', TicketViewSet, basename='ticket')

urlpatterns = [
    path('', include(router.urls)),
]

urlpatterns = [
    path('', include(router.urls)),
]

