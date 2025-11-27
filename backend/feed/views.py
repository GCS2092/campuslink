"""
Views for feed app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from .models import FeedItem
from .serializers import FeedItemSerializer
from .permissions import CanManageFeed, CanViewFeed
from users.models import User


class FeedItemViewSet(viewsets.ModelViewSet):
    """
    ViewSet for feed items.
    - List: All users can view feed items (filtered by visibility)
    - Create/Update/Delete: Only admin and class leaders
    """
    serializer_class = FeedItemSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = None  # Disable pagination for feed items to show all
    
    def get_queryset(self):
        user = self.request.user
        
        # Base queryset - exclude deleted and hidden items
        queryset = FeedItem.objects.filter(
            is_published=True,
            is_deleted=False,
            is_hidden=False
        ).select_related('author', 'author__profile')
        
        # Get user's university if available
        user_university = None
        if hasattr(user, 'profile') and user.profile:
            user_university = user.profile.university
        
        # Filter by visibility
        # Show public items OR private items from user's university
        if user_university:
            queryset = queryset.filter(
                Q(visibility='public') | 
                Q(visibility='private', university=user_university)
            )
        else:
            # If user has no university, only show public items
            queryset = queryset.filter(visibility='public')
        
        # Filter by type if provided
        feed_type = self.request.query_params.get('type')
        if feed_type:
            queryset = queryset.filter(type=feed_type)
        
        # Filter by university if provided (for private items)
        university = self.request.query_params.get('university')
        if university:
            queryset = queryset.filter(
                Q(visibility='public') | 
                Q(visibility='private', university__icontains=university)
            )
        
        return queryset.order_by('-created_at')
    
    def get_permissions(self):
        """
        Instantiates and returns the list of permissions that this view requires.
        """
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            permission_classes = [IsAuthenticated, CanManageFeed]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def perform_create(self, serializer):
        """Set author to current user and ensure is_published is True by default."""
        # Ensure is_published is True by default (unless explicitly set to False)
        if 'is_published' not in serializer.validated_data:
            serializer.validated_data['is_published'] = True
        feed_item = serializer.save(author=self.request.user)
        # Double check: if somehow is_published is False, set it to True
        if not feed_item.is_published:
            feed_item.is_published = True
            feed_item.save(update_fields=['is_published'])
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated(), CanManageFeed()])
    def my_feed_items(self, request):
        """Get feed items created by current user (for managers)."""
        queryset = FeedItem.objects.filter(author=request.user).order_by('-created_at')
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

