"""
Views for Notifications app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Notification
from .serializers import NotificationSerializer


class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for notifications."""
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    ordering = ['-created_at']
    
    def get_queryset(self):
        queryset = Notification.objects.filter(recipient=self.request.user)
        
        # Filter by read status if provided
        is_read = self.request.query_params.get('is_read')
        if is_read is not None:
            is_read_bool = is_read.lower() == 'true'
            queryset = queryset.filter(is_read=is_read_bool)
        
        return queryset
    
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get count of unread notifications."""
        from .utils import get_unread_count
        count = get_unread_count(request.user)
        return Response({'unread_count': count})
    
    @action(detail=True, methods=['put'])
    def read(self, request, pk=None):
        """Mark notification as read."""
        notification = self.get_object()
        notification.is_read = True
        notification.save(update_fields=['is_read'])
        return Response(NotificationSerializer(notification).data)
    
    @action(detail=False, methods=['put'])
    def read_all(self, request):
        """Mark all notifications as read."""
        Notification.objects.filter(recipient=request.user, is_read=False).update(is_read=True)
        return Response({'message': 'Toutes les notifications ont été marquées comme lues.'})

