"""
Django management command to create or update TEST user as class leader.
"""
from django.core.management.base import BaseCommand
from users.models import User


class Command(BaseCommand):
    help = 'Create or update TEST user as class leader with email etudiant@esmt.sn'

    def handle(self, *args, **options):
        email = 'etudiant@esmt.sn'
        username = 'TEST'
        first_name = 'TEST'
        last_name = ''
        
        try:
            # Try to get existing user by email
            user = User.objects.get(email=email)
            
            self.stdout.write(
                self.style.WARNING(f'⚠️  Utilisateur avec l\'email {email} existe déjà!')
            )
            
            # Update
            user.username = username
            user.first_name = first_name
            user.last_name = last_name
            user.role = 'class_leader'
            user.is_active = True
            user.is_verified = True
            user.verification_status = 'verified'
            
            # Set password if not already set
            if not user.has_usable_password():
                user.set_password('test123')
                self.stdout.write(self.style.SUCCESS('🔑 Mot de passe défini: test123'))
            
            user.save()
            self.stdout.write(
                self.style.SUCCESS(f'✅ Utilisateur mis à jour avec succès!')
            )
            
        except User.DoesNotExist:
            # Create new user
            try:
                user = User.objects.create_user(
                    username=username,
                    email=email,
                    password='test123',
                    first_name=first_name,
                    last_name=last_name,
                    phone_number='+221000000000',
                    role='class_leader',
                    is_active=True,
                    is_verified=True,
                    verification_status='verified'
                )
                self.stdout.write(
                    self.style.SUCCESS(f'✅ Utilisateur créé avec succès!')
                )
                self.stdout.write(self.style.SUCCESS('🔑 Mot de passe: test123'))
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f'❌ Erreur lors de la création: {str(e)}')
                )
                return
        
        # Display user details
        self.stdout.write('\n📋 Détails de l\'utilisateur:')
        self.stdout.write(f'  - Username: {user.username}')
        self.stdout.write(f'  - Email: {user.email}')
        self.stdout.write(f'  - Nom: {user.first_name} {user.last_name}')
        self.stdout.write(f'  - Rôle: {user.role}')
        self.stdout.write(f'  - Actif: {user.is_active}')
        self.stdout.write(f'  - Vérifié: {user.is_verified}')
        self.stdout.write(f'  - Statut de vérification: {user.verification_status}')

