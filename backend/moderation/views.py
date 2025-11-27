"""
Views for Moderation app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from users.permissions import IsAdminOrClassLeader
from .models import Report, AuditLog
from .serializers import ReportSerializer, AuditLogSerializer
from .tasks import moderate_content


class ReportViewSet(viewsets.ModelViewSet):
    """ViewSet for reports."""
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        if self.request.user.is_staff:
            return Report.objects.all()
        return Report.objects.filter(reporter=self.request.user)
    
    def perform_create(self, serializer):
        """Create report and trigger moderation."""
        report = serializer.save(reporter=self.request.user)
        
        # Trigger automatic moderation
        moderate_content.delay(
            content_type=report.content_type,
            content_id=str(report.content_id),
            reason=report.reason
        )


class AuditLogViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for audit logs (admin only)."""
    queryset = AuditLog.objects.all()
    serializer_class = AuditLogSerializer
    permission_classes = [IsAuthenticated, IsAdminOrClassLeader]
    ordering = ['-created_at']

