"""
Commande Django pour mettre à jour tous les admins :
- Changer leurs emails (format générique pour éviter limite 15 min)
- Mettre le mot de passe à "password"
- S'assurer que is_verified=True et is_active=True

Usage: python manage.py update_admins
"""

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password

User = get_user_model()


class Command(BaseCommand):
    help = 'Met à jour tous les admins : email, mot de passe, vérification'

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS('=' * 80))
        self.stdout.write(self.style.SUCCESS('🚀 Mise à jour des admins...'))
        self.stdout.write(self.style.SUCCESS('=' * 80))
        self.stdout.write('')
        
        # Trouver tous les admins (tous types)
        admin_queryset = User.objects.filter(
            role__in=['admin', 'university_admin', 'class_leader']
        )
        
        # Inclure aussi les superusers et staff
        superusers = User.objects.filter(is_superuser=True)
        staff = User.objects.filter(is_staff=True)
        
        # Combiner et éviter les doublons
        all_admin_ids = set(
            list(admin_queryset.values_list('id', flat=True)) +
            list(superusers.values_list('id', flat=True)) +
            list(staff.values_list('id', flat=True))
        )
        
        admins = User.objects.filter(id__in=all_admin_ids)
        
        self.stdout.write(f'🔍 Trouvé {admins.count()} admin(s) à mettre à jour\n')
        
        updated_count = 0
        
        for admin in admins:
            try:
                # Générer un email unique basé sur le rôle et l'ID
                role_slug = admin.role if admin.role else 'admin'
                if admin.is_superuser:
                    role_slug = 'superuser'
                elif admin.is_staff and not admin.role:
                    role_slug = 'staff'
                
                # Nouvel email : admin-{role}-{id}@campuslink.local
                new_email = f"admin-{role_slug}-{admin.id}@campuslink.local"
                
                # Sauvegarder l'ancien email
                old_email = admin.email
                old_username = admin.username
                
                # Mettre à jour
                admin.email = new_email
                admin.password = make_password('password')  # Mot de passe : "password"
                admin.is_verified = True
                admin.is_active = True
                
                # S'assurer que le username est valide
                if not admin.username or admin.username == old_email:
                    admin.username = f"admin_{role_slug}_{admin.id}"
                
                admin.save()
                
                updated_count += 1
                
                self.stdout.write(self.style.SUCCESS(f'✅ Admin #{updated_count}:'))
                self.stdout.write(f'   ID: {admin.id}')
                self.stdout.write(f'   Username: {admin.username}')
                self.stdout.write(f'   Email: {old_email} → {new_email}')
                self.stdout.write(f'   Rôle: {admin.role}')
                self.stdout.write(f'   Superuser: {admin.is_superuser}')
                self.stdout.write(f'   Staff: {admin.is_staff}')
                self.stdout.write(f'   Vérifié: {admin.is_verified} ✅')
                self.stdout.write(f'   Actif: {admin.is_active} ✅')
                self.stdout.write(f'   Mot de passe: password')
                self.stdout.write('')
                
            except Exception as e:
                self.stdout.write(self.style.ERROR(f'❌ Erreur lors de la mise à jour de l\'admin {admin.id}: {str(e)}'))
                continue
        
        self.stdout.write(self.style.SUCCESS(f'\n✨ {updated_count} admin(s) mis à jour avec succès!'))
        self.stdout.write('')
        self.stdout.write(self.style.SUCCESS('📋 Identifiants de connexion:'))
        self.stdout.write('=' * 80)
        
        # Afficher les identifiants
        for admin in User.objects.filter(id__in=all_admin_ids).order_by('role', 'id'):
            role_slug = admin.role if admin.role else 'admin'
            if admin.is_superuser:
                role_slug = 'superuser'
            elif admin.is_staff and not admin.role:
                role_slug = 'staff'
            
            self.stdout.write('')
            self.stdout.write(self.style.WARNING(f'👤 Admin {role_slug.upper()}:'))
            self.stdout.write(f'   Email: {admin.email}')
            self.stdout.write(f'   Username: {admin.username}')
            self.stdout.write(f'   Mot de passe: password')
            self.stdout.write(f'   Rôle: {admin.role}')
            self.stdout.write(f'   Vérifié: {admin.is_verified} ✅')
            self.stdout.write(f'   Actif: {admin.is_active} ✅')
        
        self.stdout.write('')
        self.stdout.write('=' * 80)

