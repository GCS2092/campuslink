"""
Recommendation engine for events.
"""
from django.db.models import Q, Count, F
from django.utils import timezone
from datetime import timedelta
from users.models import User
from .models import Event, Participation, EventLike, EventFavorite


def get_recommended_events(user_id, limit=10):
    """
    Get recommended events for a user based on:
    - User interests
    - Participation history
    - Popular events in user's university
    - Events liked by friends
    - Trending events
    
    Args:
        user_id: User ID
        limit: Maximum number of recommendations
    
    Returns:
        QuerySet: Recommended events
    """
    try:
        user = User.objects.select_related('profile').get(id=user_id)
    except User.DoesNotExist:
        return Event.objects.none()
    
    # Get user interests
    user_interests = user.profile.interests if hasattr(user, 'profile') and user.profile.interests else []
    
    # Get user's university
    user_university = user.profile.university if hasattr(user, 'profile') else None
    
    # Get events user already participated/liked/favorited (to exclude)
    participated_events = Participation.objects.filter(user=user).values_list('event_id', flat=True)
    liked_events = EventLike.objects.filter(user=user).values_list('event_id', flat=True)
    favorited_events = EventFavorite.objects.filter(user=user).values_list('event_id', flat=True)
    excluded_event_ids = set(participated_events) | set(liked_events) | set(favorited_events)
    
    # Base queryset: published events, future events
    base_queryset = Event.objects.filter(
        status='published',
        start_date__gte=timezone.now()
    ).exclude(id__in=excluded_event_ids)
    
    # Scoring system
    recommended_events = []
    
    for event in base_queryset[:limit * 3]:  # Get more to score
        score = 0
        
        # 1. University match (high weight)
        if user_university and hasattr(event.organizer, 'profile') and event.organizer.profile and event.organizer.profile.university == user_university:
            score += 50
        
        # 2. Interest match (if event category matches user interests)
        if user_interests and event.category:
            # Simple matching (can be improved)
            category_name_lower = event.category.name.lower()
            for interest in user_interests:
                if interest.lower() in category_name_lower or category_name_lower in interest.lower():
                    score += 30
                    break
        
        # 3. Popularity (participants, likes, views)
        score += min(event.participants_count * 2, 20)
        score += min(event.likes_count, 15)
        score += min(event.views_count / 10, 10)
        
        # 4. Featured events
        if event.is_featured:
            score += 25
        
        # 5. Recent events (prefer upcoming)
        days_until = (event.start_date - timezone.now()).days
        if days_until <= 7:
            score += 20
        elif days_until <= 30:
            score += 10
        
        # 6. Events from followed users
        from users.models import Follow
        if Follow.objects.filter(follower=user, following=event.organizer).exists():
            score += 15
        
        recommended_events.append((event, score))
    
    # Sort by score
    recommended_events.sort(key=lambda x: x[1], reverse=True)
    
    # Return top events
    return [event for event, score in recommended_events[:limit]]

