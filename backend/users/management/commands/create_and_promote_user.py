"""
Django management command to create a user and promote them to class leader or admin.
"""
from django.core.management.base import BaseCommand
from users.models import User


class Command(BaseCommand):
    help = 'Create a user and promote them to class_leader or admin role'

    def add_arguments(self, parser):
        parser.add_argument(
            'username',
            type=str,
            help='Username of the user to create/promote'
        )
        parser.add_argument(
            '--email',
            type=str,
            help='Email address (required if creating new user)'
        )
        parser.add_argument(
            '--password',
            type=str,
            help='Password (required if creating new user)'
        )
        parser.add_argument(
            '--phone',
            type=str,
            default='+221000000000',
            help='Phone number (default: +221000000000)'
        )
        parser.add_argument(
            '--role',
            type=str,
            choices=['class_leader', 'admin', 'student'],
            default='class_leader',
            help='Role to assign (default: class_leader)'
        )
        parser.add_argument(
            '--activate',
            action='store_true',
            help='Also activate and verify the user account'
        )

    def handle(self, *args, **options):
        username = options['username']
        email = options.get('email')
        password = options.get('password')
        phone = options.get('phone', '+221000000000')
        role = options['role']
        activate = options['activate']

        try:
            # Try to get existing user
            user = User.objects.get(username=username)
            
            self.stdout.write(
                self.style.WARNING(f'⚠️  Utilisateur "{username}" existe déjà!')
            )
            
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
            
        except User.DoesNotExist:
            # User doesn't exist, create it
            if not email:
                self.stdout.write(
                    self.style.ERROR('❌ Email requis pour créer un nouvel utilisateur!')
                )
                self.stdout.write('Utilisez: --email <email> --password <password>')
                return
            
            if not password:
                self.stdout.write(
                    self.style.ERROR('❌ Mot de passe requis pour créer un nouvel utilisateur!')
                )
                self.stdout.write('Utilisez: --email <email> --password <password>')
                return
            
            try:
                user = User.objects.create_user(
                    username=username,
                    email=email,
                    password=password,
                    phone_number=phone,
                    role=role,
                    is_active=activate or False,
                    is_verified=activate or False,
                    verification_status='verified' if activate else 'pending'
                )
                
                self.stdout.write(
                    self.style.SUCCESS(
                        f'✅ Utilisateur "{username}" créé avec le rôle "{role}"!'
                    )
                )
                
                if activate:
                    self.stdout.write(
                        self.style.SUCCESS(f'✅ Compte activé et vérifié automatiquement.')
                    )
                
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f'❌ Erreur lors de la création: {str(e)}')
                )
                return
        
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'❌ Erreur: {str(e)}')
            )
            return
        
        # Display user details
        self.stdout.write(f'\n📋 Détails de l\'utilisateur:')
        self.stdout.write(f'  - Username: {user.username}')
        self.stdout.write(f'  - Email: {user.email}')
        self.stdout.write(f'  - Rôle: {user.role}')
        self.stdout.write(f'  - Actif: {user.is_active}')
        self.stdout.write(f'  - Vérifié: {user.is_verified}')
        self.stdout.write(f'  - Statut de vérification: {user.verification_status}')

