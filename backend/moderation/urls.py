"""
URLs for Moderation app.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ReportViewSet, AuditLogViewSet
from .admin_views import (
    AdminReportViewSet, AdminAuditLogViewSet,
    moderate_post, moderate_feed_item, moderate_comment
)

router = DefaultRouter()
router.register(r'reports', ReportViewSet, basename='report')
router.register(r'audit-log', AuditLogViewSet, basename='auditlog')

# Admin routes
admin_router = DefaultRouter()
admin_router.register(r'admin/reports', AdminReportViewSet, basename='admin-report')
admin_router.register(r'admin/audit-log', AdminAuditLogViewSet, basename='admin-auditlog')

urlpatterns = [
    path('', include(router.urls)),
    path('', include(admin_router.urls)),
    # Admin moderation endpoints
    path('admin/moderate/post/<uuid:post_id>/', moderate_post, name='moderate_post'),
    path('admin/moderate/feed-item/<uuid:feed_item_id>/', moderate_feed_item, name='moderate_feed_item'),
    path('admin/moderate/comment/<uuid:comment_id>/', moderate_comment, name='moderate_comment'),
]

