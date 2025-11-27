"""
Serializers for feed app.
"""
from rest_framework import serializers
from .models import FeedItem
from users.serializers import UserBasicSerializer


class FeedItemSerializer(serializers.ModelSerializer):
    """Serializer for feed items."""
    author = UserBasicSerializer(read_only=True)
    author_id = serializers.UUIDField(write_only=True, required=False)
    image = serializers.ImageField(required=False, allow_null=True)
    
    class Meta:
        model = FeedItem
        fields = [
            'id', 'author', 'author_id', 'type', 'title', 'content', 'image',
            'visibility', 'university', 'is_published', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'author', 'created_at', 'updated_at']
    
    def to_representation(self, instance):
        """Return full URL for image if it exists."""
        representation = super().to_representation(instance)
        if representation.get('image') and not representation['image'].startswith('http'):
            request = self.context.get('request')
            if request:
                representation['image'] = request.build_absolute_uri(instance.image.url)
        return representation
    
    def create(self, validated_data):
        # Set author from request user
        validated_data['author'] = self.context['request'].user
        
        # If visibility is private, set university from user's profile
        if validated_data.get('visibility') == 'private':
            user = validated_data['author']
            if hasattr(user, 'profile') and user.profile.university:
                validated_data['university'] = user.profile.university
        
        return super().create(validated_data)
    
    def update(self, instance, validated_data):
        # If visibility is changed to private, update university
        if validated_data.get('visibility') == 'private' and not validated_data.get('university'):
            user = instance.author
            if hasattr(user, 'profile') and user.profile.university:
                validated_data['university'] = user.profile.university
        
        return super().update(instance, validated_data)


