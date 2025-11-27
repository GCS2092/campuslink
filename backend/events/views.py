"""
Views for Events app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.db.models import Q
from .models import Category, Event, Participation, EventComment, EventLike, EventFavorite
from .serializers import (
    CategorySerializer, EventSerializer, ParticipationSerializer,
    EventCommentSerializer, EventLikeSerializer
)
from .permissions import IsVerifiedOrReadOnly
from users.permissions import IsAdminOrClassLeader
from .analytics import get_event_analytics, get_organizer_dashboard
from .utils import get_nearby_events
from .calendar import generate_user_calendar, get_user_calendar_events
from .recommendations import get_recommended_events
from core.cache import invalidate_feed_cache


class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for categories."""
    serializer_class = CategorySerializer
    permission_classes = [AllowAny]
    
    def get_queryset(self):
        """Get categories with cache."""
        from core.cache import get_cached_categories, cache_categories
        
        # Try to get from cache
        cached = get_cached_categories()
        if cached:
            # Return queryset from cached IDs
            category_ids = [c['id'] for c in cached]
            return Category.objects.filter(id__in=category_ids).order_by('name')
        
        # Get from database
        queryset = Category.objects.all().order_by('name')
        
        # Cache the results
        categories_data = [{'id': str(c.id), 'name': c.name, 'slug': c.slug} for c in queryset]
        cache_categories(categories_data)
        
        return queryset


class EventViewSet(viewsets.ModelViewSet):
    """ViewSet for events."""
    queryset = Event.objects.filter(status='published').select_related(
        'organizer', 'category'
    ).prefetch_related(
        'organizer__profile',
        'participations__user',
        'comments__user',
        'likes__user',
        'favorited_by__user'
    )
    serializer_class = EventSerializer
    permission_classes = [IsVerifiedOrReadOnly]
    filterset_fields = ['category', 'status', 'is_featured']
    search_fields = ['title', 'description', 'location']
    ordering_fields = ['start_date', 'created_at', 'participants_count', 'likes_count']
    ordering = ['-created_at']
    
    def get_queryset(self):
        try:
            # Admins can see all events (including drafts), others only published
            if (hasattr(self.request, 'user') and 
                self.request.user.is_authenticated and 
                (self.request.user.is_staff or 
                 self.request.user.is_superuser or 
                 self.request.user.role == 'admin')):
                queryset = Event.objects.all()
            else:
                queryset = super().get_queryset()
            
            queryset = queryset.select_related(
                'organizer', 'category'
            ).prefetch_related(
                'organizer__profile',
                'participations__user',
                'comments__user',
                'likes__user',
                'favorited_by__user'
            )
            
            # Filters
            university = self.request.query_params.get('university')
            if university:
                # Use a safe filter that handles missing profiles
                queryset = queryset.filter(
                    organizer__profile__isnull=False,
                    organizer__profile__university=university
                )
            
            status_filter = self.request.query_params.get('status')
            if status_filter and (hasattr(self.request, 'user') and 
                                  self.request.user.is_authenticated and
                                  (self.request.user.is_staff or 
                                   self.request.user.is_superuser or 
                                   self.request.user.role == 'admin')):
                queryset = queryset.filter(status=status_filter)
            
            date_from = self.request.query_params.get('date_from')
            if date_from:
                queryset = queryset.filter(start_date__gte=date_from)
            
            date_to = self.request.query_params.get('date_to')
            if date_to:
                queryset = queryset.filter(start_date__lte=date_to)
            
            return queryset
        except Exception as e:
            # Log the error and return a safe queryset
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error in EventViewSet.get_queryset: {str(e)}", exc_info=True)
            # Return a safe queryset with only published events
            return Event.objects.filter(status='published').select_related('organizer', 'category')
    
    def get_serializer_context(self):
        """Add request to serializer context."""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    def get_permissions(self):
        """Set permissions based on action."""
        if self.action in ['destroy', 'moderate']:
            # Only admins can delete/moderate
            return [IsAuthenticated(), IsAdminOrClassLeader()]
        elif self.action == 'create':
            # Only verified users can create (admins shouldn't create directly)
            return [IsAuthenticated(), IsVerifiedOrReadOnly()]
        elif self.action in ['update', 'partial_update']:
            # Only organizer or admin can update
            return [IsAuthenticated(), IsVerifiedOrReadOnly()]
        return [IsVerifiedOrReadOnly()]
    
    def perform_create(self, serializer):
        """Create event (only verified users, not admins)."""
        # Prevent admins from creating events directly
        if (self.request.user.is_staff or 
            self.request.user.is_superuser or 
            self.request.user.role == 'admin'):
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied('Les administrateurs ne peuvent pas créer d\'événements directement. Les étudiants et responsables de classe gèrent les événements.')
        
        event = serializer.save(organizer=self.request.user)
        invalidate_feed_cache()
        
        # Create notification for organizer's friends/followers about new event
        # Only if event is published
        if event.status == 'published':
            from notifications.utils import create_bulk_notifications
            from social.models import Follow, Friendship
            
            # Get followers and friends
            followers = Follow.objects.filter(
                following=self.request.user
            ).values_list('follower', flat=True)
            
            friends = Friendship.objects.filter(
                Q(from_user=self.request.user, status='accepted') |
                Q(to_user=self.request.user, status='accepted')
            ).values_list('from_user', 'to_user')
            
            # Flatten friends list
            friend_ids = set()
            for from_user, to_user in friends:
                if from_user != self.request.user.id:
                    friend_ids.add(from_user)
                if to_user != self.request.user.id:
                    friend_ids.add(to_user)
            
            # Combine and create notifications
            all_recipients = list(set(list(followers) + list(friend_ids)))
            
            if all_recipients:
                create_bulk_notifications(
                    recipients=all_recipients,
                    notification_type='event_created',
                    title=f'Nouvel événement : {event.title}',
                    message=f'{self.request.user.username} a créé un nouvel événement : "{event.title}"',
                    related_object_type='event',
                    related_object_id=event.id,
                    use_async=True
                )
    
    def retrieve(self, request, *args, **kwargs):
        """Retrieve event and increment views."""
        instance = self.get_object()
        
        # Check cache for popular events
        from core.cache import get_cached_event_popular, cache_event_popular
        
        if instance.is_featured or instance.participants_count > 50:
            cached = get_cached_event_popular(str(instance.id))
            if cached:
                # Return cached data but still increment views
                instance.views_count += 1
                instance.save(update_fields=['views_count'])
                return Response(cached)
        
        instance.views_count += 1
        instance.save(update_fields=['views_count'])
        serializer = self.get_serializer(instance)
        data = serializer.data
        
        # Cache if popular
        if instance.is_featured or instance.participants_count > 50:
            cache_event_popular(str(instance.id), data)
        
        return Response(data)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def participate(self, request, pk=None):
        """Participate in event."""
        event = self.get_object()
        user = request.user
        
        participation, created = Participation.objects.get_or_create(
            user=user,
            event=event
        )
        
        if created:
            event.participants_count += 1
            event.save(update_fields=['participants_count'])
            invalidate_feed_cache()
            
            # Create notification for event organizer
            from notifications.utils import create_notification
            create_notification(
                recipient=event.organizer,
                notification_type='participation',
                title=f'Nouvelle participation à {event.title}',
                message=f'{user.username} participe à votre événement "{event.title}"',
                related_object_type='event',
                related_object_id=event.id,
                use_async=True
            )
            
            return Response({'message': 'Participation enregistrée.'}, status=status.HTTP_201_CREATED)
        
        return Response({'message': 'Déjà participant.'}, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['delete'], permission_classes=[IsAuthenticated])
    def leave(self, request, pk=None):
        """Leave event."""
        event = self.get_object()
        user = request.user
        
        try:
            participation = Participation.objects.get(user=user, event=event)
            participation.delete()
            event.participants_count = max(0, event.participants_count - 1)
            event.save(update_fields=['participants_count'])
            invalidate_feed_cache()
            return Response({'message': 'Participation annulée.'}, status=status.HTTP_200_OK)
        except Participation.DoesNotExist:
            return Response({'error': 'Pas de participation trouvée.'}, 
                          status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def like(self, request, pk=None):
        """Like event."""
        event = self.get_object()
        user = request.user
        
        like, created = EventLike.objects.get_or_create(user=user, event=event)
        
        if created:
            event.likes_count += 1
            event.save(update_fields=['likes_count'])
            
            # Create notification for event organizer (only if not self-like)
            if event.organizer != user:
                from notifications.utils import create_notification
                create_notification(
                    recipient=event.organizer,
                    notification_type='like',
                    title=f'{user.username} a aimé votre événement',
                    message=f'{user.username} a aimé votre événement "{event.title}"',
                    related_object_type='event',
                    related_object_id=event.id,
                    use_async=True
                )
            
            return Response({'message': 'Événement liké.'}, status=status.HTTP_201_CREATED)
        
        return Response({'message': 'Déjà liké.'}, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['delete'], permission_classes=[IsAuthenticated])
    def unlike(self, request, pk=None):
        """Unlike event."""
        event = self.get_object()
        user = request.user
        
        try:
            like = EventLike.objects.get(user=user, event=event)
            like.delete()
            event.likes_count = max(0, event.likes_count - 1)
            event.save(update_fields=['likes_count'])
            return Response({'message': 'Like retiré.'}, status=status.HTTP_200_OK)
        except EventLike.DoesNotExist:
            return Response({'error': 'Like non trouvé.'}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['get'])
    def participants(self, request, pk=None):
        """Get event participants."""
        event = self.get_object()
        participations = Participation.objects.filter(event=event).select_related('user')
        serializer = ParticipationSerializer(participations, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get', 'post'])
    def comments(self, request, pk=None):
        """Get or create comments."""
        event = self.get_object()
        
        if request.method == 'GET':
            comments = EventComment.objects.filter(event=event).select_related('user')
            serializer = EventCommentSerializer(comments, many=True)
            return Response(serializer.data)
        
        # POST - Create comment
        serializer = EventCommentSerializer(data=request.data)
        if serializer.is_valid():
            comment = serializer.save(event=event, user=request.user)
            event.comments_count += 1
            event.save(update_fields=['comments_count'])
            
            # Create notification for event organizer (only if not self-comment)
            if event.organizer != request.user:
                from notifications.utils import create_notification
                create_notification(
                    recipient=event.organizer,
                    notification_type='comment',
                    title=f'Nouveau commentaire sur {event.title}',
                    message=f'{request.user.username} a commenté votre événement "{event.title}": {comment.content[:100]}{"..." if len(comment.content) > 100 else ""}',
                    related_object_type='event',
                    related_object_id=event.id,
                    use_async=True
                )
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def favorite(self, request, pk=None):
        """Add event to favorites."""
        event = self.get_object()
        user = request.user
        
        favorite, created = EventFavorite.objects.get_or_create(user=user, event=event)
        
        if created:
            return Response({'message': 'Événement ajouté aux favoris.'}, status=status.HTTP_201_CREATED)
        
        return Response({'message': 'Déjà dans les favoris.'}, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['delete'], permission_classes=[IsAuthenticated])
    def unfavorite(self, request, pk=None):
        """Remove event from favorites."""
        event = self.get_object()
        user = request.user
        
        try:
            favorite = EventFavorite.objects.get(user=user, event=event)
            favorite.delete()
            return Response({'message': 'Événement retiré des favoris.'}, status=status.HTTP_200_OK)
        except EventFavorite.DoesNotExist:
            return Response({'error': 'Favori non trouvé.'}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def favorites(self, request):
        """Get user's favorite events."""
        favorites = EventFavorite.objects.filter(user=request.user).select_related('event', 'event__organizer', 'event__category')
        events = [favorite.event for favorite in favorites]
        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'], permission_classes=[IsAuthenticated])
    def analytics(self, request, pk=None):
        """Get analytics for an event (organizer only)."""
        event = self.get_object()
        
        # Check if user is the organizer
        if event.organizer != request.user:
            return Response(
                {'error': 'Only event organizer can view analytics.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        analytics_data = get_event_analytics(event.id)
        return Response(analytics_data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def dashboard(self, request):
        """Get organizer dashboard analytics."""
        dashboard_data = get_organizer_dashboard(request.user.id)
        return Response(dashboard_data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], permission_classes=[AllowAny])
    def nearby(self, request):
        """Get events nearby a location."""
        latitude = request.query_params.get('lat')
        longitude = request.query_params.get('lng')
        radius = float(request.query_params.get('radius', 10))  # Default 10km
        
        if not latitude or not longitude:
            return Response(
                {'error': 'lat and lng parameters are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            latitude = float(latitude)
            longitude = float(longitude)
        except ValueError:
            return Response(
                {'error': 'Invalid latitude or longitude.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        nearby_events = get_nearby_events(latitude, longitude, radius_km=radius)
        
        # Serialize with distance
        serializer = self.get_serializer(nearby_events, many=True)
        data = serializer.data
        
        # Add distance to each event
        for i, event in enumerate(nearby_events):
            data[i]['distance_km'] = event.distance_km
        
        return Response(data, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def invite(self, request, pk=None):
        """Invite users to an event."""
        event = self.get_object()
        user_ids = request.data.get('user_ids', [])
        emails = request.data.get('emails', [])
        
        if not user_ids and not emails:
            return Response(
                {'error': 'user_ids or emails are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        invitations_created = []
        
        # Invite by user IDs
        for user_id in user_ids:
            try:
                invitee = User.objects.get(id=user_id)
                invitation, created = EventInvitation.objects.get_or_create(
                    event=event,
                    inviter=request.user,
                    invitee=invitee,
                    defaults={'status': 'pending'}
                )
                if created:
                    invitations_created.append(str(invitation.id))
                    # Create notification (use utils for consistency)
                    from notifications.utils import create_notification
                    create_notification(
                        recipient=invitee,
                        notification_type='event_invitation',
                        title=f'Invitation à {event.title}',
                        message=f'{request.user.username} vous a invité à {event.title}',
                        related_object_type='event',
                        related_object_id=event.id,
                        use_async=True  # Use async for better performance
                    )
            except User.DoesNotExist:
                continue
        
        # Invite by emails
        for email in emails:
            try:
                invitee = User.objects.get(email=email)
                invitation, created = EventInvitation.objects.get_or_create(
                    event=event,
                    inviter=request.user,
                    invitee=invitee,
                    defaults={'status': 'pending'}
                )
                if created:
                    invitations_created.append(str(invitation.id))
            except User.DoesNotExist:
                # Create invitation for non-registered user
                invitation = EventInvitation.objects.create(
                    event=event,
                    inviter=request.user,
                    invitee_email=email,
                    status='pending'
                )
                invitations_created.append(str(invitation.id))
                # TODO: Send email invitation
        
        return Response({
            'message': f'{len(invitations_created)} invitation(s) envoyée(s).',
            'invitations_created': invitations_created
        }, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def share(self, request, pk=None):
        """Generate share link for an event."""
        event = self.get_object()
        
        # Generate share code
        share_code = f"SHARE{secrets.token_hex(8).upper()}"
        
        # Store in cache or create share record
        from core.cache import redis_client
        share_key = f'event_share:{share_code}'
        redis_client.setex(share_key, 86400 * 7, str(event.id))  # 7 days
        
        share_url = f"{request.build_absolute_uri('/')}events/share/{share_code}"
        
        return Response({
            'share_url': share_url,
            'share_code': share_code,
            'expires_in_days': 7
        }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated, IsAdminOrClassLeader])
    def moderate(self, request, pk=None):
        """Moderate event (admin only): delete or change status."""
        event = self.get_object()
        action = request.data.get('action')  # 'delete', 'publish', 'cancel', 'draft'
        
        if action == 'delete':
            event.delete()
            invalidate_feed_cache()
            return Response({'message': 'Événement supprimé avec succès.'}, status=status.HTTP_200_OK)
        elif action in ['publish', 'cancel', 'draft']:
            event.status = action if action != 'publish' else 'published'
            event.save(update_fields=['status'])
            invalidate_feed_cache()
            return Response({
                'message': f'Statut de l\'événement modifié en "{event.status}".',
                'status': event.status
            }, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Action invalide. Utilisez: delete, publish, cancel, ou draft.'}, 
                          status=status.HTTP_400_BAD_REQUEST)


class CalendarViewSet(viewsets.ViewSet):
    """ViewSet for user calendar."""
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def events(self, request):
        """Get user's calendar events."""
        start_date = request.query_params.get('start_date')
        end_date = request.query_params.get('end_date')
        
        events_data = get_user_calendar_events(
            request.user.id,
            start_date=start_date,
            end_date=end_date
        )
        
        # Serialize events
        serializer = EventSerializer([e['event'] for e in events_data], many=True)
        result = serializer.data
        
        # Add metadata
        for i, event_data in enumerate(events_data):
            result[i]['calendar_type'] = event_data['type']
            if event_data['type'] == 'participation':
                result[i]['participated_at'] = event_data['participated_at'].isoformat()
            else:
                result[i]['favorited_at'] = event_data['favorited_at'].isoformat()
        
        return Response(result, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'])
    def export(self, request):
        """Export user calendar as iCal file."""
        include_favorites = request.query_params.get('include_favorites', 'true').lower() == 'true'
        
        cal = generate_user_calendar(request.user.id, include_favorites=include_favorites)
        
        from django.http import HttpResponse
        response = HttpResponse(cal.to_ical(), content_type='text/calendar')
        response['Content-Disposition'] = f'attachment; filename="campuslink_calendar_{request.user.username}.ics"'
        return response
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def recommended(self, request):
        """Get recommended events for current user."""
        limit = int(request.query_params.get('limit', 10))
        
        recommended = get_recommended_events(request.user.id, limit=limit)
        serializer = EventSerializer(recommended, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

