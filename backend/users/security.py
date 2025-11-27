"""
Security utilities for User app.
"""
import logging
from django.core.cache import cache
from datetime import timedelta

logger = logging.getLogger('users')

MAX_LOGIN_ATTEMPTS = 5
LOCKOUT_DURATION = 15  # minutes


def check_account_lockout(email):
    """
    Check if account is locked due to failed login attempts.
    
    Returns:
        tuple: (is_locked: bool, remaining_seconds: int)
    """
    lockout_key = f'account_lockout:{email}'
    attempts_key = f'login_attempts:{email}'
    
    # Vérifier si le compte est verrouillé
    if cache.get(lockout_key):
        remaining = cache.ttl(lockout_key)
        logger.warning(f"Account lockout attempt for {email}. Remaining: {remaining}s")
        return True, remaining
    
    # Vérifier le nombre de tentatives
    attempts = cache.get(attempts_key, 0)
    if attempts >= MAX_LOGIN_ATTEMPTS:
        # Verrouiller le compte
        cache.set(lockout_key, True, timeout=LOCKOUT_DURATION * 60)
        cache.delete(attempts_key)
        logger.warning(f"Account {email} locked due to too many failed attempts")
        return True, LOCKOUT_DURATION * 60
    
    return False, 0


def record_failed_login_attempt(email):
    """Record a failed login attempt."""
    attempts_key = f'login_attempts:{email}'
    attempts = cache.get(attempts_key, 0)
    new_attempts = attempts + 1
    cache.set(attempts_key, new_attempts, timeout=15 * 60)  # 15 minutes
    logger.warning(f"Failed login attempt for {email}. Attempts: {new_attempts}/{MAX_LOGIN_ATTEMPTS}")


def clear_login_attempts(email):
    """Clear login attempts after successful login."""
    attempts_key = f'login_attempts:{email}'
    lockout_key = f'account_lockout:{email}'
    cache.delete(attempts_key)
    cache.delete(lockout_key)
    logger.info(f"Login attempts cleared for {email}")

