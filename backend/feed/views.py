"""
Views for feed app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from django.utils import timezone
from .models import FeedItem
from .serializers import FeedItemSerializer
from .permissions import CanManageFeed, CanViewFeed
from users.models import User
from users.permissions import IsActiveAndVerified


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
        
        # Auto-filter for university admins - only show feed items from their university
        if (user.role == 'university_admin' and user.managed_university):
            queryset = queryset.filter(author__profile__university=user.managed_university)
        else:
            # Get user's university if available
            user_university = None
            if hasattr(user, 'profile') and user.profile:
                user_university = user.profile.university
            
            # Filter by visibility
            # Show public items OR private items from user's university
            if user_university:
                queryset = queryset.filter(
                    Q(visibility='public') | 
                    Q(visibility='private', author__profile__university=user_university)
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
                Q(visibility='private', author__profile__university__name__icontains=university)
            )
        
        return queryset.order_by('-created_at')
    
    def get_permissions(self):
        """
        Instantiates and returns the list of permissions that this view requires.
        """
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            permission_classes = [IsAuthenticated, IsActiveAndVerified, CanManageFeed]
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
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def personalized(self, request):
        """
        Get personalized feed for the current user.
        Includes:
        - Events user is participating in
        - Events from user's groups
        - Events from user's friends
        - Events from user's university
        - Feed items from user's university
        - Feed items from user's groups
        """
        from events.models import Event, Participation
        from groups.models import Group, Membership
        from users.models import Friendship
        
        user = request.user
        user_university = None
        if hasattr(user, 'profile') and user.profile:
            user_university = user.profile.university
        
        # Get user's participations
        user_participations = Participation.objects.filter(user=user).values_list('event_id', flat=True)
        
        # Get user's groups
        user_groups = Membership.objects.filter(
            user=user,
            status='active'
        ).values_list('group_id', flat=True)
        
        # Get user's friends
        user_friends = Friendship.objects.filter(
            (Q(from_user=user) | Q(to_user=user)),
            status='accepted'
        ).values_list('from_user_id', 'to_user_id')
        friend_ids = set()
        for friendship in user_friends:
            friend_ids.add(friendship[0] if friendship[0] != user.id else friendship[1])
        
        # Get personalized events
        events_queryset = Event.objects.filter(
            status='published'
        ).select_related('organizer', 'category', 'university').prefetch_related(
            'organizer__profile',
            'participations__user'
        )
        
        # Filter events: user's participations, friends' events, university events
        # Note: Events don't have a direct 'group' field, so we filter by organizer's groups instead
        events_filter = Q()
        if user_participations:
            events_filter |= Q(id__in=user_participations)
        if user_groups:
            # Events organized by users who are members of groups the current user is in
            # This is a workaround since Event doesn't have a direct group field
            # We could filter by organizer being in the same groups, but that's complex
            # For now, we'll skip group-based event filtering
            pass
        if friend_ids:
            # Events organized by friends
            events_filter |= Q(organizer_id__in=friend_ids)
        if user_university:
            # Events from user's university
            events_filter |= Q(
                Q(university=user_university) |
                Q(university__isnull=True, organizer__profile__university=user_university)
            )
        
        if events_filter:
            personalized_events = events_queryset.filter(events_filter).distinct().order_by('-created_at', '-start_date')[:20]
        else:
            # Fallback to university events or public events
            if user_university:
                personalized_events = events_queryset.filter(
                    Q(university=user_university) |
                    Q(university__isnull=True, organizer__profile__university=user_university)
                ).order_by('-created_at', '-start_date')[:20]
            else:
                # Fallback to all published events - inclure tous les événements publiés récents
                personalized_events = events_queryset.order_by('-created_at', '-start_date')[:20]
        
        # Get personalized feed items
        feed_items_queryset = FeedItem.objects.filter(
            is_published=True,
            is_deleted=False,
            is_hidden=False
        ).select_related('author', 'author__profile')
        
        feed_filter = Q()
        if user_university:
            # Feed items from user's university
            feed_filter |= Q(author__profile__university=user_university)
        if user_groups:
            # Feed items related to user's groups (if FeedItem has group field)
            # For now, we'll focus on university-based filtering
            pass
        if friend_ids:
            # Feed items from friends
            feed_filter |= Q(author_id__in=friend_ids)
        
        # Always include public items
        feed_filter |= Q(visibility='public')
        
        personalized_feed_items = feed_items_queryset.filter(feed_filter).distinct().order_by('-created_at')[:20]
        
        # Serialize events
        from events.serializers import EventSerializer
        events_serializer = EventSerializer(personalized_events, many=True, context={'request': request})
        
        # Serialize feed items
        feed_serializer = self.get_serializer(personalized_feed_items, many=True)
        
        # Combine and sort by relevance/date
        combined_items = []
        
        # Add events as feed-like items
        for event in events_serializer.data:
            combined_items.append({
                'type': 'event',
                'id': event['id'],
                'title': event['title'],
                'content': event.get('description', ''),
                'image': event.get('image_url') or event.get('image'),
                'author': event.get('organizer'),
                'university': event.get('university'),
                'created_at': event.get('start_date') or event.get('created_at'),
                'event_data': event,
            })
        
        # Add feed items
        for feed_item in feed_serializer.data:
            combined_items.append({
                'type': 'feed',
                'id': feed_item['id'],
                'title': feed_item.get('title', ''),
                'content': feed_item.get('content', ''),
                'image': feed_item.get('image'),
                'author': feed_item.get('author'),
                'university': feed_item.get('university'),
                'created_at': feed_item.get('created_at'),
                'feed_data': feed_item,
            })
        
        # Sort by created_at (most recent first)
        combined_items.sort(key=lambda x: x.get('created_at', ''), reverse=True)
        
        return Response({
            'items': combined_items[:30],  # Limit to 30 items
            'total': len(combined_items),
            'events_count': len(personalized_events),
            'feed_items_count': len(personalized_feed_items),
        })
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def friends_activity(self, request):
        """
        Get activity feed from user's friends.
        Shows:
        - Events friends are participating in
        - Events friends organized
        - Events friends liked/favorited
        - Feed items from friends
        """
        from events.models import Event, Participation, EventLike, EventFavorite
        from users.models import Friendship
        
        user = request.user
        
        # Get user's friends
        friendships = Friendship.objects.filter(
            (Q(from_user=user) | Q(to_user=user)),
            status='accepted'
        )
        friend_ids = set()
        for friendship in friendships:
            friend_ids.add(friendship.from_user_id if friendship.from_user_id != user.id else friendship.to_user_id)
        
        if not friend_ids:
            return Response({
                'items': [],
                'total': 0,
                'message': 'Vous n\'avez pas encore d\'amis. Ajoutez des amis pour voir leur activité!'
            })
        
        activities = []
        
        # 1. Events friends are participating in (recent)
        friend_participations = Participation.objects.filter(
            user_id__in=friend_ids,
            created_at__gte=timezone.now() - timezone.timedelta(days=30)  # Last 30 days
        ).select_related(
            'user', 'user__profile', 'event', 'event__organizer', 'event__category'
        ).order_by('-created_at')[:20]
        
        for participation in friend_participations:
            activities.append({
                'type': 'participation',
                'id': str(participation.id),
                'friend': {
                    'id': str(participation.user.id),
                    'username': participation.user.username,
                    'first_name': participation.user.first_name,
                    'last_name': participation.user.last_name,
                    'profile_picture': participation.user.profile.profile_picture.url if hasattr(participation.user, 'profile') and participation.user.profile and participation.user.profile.profile_picture else None,
                },
                'event': {
                    'id': str(participation.event.id),
                    'title': participation.event.title,
                    'image_url': participation.event.image_url if hasattr(participation.event, 'image_url') else None,
                },
                'created_at': participation.created_at.isoformat(),
                'message': f"{participation.user.first_name or participation.user.username} participe à {participation.event.title}",
            })
        
        # 2. Events friends organized (recent)
        friend_organized = Event.objects.filter(
            organizer_id__in=friend_ids,
            created_at__gte=timezone.now() - timezone.timedelta(days=30)
        ).select_related(
            'organizer', 'organizer__profile', 'category'
        ).order_by('-created_at')[:15]
        
        for event in friend_organized:
            activities.append({
                'type': 'event_created',
                'id': str(event.id),
                'friend': {
                    'id': str(event.organizer.id),
                    'username': event.organizer.username,
                    'first_name': event.organizer.first_name,
                    'last_name': event.organizer.last_name,
                    'profile_picture': event.organizer.profile.profile_picture.url if hasattr(event.organizer, 'profile') and event.organizer.profile and event.organizer.profile.profile_picture else None,
                },
                'event': {
                    'id': str(event.id),
                    'title': event.title,
                    'description': event.description[:200] if event.description else '',
                    'start_date': event.start_date.isoformat() if event.start_date else None,
                    'image_url': event.image_url if hasattr(event, 'image_url') else None,
                },
                'created_at': event.created_at.isoformat(),
                'message': f"{event.organizer.first_name or event.organizer.username} a créé l'événement {event.title}",
            })
        
        # 3. Events friends liked (recent)
        friend_likes = EventLike.objects.filter(
            user_id__in=friend_ids,
            created_at__gte=timezone.now() - timezone.timedelta(days=7)  # Last 7 days
        ).select_related(
            'user', 'user__profile', 'event', 'event__organizer'
        ).order_by('-created_at')[:15]
        
        for like in friend_likes:
            activities.append({
                'type': 'event_liked',
                'id': str(like.id),
                'friend': {
                    'id': str(like.user.id),
                    'username': like.user.username,
                    'first_name': like.user.first_name,
                    'last_name': like.user.last_name,
                    'profile_picture': like.user.profile.profile_picture.url if hasattr(like.user, 'profile') and like.user.profile and like.user.profile.profile_picture else None,
                },
                'event': {
                    'id': str(like.event.id),
                    'title': like.event.title,
                    'image_url': like.event.image_url if hasattr(like.event, 'image_url') else None,
                },
                'created_at': like.created_at.isoformat(),
                'message': f"{like.user.first_name or like.user.username} a aimé {like.event.title}",
            })
        
        # 4. Events friends favorited (recent)
        friend_favorites = EventFavorite.objects.filter(
            user_id__in=friend_ids,
            created_at__gte=timezone.now() - timezone.timedelta(days=7)
        ).select_related(
            'user', 'user__profile', 'event', 'event__organizer'
        ).order_by('-created_at')[:15]
        
        for favorite in friend_favorites:
            activities.append({
                'type': 'event_favorited',
                'id': str(favorite.id),
                'friend': {
                    'id': str(favorite.user.id),
                    'username': favorite.user.username,
                    'first_name': favorite.user.first_name,
                    'last_name': favorite.user.last_name,
                    'profile_picture': favorite.user.profile.profile_picture.url if hasattr(favorite.user, 'profile') and favorite.user.profile and favorite.user.profile.profile_picture else None,
                },
                'event': {
                    'id': str(favorite.event.id),
                    'title': favorite.event.title,
                    'image_url': favorite.event.image_url if hasattr(favorite.event, 'image_url') else None,
                },
                'created_at': favorite.created_at.isoformat() if hasattr(favorite, 'created_at') else timezone.now().isoformat(),
                'message': f"{favorite.user.first_name or favorite.user.username} a ajouté {favorite.event.title} à ses favoris",
            })
        
        # 5. Feed items from friends
        friend_feed_items = FeedItem.objects.filter(
            author_id__in=friend_ids,
            is_published=True,
            is_deleted=False,
            is_hidden=False,
            created_at__gte=timezone.now() - timezone.timedelta(days=30)
        ).select_related(
            'author', 'author__profile'
        ).order_by('-created_at')[:15]
        
        feed_serializer = self.get_serializer(friend_feed_items, many=True)
        for feed_item in feed_serializer.data:
            activities.append({
                'type': 'feed_item',
                'id': feed_item['id'],
                'friend': feed_item.get('author'),
                'content': feed_item.get('content', ''),
                'title': feed_item.get('title', ''),
                'image': feed_item.get('image'),
                'created_at': feed_item.get('created_at'),
                'message': f"{feed_item.get('author', {}).get('first_name', 'Un ami')} a partagé: {feed_item.get('title', '')}",
            })
        
        # Sort all activities by date (most recent first)
        activities.sort(key=lambda x: x.get('created_at', ''), reverse=True)
        
        return Response({
            'items': activities[:50],  # Limit to 50 activities
            'total': len(activities),
        })

