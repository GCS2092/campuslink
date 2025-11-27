"""
Serializers for Social app.
"""
from rest_framework import serializers
from .models import Post, PostComment, PostLike
from users.serializers import UserSerializer


class PostSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)
    is_liked = serializers.SerializerMethodField()
    
    class Meta:
        model = Post
        fields = '__all__'
        read_only_fields = ['id', 'author', 'likes_count', 'comments_count', 
                          'shares_count', 'created_at', 'updated_at']
    
    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return PostLike.objects.filter(user=request.user, post=obj).exists()
        return False


class PostCommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = PostComment
        fields = '__all__'
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']


class PostLikeSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = PostLike
        fields = '__all__'
        read_only_fields = ['id', 'user', 'created_at']

