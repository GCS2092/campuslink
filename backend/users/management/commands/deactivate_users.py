"""
Commande Django pour désactiver tous les comptes sauf admin et responsable de l'école
Usage: python manage.py deactivate_users
"""

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.db import transaction

User = get_user_model()


class Command(BaseCommand):
    help = 'Désactive tous les comptes utilisateurs sauf les administrateurs et responsables d\'école'

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Affiche ce qui sera fait sans effectuer les modifications',
        )
        parser.add_argument(
            '--force',
            action='store_true',
            help='Force la désactivation sans confirmation',
        )

    def handle(self, *args, **options):
        dry_run = options['dry_run']
        force = options['force']

        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write(self.style.SUCCESS('DÉSACTIVATION DES COMPTES UTILISATEURS'))
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write('')

        # Récupérer tous les utilisateurs sauf admin et university_admin
        users_to_deactivate = User.objects.exclude(
            role__in=['admin', 'university_admin']
        ).exclude(
            is_staff=True
        ).exclude(
            is_superuser=True
        )

        # Compter les utilisateurs
        total_to_deactivate = users_to_deactivate.count()
        already_inactive = users_to_deactivate.filter(is_active=False).count()
        to_deactivate_count = users_to_deactivate.filter(is_active=True).count()

        # Afficher les statistiques
        self.stdout.write(self.style.SUCCESS('📊 STATISTIQUES:'))
        self.stdout.write(f'   Total d\'utilisateurs à désactiver: {total_to_deactivate}')
        self.stdout.write(f'   Déjà inactifs: {already_inactive}')
        self.stdout.write(f'   À désactiver: {to_deactivate_count}')
        self.stdout.write('')

        # Afficher les utilisateurs qui seront conservés actifs
        active_admins = User.objects.filter(
            role__in=['admin', 'university_admin']
        ).filter(is_active=True)
        
        active_staff = User.objects.filter(
            is_staff=True
        ).exclude(role__in=['admin', 'university_admin']).filter(is_active=True)

        self.stdout.write(self.style.WARNING('👑 COMPTES QUI RESTERONT ACTIFS:'))
        self.stdout.write(f'   Administrateurs (admin): {User.objects.filter(role="admin", is_active=True).count()}')
        self.stdout.write(f'   Responsables d\'école (university_admin): {User.objects.filter(role="university_admin", is_active=True).count()}')
        self.stdout.write(f'   Staff (autres): {active_staff.count()}')
        self.stdout.write('')

        if active_admins.exists():
            self.stdout.write(self.style.SUCCESS('   Liste des administrateurs actifs:'))
            for admin in active_admins:
                self.stdout.write(f'      - {admin.username} ({admin.email}) - Rôle: {admin.role}')
            self.stdout.write('')

        if not force and not dry_run:
            # Demander confirmation
            self.stdout.write(self.style.WARNING('⚠️  ATTENTION: Cette action va désactiver tous les comptes sauf les administrateurs et responsables d\'école.'))
            confirm = input('Voulez-vous continuer? (oui/non): ')
            if confirm.lower() not in ['oui', 'o', 'yes', 'y']:
                self.stdout.write(self.style.ERROR('❌ Opération annulée.'))
                return

        if dry_run:
            self.stdout.write(self.style.WARNING('🔍 MODE DRY-RUN: Aucune modification ne sera effectuée'))
            self.stdout.write('')
            self.stdout.write(self.style.SUCCESS('Utilisateurs qui seraient désactivés:'))
            for user in users_to_deactivate.filter(is_active=True)[:20]:  # Limiter à 20 pour l'affichage
                self.stdout.write(f'   - {user.username} ({user.email}) - Rôle: {user.role}')
            if to_deactivate_count > 20:
                self.stdout.write(f'   ... et {to_deactivate_count - 20} autres utilisateurs')
        else:
            # Effectuer la désactivation
            with transaction.atomic():
                updated_count = users_to_deactivate.filter(is_active=True).update(is_active=False)
                
                self.stdout.write(self.style.SUCCESS('=' * 70))
                self.stdout.write(self.style.SUCCESS(f'✅ {updated_count} compte(s) désactivé(s) avec succès'))
                self.stdout.write(self.style.SUCCESS('=' * 70))
                self.stdout.write('')

                # Afficher un résumé final
                self.stdout.write(self.style.SUCCESS('📊 RÉSUMÉ FINAL:'))
                total_active = User.objects.filter(is_active=True).count()
                total_inactive = User.objects.filter(is_active=False).count()
                self.stdout.write(f'   Total actifs: {total_active}')
                self.stdout.write(f'   Total inactifs: {total_inactive}')
                self.stdout.write('')

                # Vérifier les admins et responsables d'école
                active_admins_count = User.objects.filter(role='admin', is_active=True).count()
                active_university_admins_count = User.objects.filter(role='university_admin', is_active=True).count()
                
                self.stdout.write(self.style.SUCCESS('👑 COMPTES ADMINISTRATEURS ACTIFS:'))
                self.stdout.write(f'   Administrateurs (admin): {active_admins_count}')
                self.stdout.write(f'   Responsables d\'école (university_admin): {active_university_admins_count}')

