"""
Signals for User app.
"""
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import User, Profile


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """Create profile when user is created."""
    if created:
        Profile.objects.create(user=instance)


@receiver(post_save, sender=User)
def update_verification_status(sender, instance, **kwargs):
    """Update is_verified when both email and phone are verified."""
    if instance.profile.email_verified and instance.phone_verified:
        if not instance.is_verified:
            instance.is_verified = True
            instance.verification_status = 'verified'
            instance.save(update_fields=['is_verified', 'verification_status'])

