"""
Django management command to promote a user to class leader or admin.
"""
from django.core.management.base import BaseCommand
from users.models import User


class Command(BaseCommand):
    help = 'Promote a user to class_leader or admin role'

    def add_arguments(self, parser):
        parser.add_argument(
            'username',
            type=str,
            help='Username of the user to promote'
        )
        parser.add_argument(
            '--role',
            type=str,
            choices=['class_leader', 'admin'],
            default='class_leader',
            help='Role to assign (default: class_leader)'
        )
        parser.add_argument(
            '--activate',
            action='store_true',
            help='Also activate the user account'
        )

    def handle(self, *args, **options):
        username = options['username']
        role = options['role']
        activate = options['activate']

        try:
            user = User.objects.get(username=username)
            
            old_role = user.role
            user.role = role
            
            if activate:
                user.is_active = True
                user.is_verified = True
                user.verification_status = 'verified'
            
            user.save(update_fields=['role', 'is_active', 'is_verified', 'verification_status'])
            
            self.stdout.write(
                self.style.SUCCESS(
                    f'✅ Utilisateur "{username}" promu de "{old_role}" à "{role}" avec succès!'
                )
            )
            
            if activate:
                self.stdout.write(
                    self.style.SUCCESS(f'✅ Compte activé et vérifié automatiquement.')
                )
            
            self.stdout.write(f'\nDétails de l\'utilisateur:')
            self.stdout.write(f'  - Username: {user.username}')
            self.stdout.write(f'  - Email: {user.email}')
            self.stdout.write(f'  - Rôle: {user.role}')
            self.stdout.write(f'  - Actif: {user.is_active}')
            self.stdout.write(f'  - Vérifié: {user.is_verified}')
            
        except User.DoesNotExist:
            self.stdout.write(
                self.style.WARNING(f'⚠️  Utilisateur "{username}" non trouvé!')
            )
            self.stdout.write(
                self.style.WARNING('Veuillez d\'abord créer l\'utilisateur ou vérifier le nom d\'utilisateur.')
            )
            self.stdout.write('\nPour créer un utilisateur, utilisez:')
            self.stdout.write('  python manage.py createsuperuser')
            self.stdout.write('  ou créez-le via l\'interface d\'inscription')
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'❌ Erreur: {str(e)}')
            )

