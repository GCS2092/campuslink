"""
Active tous les utilisateurs (is_active=True, is_verified=True).
Usage: python manage.py activate_all_users
       python manage.py activate_all_users --verify
"""

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

User = get_user_model()


class Command(BaseCommand):
    help = "Active tous les utilisateurs (is_active=True; optionnel: is_verified=True)"

    def add_arguments(self, parser):
        parser.add_argument(
            '--verify',
            action='store_true',
            help='Mettre aussi is_verified=True et verification_status=verified pour tous',
        )

    def handle(self, *args, **options):
        verify = options['verify']
        qs = User.objects.all()
        total = qs.count()
        to_activate = qs.filter(is_active=False)
        count_inactive = to_activate.count()

        self.stdout.write(self.style.SUCCESS('=' * 60))
        self.stdout.write(self.style.SUCCESS('ACTIVATION DE TOUS LES UTILISATEURS'))
        self.stdout.write(self.style.SUCCESS('=' * 60))
        self.stdout.write(f'Total utilisateurs: {total}')
        self.stdout.write(f'Déjà actifs: {total - count_inactive}')
        self.stdout.write(f'À activer: {count_inactive}')
        self.stdout.write('')

        if verify:
            updated = qs.update(
                is_active=True,
                is_verified=True,
                verification_status='verified',
            )
            self.stdout.write(self.style.SUCCESS(f'✅ Tous les utilisateurs ont été activés et vérifiés ({updated} mis à jour).'))
        else:
            updated = qs.update(is_active=True)
            self.stdout.write(self.style.SUCCESS(f'✅ Tous les utilisateurs ont été activés ({updated} mis à jour).'))

        self.stdout.write(self.style.SUCCESS('=' * 60))
