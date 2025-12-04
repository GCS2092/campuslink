"""
Migration to create cache table for Database Cache.
This migration creates the cache_table in PostgreSQL automatically.
"""
from django.db import migrations, models


class Migration(migrations.Migration):
    """Migration to create cache table."""
    
    dependencies = []
    
    operations = [
        migrations.RunSQL(
            # Create cache table (PostgreSQL syntax)
            sql="""
            CREATE TABLE IF NOT EXISTS cache_table (
                cache_key VARCHAR(255) PRIMARY KEY,
                value TEXT NOT NULL,
                expires TIMESTAMP NOT NULL
            );
            CREATE INDEX IF NOT EXISTS cache_table_expires_idx ON cache_table(expires);
            """,
            # Reverse migration: drop table
            reverse_sql="DROP TABLE IF EXISTS cache_table CASCADE;"
        ),
    ]

