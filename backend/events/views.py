"""
Views for Events app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.exceptions import NotFound
from django.http import Http404
from django.db import models
from django.db.models import Q, Case, When, F
from django.utils import timezone
from .models import Category, Event, Participation, EventComment, EventLike, EventFavorite, EventShare, EventFilterPreference
from .serializers import (
    CategorySerializer, EventSerializer, ParticipationSerializer,
    EventCommentSerializer, EventLikeSerializer, EventFilterPreferenceSerializer
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
        """Get categories from database."""
        # Note: Cache functions removed as they were causing import errors
        # Can be re-implemented later if Redis is available
        return Category.objects.all().order_by('name')


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
                # Non-admins can see published events OR their own events (even drafts)
                if (hasattr(self.request, 'user') and 
                    self.request.user.is_authenticated):
                    # Allow users to see published events OR their own events
                    queryset = Event.objects.filter(
                        Q(status='published') | Q(organizer=self.request.user)
                    )
                else:
                    # Anonymous users can only see published events
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
                # Use direct university field if available, otherwise fallback to organizer's university
                queryset = queryset.filter(
                    Q(university_id=university) |
                    Q(university__isnull=True, organizer__profile__university_id=university)
                )
            
            # Auto-filter for university admins
            if (hasattr(self.request, 'user') and 
                self.request.user.is_authenticated and
                self.request.user.role == 'university_admin' and
                self.request.user.managed_university):
                queryset = queryset.filter(
                    Q(university=self.request.user.managed_university) |
                    Q(university__isnull=True, organizer__profile__university=self.request.user.managed_university)
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
            
            # Advanced filters
            category = self.request.query_params.get('category')
            if category:
                queryset = queryset.filter(category_id=category)
            
            is_free = self.request.query_params.get('is_free')
            if is_free is not None:
                queryset = queryset.filter(is_free=is_free.lower() == 'true')
            
            price_min = self.request.query_params.get('price_min')
            if price_min:
                try:
                    queryset = queryset.filter(price__gte=float(price_min))
                except ValueError:
                    pass
            
            price_max = self.request.query_params.get('price_max')
            if price_max:
                try:
                    queryset = queryset.filter(price__lte=float(price_max))
                except ValueError:
                    pass
            
            # Geographic filters (for map) - Using GeoDjango PointField
            lat = self.request.query_params.get('lat')
            lng = self.request.query_params.get('lng')
            radius = self.request.query_params.get('radius', 10)  # Default 10km
            
            if lat and lng:
                try:
                    lat_float = float(lat)
                    lng_float = float(lng)
                    radius_float = float(radius)
                    
                    # Use GeoDjango for precise distance calculation
                    try:
                        from django.contrib.gis.geos import Point
                        from django.contrib.gis.measure import D
                        from django.contrib.gis.db.models.functions import Distance
                        
                        user_location = Point(lng_float, lat_float, srid=4326)
                        
                        # Use location_point if available, otherwise fallback to location_lat/lng
                        queryset = queryset.filter(
                            Q(location_point__isnull=False) | 
                            Q(location_lat__isnull=False, location_lng__isnull=False)
                        )
                        
                        # Annotate with distance using location_point (preferred) or lat/lng
                        queryset = queryset.annotate(
                            distance=Case(
                                When(location_point__isnull=False,
                                     then=Distance('location_point', user_location)),
                                default=Distance(
                                    Point(F('location_lng'), F('location_lat'), srid=4326),
                                    user_location
                                ),
                                output_field=models.FloatField()
                            )
                        ).filter(
                            distance__lte=D(km=radius_float)
                        ).order_by('distance')
                    except ImportError:
                        # If GIS is not available, use simple bounding box approximation
                        # Approximate: 1 degree ≈ 111 km
                        lat_delta = radius_float / 111.0
                        lng_delta = radius_float / (111.0 * abs(lat_float / 90.0) if lat_float != 0 else 1)
                        
                        queryset = queryset.filter(
                            Q(location_point__isnull=False) |
                            Q(
                                location_lat__isnull=False,
                                location_lng__isnull=False,
                                location_lat__gte=lat_float - lat_delta,
                                location_lat__lte=lat_float + lat_delta,
                                location_lng__gte=lng_float - lng_delta,
                                location_lng__lte=lng_float + lng_delta
                            )
                        )
                except (ValueError, TypeError):
                    # Invalid coordinates, skip geographic filter
                    pass
            
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
    
    def list(self, request, *args, **kwargs):
        """List events with error handling."""
        try:
            return super().list(request, *args, **kwargs)
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error in EventViewSet.list: {str(e)}", exc_info=True)
            # Try to return a simplified response
            try:
                queryset = self.get_queryset()
                # Use basic serializer without nested relations
                from .serializers import EventSerializer
                serializer = EventSerializer(queryset[:50], many=True, context={'request': request})
                return Response(serializer.data, status=status.HTTP_200_OK)
            except Exception as e2:
                logger.error(f"Error in fallback list: {str(e2)}", exc_info=True)
                return Response(
                    {'error': 'Erreur lors de la récupération des événements. Veuillez réessayer plus tard.'},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
    
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
            self.request.user.role == 'admin' or
            self.request.user.role == 'university_admin'):
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied('Les administrateurs ne peuvent pas créer d\'événements directement. Les étudiants et responsables de classe gèrent les événements.')
        
        # Auto-assign university from organizer's profile
        user_university = None
        if hasattr(self.request.user, 'profile') and self.request.user.profile:
            user_university = self.request.user.profile.university
        
        event = serializer.save(organizer=self.request.user, university=user_university)
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
    
    def get_object(self):
        """Override to better handle event retrieval, including user's own events."""
        pk = self.kwargs.get('pk')
        
        # Ignore special action routes like 'recommended'
        if pk in ['recommended', 'upcoming', 'past', 'my-events']:
            raise Http404("Cette route n'est pas un événement spécifique")
        
        try:
            return super().get_object()
        except Exception as e:
            # If event not found in queryset, try to get it directly if user is the organizer
            if pk and hasattr(self.request, 'user') and self.request.user.is_authenticated:
                try:
                    from .models import Event
                    event = Event.objects.get(pk=pk)
                    # Allow access if user is the organizer
                    if event.organizer == self.request.user:
                        return event
                except Event.DoesNotExist:
                    pass
            # Re-raise the original exception
            raise
    
    def retrieve(self, request, *args, **kwargs):
        """Retrieve event and increment views."""
        pk = self.kwargs.get('pk')
        # Skip retrieve for action routes
        if pk in ['recommended', 'upcoming', 'past', 'my-events']:
            from django.http import Http404
            raise Http404("Cette route n'est pas un événement spécifique")
        
        try:
            instance = self.get_object()
            
            # Increment views count
            instance.views_count += 1
            instance.save(update_fields=['views_count'])
            
            try:
                serializer = self.get_serializer(instance)
                data = serializer.data
            except Exception as e:
                # If serialization fails, try with minimal data
                import logging
                logger = logging.getLogger(__name__)
                logger.error(f"Error serializing event {instance.id}: {str(e)}", exc_info=True)
                # Return basic event data without nested serializers
                data = {
                    'id': str(instance.id),
                    'title': instance.title,
                    'description': instance.description,
                    'start_date': instance.start_date.isoformat() if instance.start_date else None,
                    'end_date': instance.end_date.isoformat() if instance.end_date else None,
                    'location': instance.location,
                    'status': instance.status,
                    'capacity': instance.capacity,
                    'price': float(instance.price) if instance.price else 0,
                    'is_free': instance.is_free,
                    'views_count': instance.views_count,
                    'participants_count': instance.participants_count,
                    'likes_count': instance.likes_count,
                    'organizer': {
                        'id': str(instance.organizer.id),
                        'username': instance.organizer.username,
                        'email': instance.organizer.email,
                    } if instance.organizer else None,
                    'university': None,  # Will be set by get_university if available
                    'category': None,
                    'is_participating': False,
                    'is_liked': False,
                }
                # Try to get university safely
                if instance.university:
                    try:
                        from users.serializers import UniversityBasicSerializer
                        data['university'] = UniversityBasicSerializer(instance.university).data
                    except:
                        pass
            
            return Response(data)
        except NotFound:
            # Event not found
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f"Event {kwargs.get('pk')} not found")
            return Response(
                {'error': 'Événement introuvable.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error retrieving event {kwargs.get('pk')}: {str(e)}", exc_info=True)
            return Response(
                {'error': f'Erreur lors de la récupération de l\'événement: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def participate(self, request, pk=None):
        """Participate in event."""
        event = self.get_object()
        user = request.user
        
        # Validations
        # 1. Check if event is published
        if event.status != 'published':
            return Response(
                {'error': 'Vous ne pouvez participer qu\'aux événements publiés.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # 2. Check if event is not cancelled or completed
        if event.status in ['cancelled', 'completed']:
            return Response(
                {'error': f'Cet événement est {event.status}.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # 3. Check if event has not passed
        # Utiliser end_date si disponible, sinon start_date
        # On peut rejoindre un événement tant qu'il n'est pas terminé (end_date < now)
        from django.utils import timezone
        now = timezone.now()
        
        # Si l'événement a une date de fin, vérifier qu'elle n'est pas passée
        if event.end_date and event.end_date < now:
            return Response(
                {'error': 'Cet événement est terminé.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Si l'événement n'a pas de date de fin mais a une date de début passée
        # On peut toujours rejoindre (événement en cours)
        # Seulement si l'événement n'a ni date de début ni date de fin, c'est un problème
        if not event.start_date and not event.end_date:
            return Response(
                {'error': 'Cet événement n\'a pas de date valide.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # 4. Check if user is not the organizer
        if event.organizer == user:
            return Response(
                {'error': 'Vous êtes l\'organisateur de cet événement.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # 5. Check if user is verified (optional, but recommended)
        if not user.is_verified:
            return Response(
                {'error': 'Vous devez être vérifié pour participer à un événement.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # 6. Check capacity
        if event.capacity and event.participants_count >= event.capacity:
            return Response(
                {'error': 'Cet événement est complet.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if already participating
        if Participation.objects.filter(user=user, event=event).exists():
            return Response(
                {'message': 'Vous participez déjà à cet événement.'},
                status=status.HTTP_200_OK
            )
        
        # Create participation
        participation = Participation.objects.create(user=user, event=event)
        
        # Update participants count
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
        
        return Response({
            'message': 'Participation enregistrée.',
            'participation': ParticipationSerializer(participation).data
        }, status=status.HTTP_201_CREATED)
    
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
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def recommended(self, request):
        """Get recommended events for current user."""
        try:
            limit = int(request.query_params.get('limit', 10))
            
            # Validate limit
            if limit < 1 or limit > 50:
                limit = 10
            
            recommended = get_recommended_events(request.user.id, limit=limit)
            
            # Ensure we return a list (get_recommended_events may return empty list or QuerySet)
            if not recommended:
                return Response([], status=status.HTTP_200_OK)
            
            # Handle both list and QuerySet
            if isinstance(recommended, list):
                events_list = recommended
            else:
                events_list = list(recommended)
            
            serializer = EventSerializer(events_list, many=True, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)
        except ValueError:
            # Invalid limit parameter
            return Response(
                {'error': 'Paramètre limit invalide.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error in recommended events: {str(e)}", exc_info=True)
            # Return empty list instead of error to prevent frontend issues
            return Response([], status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def my_events(self, request):
        """Get user's events (organized, participating, favorites)."""
        try:
            user = request.user
            event_type = request.query_params.get('type', 'all')  # all, organized, participating, favorites
            
            events = []
            
            if event_type in ['all', 'organized']:
                # Events organized by user
                organized = Event.objects.filter(organizer=user).select_related(
                    'organizer', 'category', 'university'
                ).prefetch_related(
                    'participations__user',
                    'likes__user',
                    'favorited_by__user'
                ).order_by('-start_date')
                events.extend(organized)
            
            if event_type in ['all', 'participating']:
                # Events user is participating in
                participations = Participation.objects.filter(user=user).select_related(
                    'event', 'event__organizer', 'event__category', 'event__university'
                ).prefetch_related(
                    'event__participations__user',
                    'event__likes__user',
                    'event__favorited_by__user'
                ).order_by('-event__start_date')
                participating_events = [p.event for p in participations]
                events.extend(participating_events)
            
            if event_type in ['all', 'favorites']:
                # Favorite events
                favorites = EventFavorite.objects.filter(user=user).select_related(
                    'event', 'event__organizer', 'event__category', 'event__university'
                ).prefetch_related(
                    'event__participations__user',
                    'event__likes__user',
                    'event__favorited_by__user'
                ).order_by('-event__start_date')
                favorite_events = [f.event for f in favorites]
                events.extend(favorite_events)
            
            # Remove duplicates and sort by start_date
            seen_ids = set()
            unique_events = []
            for event in events:
                if event.id not in seen_ids:
                    seen_ids.add(event.id)
                    unique_events.append(event)
            
            # Sort by start_date (upcoming first)
            unique_events.sort(key=lambda e: e.start_date if e.start_date else timezone.now())
            
            # Serialize with error handling
            try:
                serializer = EventSerializer(unique_events, many=True, context={'request': request})
                return Response(serializer.data)
            except Exception as e:
                import logging
                logger = logging.getLogger(__name__)
                logger.error(f"Error serializing events in my_events: {str(e)}", exc_info=True)
                # Return minimal data if serialization fails
                minimal_data = []
                for event in unique_events:
                    try:
                        minimal_data.append({
                            'id': str(event.id),
                            'title': event.title,
                            'description': event.description,
                            'start_date': event.start_date.isoformat() if event.start_date else None,
                            'end_date': event.end_date.isoformat() if event.end_date else None,
                            'location': event.location,
                            'status': event.status,
                            'organizer': {
                                'id': str(event.organizer.id),
                                'username': event.organizer.username,
                            } if event.organizer else None,
                        })
                    except Exception as e2:
                        logger.warning(f"Error serializing event {event.id}: {e2}")
                        continue
                return Response(minimal_data, status=status.HTTP_200_OK)
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error in my_events: {str(e)}", exc_info=True)
            return Response(
                {'error': 'Erreur lors de la récupération de vos événements.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

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
    
    @action(detail=False, methods=['delete'], permission_classes=[IsAuthenticated])
    def clear_history(self, request):
        """Clear user's event participation history."""
        user = request.user
        
        try:
            # Delete all participations
            participations = Participation.objects.filter(user=user)
            count = participations.count()
            
            # Update event participants_count before deleting
            for participation in participations:
                event = participation.event
                event.participants_count = max(0, event.participants_count - 1)
                event.save(update_fields=['participants_count'])
            
            # Delete all participations
            participations.delete()
            
            # Also clear favorites and likes if requested
            clear_all = request.query_params.get('clear_all', 'false').lower() == 'true'
            if clear_all:
                EventFavorite.objects.filter(user=user).delete()
                EventLike.objects.filter(user=user).delete()
            
            invalidate_feed_cache()
            
            return Response({
                'message': f'Historique supprimé avec succès ({count} participation(s) supprimée(s)).',
                'deleted_count': count
            }, status=status.HTTP_200_OK)
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error clearing event history: {str(e)}", exc_info=True)
            return Response(
                {'error': 'Erreur lors de la suppression de l\'historique.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    
    @action(detail=True, methods=['get', 'post'], permission_classes=[AllowAny])
    def share(self, request, pk=None):
        """
        Get share links for an event or track a share.
        GET: Returns share URLs for different platforms
        POST: Tracks a share event
        """
        try:
            event = self.get_object()
        except NotFound:
            return Response(
                {'error': 'Événement introuvable.'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        if request.method == 'GET':
            # Generate share URLs
            from django.conf import settings
            from urllib.parse import quote
            
            # Base URL for the frontend
            frontend_url = getattr(settings, 'FRONTEND_URL', 'http://localhost:3000')
            event_url = f"{frontend_url}/events/{event.id}"
            
            # Event details for sharing
            event_title = quote(event.title)
            event_description = quote(event.description[:200] if event.description else '')
            
            share_urls = {
                'facebook': f"https://www.facebook.com/sharer/sharer.php?u={quote(event_url)}",
                'twitter': f"https://twitter.com/intent/tweet?url={quote(event_url)}&text={event_title}",
                'linkedin': f"https://www.linkedin.com/sharing/share-offsite/?url={quote(event_url)}",
                'whatsapp': f"https://wa.me/?text={event_title}%20{quote(event_url)}",
                'email': f"mailto:?subject={event_title}&body={event_description}%20{quote(event_url)}",
                'link': event_url,  # Direct link to copy
            }
            
            return Response({
                'event_id': str(event.id),
                'event_title': event.title,
                'share_urls': share_urls,
                'share_count': EventShare.objects.filter(event=event).count(),
            })
        
        elif request.method == 'POST':
            # Track the share
            platform = request.data.get('platform', 'link')
            user = request.user if request.user.is_authenticated else None
            
            # Get IP address
            x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
            if x_forwarded_for:
                ip_address = x_forwarded_for.split(',')[0]
            else:
                ip_address = request.META.get('REMOTE_ADDR')
            
            # Create share record
            share = EventShare.objects.create(
                event=event,
                user=user,
                platform=platform,
                ip_address=ip_address
            )
            
            # Increment share count on event (if we add this field)
            # For now, we just track it in EventShare model
            
            return Response({
                'success': True,
                'message': 'Partage enregistré avec succès',
                'share_id': str(share.id),
                'total_shares': EventShare.objects.filter(event=event).count(),
            }, status=status.HTTP_201_CREATED)
    
    @action(detail=False, methods=['get'], permission_classes=[AllowAny])
    def map_events(self, request):
        """Get events with geolocation for map display using GeoDjango."""
        try:
            # Filter events with location (only use lat/lng fields which are always available)
            queryset = self.get_queryset().filter(
                status='published',
                location_lat__isnull=False,
                location_lng__isnull=False
            )
            
            # Apply filters
            lat = request.query_params.get('lat')
            lng = request.query_params.get('lng')
            radius = request.query_params.get('radius', 50)  # Default 50km for map
            
            if lat and lng:
                try:
                    lat_float = float(lat)
                    lng_float = float(lng)
                    radius_float = float(radius)
                    
                    # Try to use GeoDjango if available
                    try:
                        from django.contrib.gis.geos import Point
                        from django.contrib.gis.measure import D
                        from django.contrib.gis.db.models.functions import Distance
                        
                        user_location = Point(float(lng), float(lat), srid=4326)
                        
                        # Check if location_point field exists in model
                        if hasattr(Event, 'location_point'):
                            # Use location_point if available
                            queryset = queryset.annotate(
                                distance=Case(
                                    When(location_point__isnull=False,
                                         then=Distance('location_point', user_location)),
                                    default=Distance(
                                        Point(F('location_lng'), F('location_lat'), srid=4326),
                                        user_location
                                    ),
                                    output_field=models.FloatField()
                                )
                            ).filter(
                                distance__lte=D(km=radius_float)
                            ).order_by('distance')
                        else:
                            # Fallback to bounding box if location_point doesn't exist
                            lat_delta = radius_float / 111.0
                            lng_delta = radius_float / (111.0 * abs(lat_float / 90.0) if lat_float != 0 else 1)
                            
                            queryset = queryset.filter(
                                location_lat__gte=lat_float - lat_delta,
                                location_lat__lte=lat_float + lat_delta,
                                location_lng__gte=lng_float - lng_delta,
                                location_lng__lte=lng_float + lng_delta
                            )
                    except (ImportError, AttributeError):
                        # If GIS is not available, use simple bounding box
                        lat_delta = radius_float / 111.0
                        lng_delta = radius_float / (111.0 * abs(lat_float / 90.0) if lat_float != 0 else 1)
                        
                        queryset = queryset.filter(
                            location_lat__gte=lat_float - lat_delta,
                            location_lat__lte=lat_float + lat_delta,
                            location_lng__gte=lng_float - lng_delta,
                            location_lng__lte=lng_float + lng_delta
                        )
                except (ValueError, TypeError) as e:
                    import logging
                    logger = logging.getLogger(__name__)
                    logger.warning(f"Invalid lat/lng/radius parameters: {str(e)}")
                    # Return empty result if parameters are invalid
                    queryset = queryset.none()
            
            # Limit results for map
            queryset = queryset[:100]
            
            serializer = EventSerializer(queryset, many=True, context={'request': request})
            return Response({
                'events': serializer.data,
                'count': len(serializer.data)
            }, status=status.HTTP_200_OK)
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error in map_events: {str(e)}", exc_info=True)
            return Response(
                {'error': 'Erreur lors de la récupération des événements pour la carte.', 'details': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class EventFilterPreferenceViewSet(viewsets.ModelViewSet):
    """ViewSet for event filter preferences."""
    serializer_class = EventFilterPreferenceSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Get filter preferences for current user."""
        return EventFilterPreference.objects.filter(user=self.request.user).order_by('-is_default', '-updated_at')
    
    def perform_create(self, serializer):
        """Create filter preference for current user."""
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def default(self, request):
        """Get default filter preference."""
        try:
            default_filter = EventFilterPreference.objects.filter(
                user=request.user,
                is_default=True
            ).first()
            
            if default_filter:
                serializer = EventFilterPreferenceSerializer(default_filter, context={'request': request})
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response(
                    {'message': 'Aucun filtre par défaut trouvé.'},
                    status=status.HTTP_404_NOT_FOUND
                )
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error getting default filter: {str(e)}", exc_info=True)
            return Response(
                {'error': 'Erreur lors de la récupération du filtre par défaut.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

