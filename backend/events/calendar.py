"""
Calendar utilities for events.
"""
from icalendar import Calendar, Event as ICalEvent
from datetime import datetime
from django.utils import timezone
from .models import Event, Participation, EventFavorite


def generate_user_calendar(user_id, include_favorites=True):
    """
    Generate iCal calendar for a user's events.
    
    Args:
        user_id: User ID
        include_favorites: Include favorited events
    
    Returns:
        Calendar: iCal calendar object
    """
    cal = Calendar()
    cal.add('prodid', '-//CampusLink//Event Calendar//EN')
    cal.add('version', '2.0')
    
    # Get user's participations
    participations = Participation.objects.filter(
        user_id=user_id
    ).select_related('event')
    
    # Get user's favorites if requested
    if include_favorites:
        favorites = EventFavorite.objects.filter(
            user_id=user_id
        ).select_related('event')
        favorite_events = [f.event for f in favorites]
    else:
        favorite_events = []
    
    # Add events from participations
    for participation in participations:
        event = participation.event
        ical_event = ICalEvent()
        ical_event.add('summary', event.title)
        ical_event.add('description', event.description)
        ical_event.add('dtstart', event.start_date)
        if event.end_date:
            ical_event.add('dtend', event.end_date)
        ical_event.add('location', event.location)
        ical_event.add('url', f"https://campuslink.sn/events/{event.id}")
        cal.add_component(ical_event)
    
    # Add favorite events (if not already added)
    participation_event_ids = {p.event.id for p in participations}
    for event in favorite_events:
        if event.id not in participation_event_ids:
            ical_event = ICalEvent()
            ical_event.add('summary', event.title)
            ical_event.add('description', event.description)
            ical_event.add('dtstart', event.start_date)
            if event.end_date:
                ical_event.add('dtend', event.end_date)
            ical_event.add('location', event.location)
            ical_event.add('url', f"https://campuslink.sn/events/{event.id}")
            cal.add_component(ical_event)
    
    return cal


def get_user_calendar_events(user_id, start_date=None, end_date=None):
    """
    Get user's calendar events (participations + favorites) for a date range.
    
    Args:
        user_id: User ID
        start_date: Start date filter (optional)
        end_date: End date filter (optional)
    
    Returns:
        list: List of events with metadata
    """
    # Get participations
    participations = Participation.objects.filter(
        user_id=user_id
    ).select_related('event', 'event__organizer', 'event__category')
    
    if start_date:
        participations = participations.filter(event__start_date__gte=start_date)
    if end_date:
        participations = participations.filter(event__start_date__lte=end_date)
    
    events_data = []
    for participation in participations:
        event = participation.event
        events_data.append({
            'event': event,
            'type': 'participation',
            'participated_at': participation.created_at,
        })
    
    # Get favorites
    favorites = EventFavorite.objects.filter(
        user_id=user_id
    ).select_related('event', 'event__organizer', 'event__category')
    
    if start_date:
        favorites = favorites.filter(event__start_date__gte=start_date)
    if end_date:
        favorites = favorites.filter(event__start_date__lte=end_date)
    
    participation_event_ids = {p.event.id for p in participations}
    for favorite in favorites:
        if favorite.event.id not in participation_event_ids:
            events_data.append({
                'event': favorite.event,
                'type': 'favorite',
                'favorited_at': favorite.created_at,
            })
    
    # Sort by start date
    events_data.sort(key=lambda x: x['event'].start_date)
    
    return events_data

