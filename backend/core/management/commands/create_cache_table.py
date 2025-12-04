"""
Django management command to create cache table.
This ensures the cache table is created during migrations.
"""
from django.core.management.commands.createcachetable import Command as BaseCommand


class Command(BaseCommand):
    """Create cache table for Database Cache backend."""
    help = 'Creates the cache table for Database Cache backend'

