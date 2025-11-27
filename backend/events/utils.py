"""
Utility functions for events app.
"""
from math import radians, cos, sin, asin, sqrt
from django.db.models import Q


def haversine_distance(lat1, lon1, lat2, lon2):
    """
    Calculate the great circle distance between two points on Earth.
    
    Args:
        lat1, lon1: Latitude and longitude of first point
        lat2, lon2: Latitude and longitude of second point
    
    Returns:
        float: Distance in kilometers
    """
    # Convert to radians
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    
    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    
    # Radius of earth in kilometers
    r = 6371
    
    return c * r


def get_nearby_events(latitude, longitude, radius_km=10, limit=20):
    """
    Get events within a certain radius from a location.
    
    Args:
        latitude: Latitude of center point
        longitude: Longitude of center point
        radius_km: Radius in kilometers (default: 10km)
        limit: Maximum number of events to return
    
    Returns:
        QuerySet: Events within the radius, ordered by distance
    """
    from .models import Event
    
    # Get all events with coordinates
    events = Event.objects.filter(
        status='published',
        location_lat__isnull=False,
        location_lng__isnull=False
    ).exclude(
        location_lat=0,
        location_lng=0
    )
    
    # Calculate distance for each event and filter
    nearby_events = []
    for event in events:
        distance = haversine_distance(
            latitude, longitude,
            float(event.location_lat), float(event.location_lng)
        )
        if distance <= radius_km:
            event.distance_km = round(distance, 2)
            nearby_events.append(event)
    
    # Sort by distance
    nearby_events.sort(key=lambda x: x.distance_km)
    
    return nearby_events[:limit]

