"""
Redis cache utilities for CampusLink.
"""
import json
import redis
from django.conf import settings

redis_client = redis.from_url(
    settings.REDIS_URL,
    decode_responses=True
)


def cache_feed_events(university=None, limit=20):
    """
    Cache the feed of popular events.
    """
    cache_key = f'feed_events:{university or "all"}:{limit}'
    cached = redis_client.get(cache_key)
    
    if cached:
        return json.loads(cached)
    
    return None


def set_feed_events_cache(university=None, limit=20, data=None, ttl=300):
    """
    Set cache for feed events.
    """
    cache_key = f'feed_events:{university or "all"}:{limit}'
    redis_client.setex(cache_key, ttl, json.dumps(data))


def invalidate_feed_cache():
    """
    Invalidate all feed caches.
    """
    keys = redis_client.keys('feed_events:*')
    if keys:
        redis_client.delete(*keys)


def get_otp(phone_number):
    """
    Get OTP code for phone number.
    """
    return redis_client.get(f'otp:{phone_number}')


def set_otp(phone_number, otp_code, ttl=600):
    """
    Set OTP code for phone number (TTL in seconds, default 10 minutes).
    """
    redis_client.setex(f'otp:{phone_number}', ttl, otp_code)


def delete_otp(phone_number):
    """
    Delete OTP code after use.
    """
    redis_client.delete(f'otp:{phone_number}')

