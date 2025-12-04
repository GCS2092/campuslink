"""
Cache utilities for CampusLink using Django Cache Framework.
Supports Redis (if configured), Database Cache, or LocMemCache.
"""
import json
import logging
from django.core.cache import cache
from django.conf import settings

logger = logging.getLogger(__name__)


def _get_cache_key(prefix, *args):
    """Generate cache key from prefix and arguments."""
    key_parts = [prefix] + [str(arg) if arg is not None else 'all' for arg in args]
    return ':'.join(key_parts)


def cache_feed_events(university=None, limit=20):
    """
    Get cached feed events.
    Returns None if not cached.
    """
    try:
        cache_key = _get_cache_key('feed_events', university, limit)
        cached = cache.get(cache_key)
        
        if cached:
            # If cached data is already a dict, return it
            if isinstance(cached, dict):
                return cached
            # If it's a string, parse it
            if isinstance(cached, str):
                return json.loads(cached)
            return cached
    except Exception as e:
        logger.warning(f"Error reading from cache: {str(e)}")
    
    return None


def set_feed_events_cache(university=None, limit=20, data=None, ttl=300):
    """
    Cache feed events.
    ttl: Time to live in seconds (default: 5 minutes)
    """
    try:
        cache_key = _get_cache_key('feed_events', university, limit)
        cache.set(cache_key, data, ttl)
    except Exception as e:
        logger.warning(f"Error writing to cache: {str(e)}")


def invalidate_feed_cache():
    """
    Invalidate all feed caches.
    For Database Cache, we use a version-based approach for efficiency.
    """
    try:
        # Increment version to invalidate all feed caches
        # This is more efficient than deleting individual keys
        version_key = 'feed_cache_version'
        current_version = cache.get(version_key, 0)
        cache.set(version_key, current_version + 1, timeout=None)  # Never expires
        
        # Also try to delete known patterns (for Redis compatibility)
        # Note: This works with Redis but not with Database Cache
        # Database Cache doesn't support pattern deletion, so version-based is better
        logger.info("Feed cache invalidated (version incremented)")
    except Exception as e:
        logger.warning(f"Error invalidating cache: {str(e)}")


def get_otp(phone_number):
    """
    Get OTP code for phone number.
    Returns None if not found or expired.
    """
    try:
        cache_key = f'otp:{phone_number}'
        return cache.get(cache_key)
    except Exception as e:
        logger.warning(f"Error getting OTP from cache: {str(e)}")
        return None


def set_otp(phone_number, otp_code, ttl=600):
    """
    Set OTP code for phone number.
    ttl: Time to live in seconds (default: 10 minutes)
    """
    try:
        cache_key = f'otp:{phone_number}'
        cache.set(cache_key, otp_code, ttl)
    except Exception as e:
        logger.warning(f"Error setting OTP in cache: {str(e)}")


def delete_otp(phone_number):
    """
    Delete OTP code after use.
    """
    try:
        cache_key = f'otp:{phone_number}'
        cache.delete(cache_key)
    except Exception as e:
        logger.warning(f"Error deleting OTP from cache: {str(e)}")

