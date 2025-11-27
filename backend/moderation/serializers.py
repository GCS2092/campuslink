"""
Serializers for Moderation app.
"""
from rest_framework import serializers
from .models import Report, AuditLog
from users.serializers import UserSerializer


class ReportSerializer(serializers.ModelSerializer):
    reporter = UserSerializer(read_only=True)
    reviewed_by = UserSerializer(read_only=True)
    
    class Meta:
        model = Report
        fields = '__all__'
        read_only_fields = ['id', 'reporter', 'reviewed_by', 'reviewed_at', 'created_at']


class AuditLogSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = AuditLog
        fields = '__all__'
        read_only_fields = ['id', 'created_at']

