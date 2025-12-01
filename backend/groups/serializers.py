"""
Serializers for groups app.
"""
from rest_framework import serializers
from .models import Group, Membership, GroupPost, GroupPostLike, GroupPostComment
from users.serializers import UserSerializer


class MembershipSerializer(serializers.ModelSerializer):
    """Serializer for Membership model."""
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Membership
        fields = [
            'id', 'group', 'user', 'role', 'status',
            'joined_at', 'left_at'
        ]
        read_only_fields = ['id', 'joined_at', 'left_at']


class GroupPostSerializer(serializers.ModelSerializer):
    """Serializer for GroupPost model."""
    author = UserSerializer(read_only=True)
    is_liked = serializers.SerializerMethodField()
    
    class Meta:
        model = GroupPost
        fields = [
            'id', 'group', 'author', 'content', 'post_type',
            'image_url', 'video_url', 'likes_count', 'comments_count',
            'is_liked', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'author', 'likes_count', 'comments_count', 'created_at', 'updated_at']
    
    def get_is_liked(self, obj):
        """Check if current user has liked this post."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return GroupPostLike.objects.filter(user=request.user, post=obj).exists()
        return False


class GroupPostCommentSerializer(serializers.ModelSerializer):
    """Serializer for GroupPostComment model."""
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = GroupPostComment
        fields = [
            'id', 'post', 'user', 'content', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']


class GroupSerializer(serializers.ModelSerializer):
    """Serializer for Group model."""
    creator = UserSerializer(read_only=True)
    members = MembershipSerializer(many=True, read_only=True, source='memberships')
    is_member = serializers.SerializerMethodField()
    user_role = serializers.SerializerMethodField()
    
    class Meta:
        model = Group
        fields = [
            'id', 'name', 'slug', 'description', 'cover_image', 'profile_image',
            'creator', 'university', 'category', 'is_public', 'is_verified',
            'members_count', 'posts_count', 'events_count', 'created_at',
            'updated_at', 'members', 'is_member', 'user_role'
        ]
        read_only_fields = [
            'id', 'slug', 'creator', 'members_count', 'posts_count', 'events_count',
            'created_at', 'updated_at'
        ]
    
    def get_is_member(self, obj):
        """Check if current user is a member."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Membership.objects.filter(
                group=obj,
                user=request.user,
                status='active'
            ).exists()
        return False
    
    def get_user_role(self, obj):
        """Get current user's role in group."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            membership = Membership.objects.filter(
                group=obj,
                user=request.user,
                status='active'
            ).first()
            if membership:
                return membership.role
        return None
    
    def create(self, validated_data):
        """Create group and generate slug from name."""
        from django.utils.text import slugify
        
        name = validated_data.get('name', '')
        if name and not validated_data.get('slug'):
            # Generate slug from name
            base_slug = slugify(name)
            slug = base_slug
            counter = 1
            # Ensure uniqueness
            while Group.objects.filter(slug=slug).exists():
                slug = f"{base_slug}-{counter}"
                counter += 1
            validated_data['slug'] = slug
        
        return super().create(validated_data)

