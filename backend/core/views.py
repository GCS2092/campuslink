"""
Core views for global functionality.
"""
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Q
from users.models import User
from events.models import Event
from groups.models import Group


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def global_search(request):
    """
    Global search across users, events, and groups.
    
    Query parameters:
    - q: Search query (required)
    - type: Filter by type (users, events, groups, all) - default: all
    - limit: Number of results per type (default: 10)
    """
    query = request.query_params.get('q', '').strip()
    search_type = request.query_params.get('type', 'all')
    try:
        limit = int(request.query_params.get('limit', 10))
        if limit < 1 or limit > 100:
            limit = 10
    except (ValueError, TypeError):
        limit = 10
    
    if not query:
        return Response(
            {'error': 'Query parameter "q" is required.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    results = {
        'query': query,
        'users': [],
        'events': [],
        'groups': [],
    }
    
    user = request.user
    
    # Search Users
    if search_type in ['all', 'users']:
        from users.serializers import UserBasicSerializer
        
        users_queryset = User.objects.filter(is_active=True).select_related('profile')
        
        # Apply role-based filtering
        if user.role == 'university_admin' and user.managed_university:
            users_queryset = users_queryset.filter(profile__university=user.managed_university)
        elif not (user.is_staff or user.is_superuser or user.role == 'admin'):
            users_queryset = users_queryset.filter(is_active=True)
        
        # Search in username, email, first_name, last_name
        users_queryset = users_queryset.filter(
            Q(username__icontains=query) |
            Q(email__icontains=query) |
            Q(first_name__icontains=query) |
            Q(last_name__icontains=query)
        ).exclude(id=user.id)[:limit]
        
        results['users'] = UserBasicSerializer(users_queryset, many=True).data
    
    # Search Events
    if search_type in ['all', 'events']:
        from events.serializers import EventSerializer
        
        events_queryset = Event.objects.filter(status='published').select_related(
            'organizer', 'category', 'university'
        ).prefetch_related(
            'organizer__profile',
            'participations__user'
        )
        
        # Auto-filter for university admins
        if user.role == 'university_admin' and user.managed_university:
            events_queryset = events_queryset.filter(
                Q(university=user.managed_university) |
                Q(university__isnull=True, organizer__profile__university=user.managed_university)
            )
        
        # Search in title, description, location
        events_queryset = events_queryset.filter(
            Q(title__icontains=query) |
            Q(description__icontains=query) |
            Q(location__icontains=query)
        )[:limit]
        
        serializer = EventSerializer(events_queryset, many=True, context={'request': request})
        results['events'] = serializer.data
    
    # Search Groups
    if search_type in ['all', 'groups']:
        from groups.serializers import GroupSerializer
        
        groups_queryset = Group.objects.filter(is_public=True, is_verified=True).select_related(
            'creator', 'university'
        ).prefetch_related(
            'creator__profile',
            'memberships__user'
        )
        
        # Auto-filter for university admins
        if user.role == 'university_admin' and user.managed_university:
            groups_queryset = groups_queryset.filter(university=user.managed_university)
        
        # Search in name, description
        groups_queryset = groups_queryset.filter(
            Q(name__icontains=query) |
            Q(description__icontains=query)
        )[:limit]
        
        serializer = GroupSerializer(groups_queryset, many=True, context={'request': request})
        results['groups'] = serializer.data
    
    # Calculate totals
    results['total'] = len(results['users']) + len(results['events']) + len(results['groups'])
    results['counts'] = {
        'users': len(results['users']),
        'events': len(results['events']),
        'groups': len(results['groups']),
    }
    
    return Response(results, status=status.HTTP_200_OK)

