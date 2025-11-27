from django.contrib import admin
from .models import Report, AuditLog


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ['content_type', 'content_id', 'reporter', 'reason', 'status', 'created_at']
    list_filter = ['reason', 'status', 'created_at']
    search_fields = ['description', 'reporter__username']
    readonly_fields = ['created_at']


@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ['user', 'action_type', 'resource_type', 'ip_address', 'created_at']
    list_filter = ['action_type', 'created_at']
    search_fields = ['user__username', 'action_type']
    readonly_fields = ['created_at']
    list_per_page = 100

