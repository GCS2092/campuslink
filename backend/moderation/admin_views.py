"""
Admin moderation views for CampusLink.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from django.db.models import Q
from .models import Report, AuditLog
from .serializers import ReportSerializer, AuditLogSerializer
from .utils import create_audit_log
from users.permissions import IsAdminOrClassLeader, IsUniversityAdminOrGlobalAdmin
from users.models import User
from social.models import Post, PostComment
from feed.models import FeedItem
from notifications.utils import create_notification
import logging

logger = logging.getLogger(__name__)


class AdminReportViewSet(viewsets.ModelViewSet):
    """ViewSet for admin to manage reports (admin only)."""
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Get all reports for admins/university admins, filtered by status if provided."""
        # Only admins and university admins can access
        if not (self.request.user.is_staff or 
                self.request.user.role == 'admin' or
                (self.request.user.role == 'university_admin' and self.request.user.managed_university)):
            return Report.objects.none()
        
        queryset = Report.objects.all().select_related('reporter', 'reviewed_by').order_by('-created_at')
        
        # Auto-filter for university admins - only show reports from their university
        if (self.request.user.role == 'university_admin' and 
            self.request.user.managed_university):
            # Filter reports by content from users in the university
            from users.models import User
            university_user_ids = User.objects.filter(
                profile__university=self.request.user.managed_university
            ).values_list('id', flat=True)
            
            # Filter reports where reporter or content author is from the university
            queryset = queryset.filter(
                Q(reporter_id__in=university_user_ids) |
                Q(content_type='post', content_id__in=Post.objects.filter(
                    author_id__in=university_user_ids
                ).values_list('id', flat=True)) |
                Q(content_type='feed_item', content_id__in=FeedItem.objects.filter(
                    author_id__in=university_user_ids
                ).values_list('id', flat=True))
            )
        
        # Filter by status
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        # Filter by content type
        content_type = self.request.query_params.get('content_type')
        if content_type:
            queryset = queryset.filter(content_type=content_type)
        
        return queryset
    
    @action(detail=True, methods=['post'])
    def resolve(self, request, pk=None):
        """Resolve a report (approve action)."""
        report = self.get_object()
        action_taken = request.data.get('action_taken', '')
        notes = request.data.get('notes', '')
        
        report.status = 'resolved'
        report.reviewed_by = request.user
        report.reviewed_at = timezone.now()
        report.save()
        
        # Create audit log
        create_audit_log(
            user=request.user,
            action_type='report_resolved',
            resource_type='report',
            resource_id=report.id,
            details={
                'report_id': str(report.id),
                'content_type': report.content_type,
                'content_id': str(report.content_id),
                'action_taken': action_taken,
                'notes': notes
            },
            request=request
        )
        
        return Response({
            'message': 'Signalement résolu.',
            'report': ReportSerializer(report).data
        })
    
    @action(detail=True, methods=['post'])
    def dismiss(self, request, pk=None):
        """Dismiss a report (no action needed)."""
        report = self.get_object()
        reason = request.data.get('reason', '')
        
        report.status = 'dismissed'
        report.reviewed_by = request.user
        report.reviewed_at = timezone.now()
        report.save()
        
        # Create audit log
        create_audit_log(
            user=request.user,
            action_type='report_dismissed',
            resource_type='report',
            resource_id=report.id,
            details={
                'report_id': str(report.id),
                'content_type': report.content_type,
                'content_id': str(report.content_id),
                'reason': reason
            },
            request=request
        )
        
        return Response({
            'message': 'Signalement rejeté.',
            'report': ReportSerializer(report).data
        })


class AdminAuditLogViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for admin to view audit logs (admin only)."""
    serializer_class = AuditLogSerializer
    permission_classes = [IsAuthenticated]
    queryset = AuditLog.objects.all().select_related('user').order_by('-created_at')
    
    def get_queryset(self):
        """Filter audit logs - only admins and university admins can access."""
        # Only admins and university admins can access audit logs
        if not (self.request.user.is_staff or 
                self.request.user.role == 'admin' or
                (self.request.user.role == 'university_admin' and self.request.user.managed_university)):
            return AuditLog.objects.none()
        
        queryset = super().get_queryset()
        
        # Auto-filter for university admins - only show logs from their university
        if (self.request.user.role == 'university_admin' and 
            self.request.user.managed_university):
            from users.models import User
            university_user_ids = User.objects.filter(
                profile__university=self.request.user.managed_university
            ).values_list('id', flat=True)
            
            # Filter logs where user is from the university
            queryset = queryset.filter(user_id__in=university_user_ids)
        
        # Filter by user
        user_id = self.request.query_params.get('user_id')
        if user_id:
            queryset = queryset.filter(user_id=user_id)
        
        # Filter by action type
        action_type = self.request.query_params.get('action_type')
        if action_type:
            queryset = queryset.filter(action_type=action_type)
        
        # Filter by resource type
        resource_type = self.request.query_params.get('resource_type')
        if resource_type:
            queryset = queryset.filter(resource_type=resource_type)
        
        # Filter by date range
        date_from = self.request.query_params.get('date_from')
        date_to = self.request.query_params.get('date_to')
        if date_from:
            queryset = queryset.filter(created_at__gte=date_from)
        if date_to:
            queryset = queryset.filter(created_at__lte=date_to)
        
        return queryset


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsUniversityAdminOrGlobalAdmin])
def moderate_post(request, post_id):
    """Moderate a post (delete, hide, approve)."""
    try:
        post = Post.objects.get(id=post_id)
    except Post.DoesNotExist:
        return Response({'error': 'Post introuvable.'}, status=status.HTTP_404_NOT_FOUND)
    
    # Vérifier que l'admin d'université ne peut modérer que les posts de son université
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(post.author, 'profile') or not post.author.profile.university:
            return Response(
                {'error': 'L\'auteur de ce post n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if post.author.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez modérer que les posts des utilisateurs de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
    action_type = request.data.get('action')  # 'delete', 'hide', 'unhide', 'approve'
    reason = request.data.get('reason', '')
    
    if action_type == 'delete':
        # Soft delete
        post.is_deleted = True
        post.deleted_at = timezone.now()
        post.deleted_by = request.user
        post.save()
        
        # Notify author
        create_notification(
            recipient=post.author,
            notification_type='post_deleted',
            title='Votre post a été supprimé',
            message=f'Votre post a été supprimé par un administrateur. Raison: {reason}' if reason else 'Votre post a été supprimé par un administrateur.',
            related_object_type='post',
            related_object_id=post.id
        )
        
        action_log = 'post_deleted'
        
    elif action_type == 'hide':
        post.is_hidden = True
        post.moderation_status = 'hidden'
        post.save()
        
        # Notify author
        create_notification(
            recipient=post.author,
            notification_type='post_hidden',
            title='Votre post a été masqué',
            message=f'Votre post a été masqué par un administrateur. Raison: {reason}' if reason else 'Votre post a été masqué par un administrateur.',
            related_object_type='post',
            related_object_id=post.id
        )
        
        action_log = 'post_hidden'
        
    elif action_type == 'unhide':
        post.is_hidden = False
        post.moderation_status = 'approved'
        post.save()
        action_log = 'post_unhidden'
        
    elif action_type == 'approve':
        post.moderation_status = 'approved'
        post.is_hidden = False
        post.save()
        action_log = 'post_approved'
        
    else:
        return Response({'error': 'Action invalide. Utilisez: delete, hide, unhide, ou approve.'}, 
                       status=status.HTTP_400_BAD_REQUEST)
    
    # Create audit log
    create_audit_log(
        user=request.user,
        action_type=action_log,
        resource_type='post',
        resource_id=post.id,
        details={
            'post_id': str(post.id),
            'post_author': str(post.author.id),
            'action': action_type,
            'reason': reason
        },
        request=request
    )
    
    return Response({
        'message': f'Post {action_type} avec succès.',
        'post': {
            'id': str(post.id),
            'is_deleted': post.is_deleted,
            'is_hidden': post.is_hidden,
            'moderation_status': post.moderation_status
        }
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsUniversityAdminOrGlobalAdmin])
def moderate_feed_item(request, feed_item_id):
    """Moderate a feed item (delete, hide, approve)."""
    try:
        feed_item = FeedItem.objects.get(id=feed_item_id)
    except FeedItem.DoesNotExist:
        return Response({'error': 'Actualité introuvable.'}, status=status.HTTP_404_NOT_FOUND)
    
    # Vérifier que l'admin d'université ne peut modérer que les feed items de son université
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(feed_item.author, 'profile') or not feed_item.author.profile.university:
            return Response(
                {'error': 'L\'auteur de cette actualité n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if feed_item.author.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez modérer que les actualités des utilisateurs de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
    action_type = request.data.get('action')  # 'delete', 'hide', 'unhide', 'approve'
    reason = request.data.get('reason', '')
    
    if action_type == 'delete':
        feed_item.is_deleted = True
        feed_item.deleted_at = timezone.now()
        feed_item.deleted_by = request.user
        feed_item.save()
        
        # Notify author
        create_notification(
            recipient=feed_item.author,
            notification_type='feed_item_deleted',
            title='Votre actualité a été supprimée',
            message=f'Votre actualité a été supprimée par un administrateur. Raison: {reason}' if reason else 'Votre actualité a été supprimée par un administrateur.',
            related_object_type='feed_item',
            related_object_id=feed_item.id
        )
        
        action_log = 'feed_item_deleted'
        
    elif action_type == 'hide':
        feed_item.is_hidden = True
        feed_item.moderation_status = 'hidden'
        feed_item.save()
        
        # Notify author
        create_notification(
            recipient=feed_item.author,
            notification_type='feed_item_hidden',
            title='Votre actualité a été masquée',
            message=f'Votre actualité a été masquée par un administrateur. Raison: {reason}' if reason else 'Votre actualité a été masquée par un administrateur.',
            related_object_type='feed_item',
            related_object_id=feed_item.id
        )
        
        action_log = 'feed_item_hidden'
        
    elif action_type == 'unhide':
        feed_item.is_hidden = False
        feed_item.moderation_status = 'approved'
        feed_item.save()
        action_log = 'feed_item_unhidden'
        
    elif action_type == 'approve':
        feed_item.moderation_status = 'approved'
        feed_item.is_hidden = False
        feed_item.save()
        action_log = 'feed_item_approved'
        
    else:
        return Response({'error': 'Action invalide. Utilisez: delete, hide, unhide, ou approve.'}, 
                       status=status.HTTP_400_BAD_REQUEST)
    
    # Create audit log
    create_audit_log(
        user=request.user,
        action_type=action_log,
        resource_type='feed_item',
        resource_id=feed_item.id,
        details={
            'feed_item_id': str(feed_item.id),
            'feed_item_author': str(feed_item.author.id),
            'action': action_type,
            'reason': reason
        },
        request=request
    )
    
    return Response({
        'message': f'Actualité {action_type} avec succès.',
        'feed_item': {
            'id': str(feed_item.id),
            'is_deleted': feed_item.is_deleted,
            'is_hidden': feed_item.is_hidden,
            'moderation_status': feed_item.moderation_status
        }
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsUniversityAdminOrGlobalAdmin])
def moderate_comment(request, comment_id):
    """Moderate a comment (delete)."""
    try:
        comment = PostComment.objects.get(id=comment_id)
    except PostComment.DoesNotExist:
        return Response({'error': 'Commentaire introuvable.'}, status=status.HTTP_404_NOT_FOUND)
    
    # Vérifier que l'admin d'université ne peut modérer que les commentaires de son université
    if request.user.role == 'university_admin' and request.user.managed_university:
        if not hasattr(comment.user, 'profile') or not comment.user.profile.university:
            return Response(
                {'error': 'L\'auteur de ce commentaire n\'appartient à aucune université.'},
                status=status.HTTP_403_FORBIDDEN
            )
        if comment.user.profile.university != request.user.managed_university:
            return Response(
                {'error': 'Vous ne pouvez modérer que les commentaires des utilisateurs de votre université.'},
                status=status.HTTP_403_FORBIDDEN
            )
    
    reason = request.data.get('reason', '')
    
    # Delete comment
    comment.delete()
    
    # Update post comments count
    post = comment.post
    post.comments_count = max(0, post.comments_count - 1)
    post.save(update_fields=['comments_count'])
    
    # Notify author
    create_notification(
        recipient=comment.user,
        notification_type='comment_deleted',
        title='Votre commentaire a été supprimé',
        message=f'Votre commentaire a été supprimé par un administrateur. Raison: {reason}' if reason else 'Votre commentaire a été supprimé par un administrateur.',
        related_object_type='post',
        related_object_id=post.id
    )
    
    # Create audit log
    create_audit_log(
        user=request.user,
        action_type='comment_deleted',
        resource_type='comment',
        resource_id=comment.id,
        details={
            'comment_id': str(comment.id),
            'comment_author': str(comment.user.id),
            'post_id': str(post.id),
            'reason': reason
        },
        request=request
    )
    
    return Response({'message': 'Commentaire supprimé avec succès.'})

