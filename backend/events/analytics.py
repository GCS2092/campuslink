"""
Analytics utilities for events.
"""
from django.db.models import Count, Avg, Q, Sum
from django.utils import timezone
from datetime import timedelta
from .models import Event, Participation, EventLike, EventComment
from payments.models import Payment, Ticket


def get_event_analytics(event_id):
    """
    Get comprehensive analytics for an event.
    
    Returns:
        dict: Analytics data including views, participants, engagement, revenue, etc.
    """
    event = Event.objects.get(id=event_id)
    
    # Basic stats
    total_participants = event.participants_count
    total_likes = event.likes_count
    total_comments = EventComment.objects.filter(event=event).count()
    total_views = event.views_count
    
    # Participation stats
    participations = Participation.objects.filter(event=event)
    participation_rate = (total_participants / max(event.capacity, 1)) * 100 if event.capacity else None
    
    # Payment stats
    payments = Payment.objects.filter(event=event, status='completed')
    total_revenue = payments.aggregate(total=Sum('amount'))['total'] or 0
    total_commission = payments.aggregate(total=Sum('commission'))['total'] or 0
    total_tickets_sold = Ticket.objects.filter(event=event, payment__status='completed').count()
    tickets_used = Ticket.objects.filter(event=event, is_used=True).count()
    
    # Engagement metrics
    engagement_rate = ((total_likes + total_comments) / max(total_views, 1)) * 100 if total_views > 0 else 0
    
    # Demographics (if available)
    participants_by_university = participations.values(
        'user__profile__university'
    ).annotate(
        count=Count('id')
    ).order_by('-count')
    
    # Time-based stats
    participations_by_day = participations.extra(
        select={'day': 'date(created_at)'}
    ).values('day').annotate(count=Count('id')).order_by('day')
    
    return {
        'event_id': str(event.id),
        'event_title': event.title,
        'basic_stats': {
            'views': total_views,
            'participants': total_participants,
            'likes': total_likes,
            'comments': total_comments,
            'participation_rate': round(participation_rate, 2) if participation_rate else None,
        },
        'revenue_stats': {
            'total_revenue': float(total_revenue),
            'total_commission': float(total_commission),
            'net_revenue': float(total_revenue - total_commission),
            'tickets_sold': total_tickets_sold,
            'tickets_used': tickets_used,
            'ticket_usage_rate': round((tickets_used / max(total_tickets_sold, 1)) * 100, 2) if total_tickets_sold > 0 else 0,
        },
        'engagement': {
            'engagement_rate': round(engagement_rate, 2),
            'likes_per_view': round(total_likes / max(total_views, 1), 3) if total_views > 0 else 0,
            'comments_per_view': round(total_comments / max(total_views, 1), 3) if total_views > 0 else 0,
        },
        'demographics': {
            'participants_by_university': list(participants_by_university),
        },
        'timeline': {
            'participations_by_day': list(participations_by_day),
        }
    }


def get_organizer_dashboard(organizer_id):
    """
    Get dashboard analytics for an organizer.
    
    Returns:
        dict: Overall statistics for all events organized by user
    """
    events = Event.objects.filter(organizer_id=organizer_id)
    published_events = events.filter(status='published')
    
    # Overall stats
    total_events = events.count()
    published_count = published_events.count()
    total_participants = published_events.aggregate(total=Sum('participants_count'))['total'] or 0
    total_views = published_events.aggregate(total=Sum('views_count'))['total'] or 0
    total_likes = published_events.aggregate(total=Sum('likes_count'))['total'] or 0
    
    # Revenue stats
    payments = Payment.objects.filter(
        event__organizer_id=organizer_id,
        status='completed'
    )
    total_revenue = payments.aggregate(total=Sum('amount'))['total'] or 0
    total_commission = payments.aggregate(total=Sum('commission'))['total'] or 0
    
    # Recent events (last 30 days)
    thirty_days_ago = timezone.now() - timedelta(days=30)
    recent_events = published_events.filter(created_at__gte=thirty_days_ago)
    recent_participants = recent_events.aggregate(total=Sum('participants_count'))['total'] or 0
    
    # Upcoming events
    upcoming_events = published_events.filter(start_date__gte=timezone.now()).count()
    
    return {
        'organizer_id': str(organizer_id),
        'overview': {
            'total_events': total_events,
            'published_events': published_count,
            'upcoming_events': upcoming_events,
            'total_participants': total_participants,
            'total_views': total_views,
            'total_likes': total_likes,
        },
        'revenue': {
            'total_revenue': float(total_revenue),
            'total_commission': float(total_commission),
            'net_revenue': float(total_revenue - total_commission),
        },
        'recent_activity': {
            'events_last_30_days': recent_events.count(),
            'participants_last_30_days': recent_participants,
        },
        'top_events': list(
            published_events.order_by('-participants_count')[:5].values(
                'id', 'title', 'participants_count', 'views_count', 'likes_count', 'start_date'
            )
        )
    }

