"""
Serializers for Events app.
"""
from rest_framework import serializers
from .models import Category, Event, Participation, EventComment, EventLike
from users.serializers import UserSerializer


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'


class EventSerializer(serializers.ModelSerializer):
    organizer = UserSerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    is_participating = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()
    
    class Meta:
        model = Event
        fields = '__all__'
        read_only_fields = ['id', 'organizer', 'views_count', 'participants_count', 
                          'likes_count', 'created_at', 'updated_at']
    
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

