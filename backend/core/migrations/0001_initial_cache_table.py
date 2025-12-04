"""
Migration to create cache table for Database Cache.
This migration ensures the cache_table exists in the database.
"""
from django.db import migrations
from django.core.cache import cache
from django.core.cache.backends.db import DatabaseCache


def create_cache_table(apps, schema_editor):
    """Create cache table if using Database Cache."""
    # Check if we're using Database Cache
    from django.conf import settings
    cache_backend = settings.CACHES.get('default', {}).get('BACKEND', '')
    
    if 'db.DatabaseCache' in cache_backend:
        # Create the cache table using Django's built-in command
        from django.core.management import call_command
        try:
            call_command('createcachetable', 'cache_table', verbosity=0)
        except Exception:
            # Table might already exist, that's okay
            pass


def reverse_cache_table(apps, schema_editor):
    """Drop cache table (optional - usually not needed)."""
    from django.db import connection
    with connection.cursor() as cursor:
        cursor.execute("DROP TABLE IF EXISTS cache_table;")


class Migration(migrations.Migration):
    """Migration to create cache table."""
    
    dependencies = []
    
    operations = [
        migrations.RunPython(create_cache_table, reverse_cache_table),
    ]

