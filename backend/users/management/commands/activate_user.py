"""
Commande Django pour activer un utilisateur par email
Usage: python manage.py activate_user --email user@example.com
"""

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

User = get_user_model()


class Command(BaseCommand):
    help = 'Active un utilisateur par son email'

    def add_arguments(self, parser):
        parser.add_argument(
            '--email',
            type=str,
            required=True,
            help='Email de l\'utilisateur à activer',
        )
        parser.add_argument(
            '--verify',
            action='store_true',
            help='Vérifier aussi le compte (is_verified=True)',
        )

    def handle(self, *args, **options):
        email = options['email']
        verify = options['verify']

        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write(self.style.SUCCESS('ACTIVATION D\'UN UTILISATEUR'))
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write('')

        try:
            user = User.objects.get(email=email)
            
            self.stdout.write(f'Utilisateur trouvé: {user.username} ({user.email})')
            self.stdout.write(f'Rôle: {user.role}')
            self.stdout.write(f'Statut actuel: Actif={user.is_active}, Vérifié={user.is_verified}')
            self.stdout.write('')

            # Activer l'utilisateur
            user.is_active = True
            update_fields = ['is_active']
            
            if verify:
                user.is_verified = True
                user.verification_status = 'verified'
                update_fields.extend(['is_verified', 'verification_status'])
            
            user.save(update_fields=update_fields)
            
            self.stdout.write(self.style.SUCCESS('=' * 70))
            self.stdout.write(self.style.SUCCESS('✅ Utilisateur activé avec succès'))
            self.stdout.write(self.style.SUCCESS('=' * 70))
            self.stdout.write('')
            self.stdout.write(f'Statut final: Actif={user.is_active}, Vérifié={user.is_verified}')
            
        except User.DoesNotExist:
            self.stdout.write(self.style.ERROR(f'❌ Utilisateur avec l\'email {email} non trouvé'))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'❌ Erreur: {str(e)}'))

