"""
Views for Social app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from .models import Post, PostComment, PostLike
from .serializers import PostSerializer, PostCommentSerializer, PostLikeSerializer
from users.permissions import IsVerified


class PostViewSet(viewsets.ModelViewSet):
    """ViewSet for posts."""
    queryset = Post.objects.filter(is_public=True, is_deleted=False, is_hidden=False).select_related('author')
    serializer_class = PostSerializer
    permission_classes = [IsVerified]  # Only verified users can create posts
    filterset_fields = ['post_type', 'is_public']
    search_fields = ['content']
    ordering_fields = ['created_at', 'likes_count']
    ordering = ['-created_at']
    
    def get_permissions(self):
        """Allow read-only for unauthenticated users."""
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsVerified()]
    
    def perform_create(self, serializer):
        """Create post (only verified users)."""
        serializer.save(author=self.request.user)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def like(self, request, pk=None):
        """Like post."""
        post = self.get_object()
        user = request.user
        
        like, created = PostLike.objects.get_or_create(user=user, post=post)
        
        if created:
            post.likes_count += 1
            post.save(update_fields=['likes_count'])
            return Response({'message': 'Post liké.'}, status=status.HTTP_201_CREATED)
        
        return Response({'message': 'Déjà liké.'}, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['delete'], permission_classes=[IsAuthenticated])
    def unlike(self, request, pk=None):
        """Unlike post."""
        post = self.get_object()
        user = request.user
        
        try:
            like = PostLike.objects.get(user=user, post=post)
            like.delete()
            post.likes_count = max(0, post.likes_count - 1)
            post.save(update_fields=['likes_count'])
            return Response({'message': 'Like retiré.'}, status=status.HTTP_200_OK)
        except PostLike.DoesNotExist:
            return Response({'error': 'Like non trouvé.'}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['get', 'post'])
    def comments(self, request, pk=None):
        """Get or create comments."""
        post = self.get_object()
        
        if request.method == 'GET':
            comments = PostComment.objects.filter(post=post).select_related('user')
            serializer = PostCommentSerializer(comments, many=True)
            return Response(serializer.data)
        
        # POST - Create comment
        serializer = PostCommentSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(post=post, user=request.user)
            post.comments_count += 1
            post.save(update_fields=['comments_count'])
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def share(self, request, pk=None):
        """Share post."""
        post = self.get_object()
        post.shares_count += 1
        post.save(update_fields=['shares_count'])
        return Response({'message': 'Post partagé.'}, status=status.HTTP_200_OK)

