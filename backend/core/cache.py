"""
Redis cache utilities for CampusLink.
Redis is optional - functions will gracefully fail if Redis is not available.
"""
import json
import logging
from django.conf import settings

logger = logging.getLogger(__name__)

# Try to initialize Redis client, but make it optional
redis_client = None
try:
    import redis
    if hasattr(settings, 'REDIS_URL') and settings.REDIS_URL:
        redis_client = redis.from_url(
            settings.REDIS_URL,
            decode_responses=True,
            socket_connect_timeout=2,
            socket_timeout=2
        )
        # Test connection
        redis_client.ping()
    else:
        logger.warning("REDIS_URL not configured, Redis cache disabled")
except (ImportError, redis.ConnectionError, redis.TimeoutError, Exception) as e:
    logger.warning(f"Redis not available: {str(e)}. Cache functions will be disabled.")
    redis_client = None


def _check_redis():
    """Check if Redis is available."""
    if redis_client is None:
        return False
    try:
        redis_client.ping()
        return True
    except Exception:
        return False


def cache_feed_events(university=None, limit=20):
    """
    Cache the feed of popular events.
    Returns None if Redis is not available.
    """
    if not _check_redis():
        return None
    
    try:
        cache_key = f'feed_events:{university or "all"}:{limit}'
        cached = redis_client.get(cache_key)
        
        if cached:
            return json.loads(cached)
    except Exception as e:
        logger.warning(f"Error reading from Redis cache: {str(e)}")
    
    return None


def set_feed_events_cache(university=None, limit=20, data=None, ttl=300):
    """
    Set cache for feed events.
    Silently fails if Redis is not available.
    """
    if not _check_redis():
        return
    
    try:
        cache_key = f'feed_events:{university or "all"}:{limit}'
        redis_client.setex(cache_key, ttl, json.dumps(data))
    except Exception as e:
        logger.warning(f"Error writing to Redis cache: {str(e)}")


def invalidate_feed_cache():
    """
    Invalidate all feed caches.
    Silently fails if Redis is not available.
    """
    if not _check_redis():
        return
    
    try:
        keys = redis_client.keys('feed_events:*')
        if keys:
            redis_client.delete(*keys)
    except Exception as e:
        logger.warning(f"Error invalidating Redis cache: {str(e)}")


def get_otp(phone_number):
    """
    Get OTP code for phone number.
    Returns None if Redis is not available.
    """
    if not _check_redis():
        return None
    
    try:
        return redis_client.get(f'otp:{phone_number}')
    except Exception as e:
        logger.warning(f"Error getting OTP from Redis: {str(e)}")
        return None


def set_otp(phone_number, otp_code, ttl=600):
    """
    Set OTP code for phone number (TTL in seconds, default 10 minutes).
    Silently fails if Redis is not available.
    """
    if not _check_redis():
        return
    
    try:
        redis_client.setex(f'otp:{phone_number}', ttl, otp_code)
    except Exception as e:
        logger.warning(f"Error setting OTP in Redis: {str(e)}")


def delete_otp(phone_number):
    """
    Delete OTP code after use.
    Silently fails if Redis is not available.
    """
    if not _check_redis():
        return
    
    try:
        redis_client.delete(f'otp:{phone_number}')
    except Exception as e:
        logger.warning(f"Error deleting OTP from Redis: {str(e)}")

