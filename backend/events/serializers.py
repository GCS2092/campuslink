"""
Serializers for Events app.
"""
from rest_framework import serializers
from .models import Category, Event, Participation, EventComment, EventLike, EventFilterPreference
from users.serializers import UserSerializer, UniversityBasicSerializer


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'


class EventSerializer(serializers.ModelSerializer):
    organizer = serializers.SerializerMethodField()
    category = CategorySerializer(read_only=True)
    university = serializers.SerializerMethodField()
    is_participating = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()
    image_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Event
        fields = '__all__'
        read_only_fields = ['id', 'organizer', 'views_count', 'participants_count', 
                          'likes_count', 'created_at', 'updated_at']
    
    def get_university(self, obj):
        """Get university safely."""
        try:
            if obj.university:
                return UniversityBasicSerializer(obj.university, context=self.context).data
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f"Error serializing university for event {obj.id}: {e}")
        return None
    
    def get_organizer(self, obj):
        """Get organizer with proper context."""
        if not obj.organizer:
            return None
        try:
            return UserSerializer(obj.organizer, context=self.context).data
        except Exception as e:
            # Fallback to basic serializer if there's an error
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f"Error serializing organizer for event {obj.id}: {e}")
            try:
                from users.serializers import UserBasicSerializer
                return UserBasicSerializer(obj.organizer, context=self.context).data
            except Exception as e2:
                logger.warning(f"Error with UserBasicSerializer for event {obj.id}: {e2}")
                # Final fallback - return minimal data
                return {
                    'id': str(obj.organizer.id),
                    'username': obj.organizer.username,
                    'email': obj.organizer.email,
                    'first_name': obj.organizer.first_name or '',
                    'last_name': obj.organizer.last_name or '',
                }
    
    def get_image_url(self, obj):
        """Get image URL safely."""
        try:
            if obj.image:
                # Handle CloudinaryField
                if hasattr(obj.image, 'url'):
                    request = self.context.get('request')
                    if request:
                        return request.build_absolute_uri(obj.image.url)
                    return obj.image.url
                # Handle regular ImageField
                elif hasattr(obj, 'image') and obj.image:
                    request = self.context.get('request')
                    if request:
                        return request.build_absolute_uri(obj.image.url)
                    return obj.image.url
            # Fallback to legacy URL
            if obj.image_url_legacy:
                return obj.image_url_legacy
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f"Error getting image URL for event {obj.id}: {e}")
        return None
    
    def get_is_participating(self, obj):
        request = self.context.get('request')
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            return Participation.objects.filter(user=request.user, event=obj).exists()
        return False
    
    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            return EventLike.objects.filter(user=request.user, event=obj).exists()
        return False


class ParticipationSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    event = EventSerializer(read_only=True)
    
    class Meta:
        model = Participation
        fields = '__all__'
        read_only_fields = ['id', 'user', 'created_at']


class EventCommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = EventComment
        fields = '__all__'
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']


class EventLikeSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = EventLike
        fields = '__all__'
        read_only_fields = ['id', 'user', 'created_at']


class EventFilterPreferenceSerializer(serializers.ModelSerializer):
    """Serializer for event filter preferences."""
    
    class Meta:
        model = EventFilterPreference
        fields = '__all__'
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']
    
    def validate(self, data):
        """Ensure only one default filter per user."""
        if data.get('is_default', False):
            user = self.context['request'].user
            # Unset other default filters
            EventFilterPreference.objects.filter(user=user, is_default=True).update(is_default=False)
        return data

