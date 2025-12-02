"""
Commande Django pour obtenir les comptes actifs avec leurs identifiants
Usage: python manage.py get_active_accounts
"""

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

User = get_user_model()


class Command(BaseCommand):
    help = 'Affiche les comptes actifs avec leurs identifiants de connexion'

    def add_arguments(self, parser):
        parser.add_argument(
            '--role',
            type=str,
            help='Filtre les utilisateurs par rôle (admin, university_admin, student, etc.)',
        )
        parser.add_argument(
            '--verified-only',
            action='store_true',
            help='Affiche uniquement les comptes vérifiés',
        )

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS('=' * 80))
        self.stdout.write(self.style.SUCCESS('🔐 COMPTES ACTIFS - INFORMATIONS DE CONNEXION'))
        self.stdout.write(self.style.SUCCESS('=' * 80))
        self.stdout.write('')

        # Filtrer les utilisateurs actifs
        queryset = User.objects.filter(is_active=True)
        
        if options['role']:
            queryset = queryset.filter(role=options['role'])
            self.stdout.write(self.style.WARNING(f'Filtre: Rôle = {options["role"]}'))
            self.stdout.write('')
        
        if options['verified_only']:
            queryset = queryset.filter(is_verified=True)
            self.stdout.write(self.style.WARNING('Filtre: Comptes vérifiés uniquement'))
            self.stdout.write('')

        # Compter les utilisateurs
        total = queryset.count()
        self.stdout.write(self.style.SUCCESS(f'📊 Nombre total de comptes actifs: {total}'))
        self.stdout.write('')

        if total == 0:
            self.stdout.write(self.style.ERROR('⚠️  Aucun compte actif trouvé dans la base de données'))
            self.stdout.write('')
            self.stdout.write(self.style.WARNING('💡 Pour activer un compte:'))
            self.stdout.write('   python manage.py activate_user --email user@example.com --verify')
            return

        # Afficher les utilisateurs
        users = queryset.select_related('profile').order_by('role', 'username')
        
        for i, user in enumerate(users, 1):
            self.stdout.write(self.style.SUCCESS('─' * 80))
            self.stdout.write(self.style.SUCCESS(f'📋 COMPTE {i}'))
            self.stdout.write(self.style.SUCCESS('─' * 80))
            
            # Informations de base
            self.stdout.write(f'👤 Username: {self.style.BOLD(user.username)}')
            self.stdout.write(f'📧 Email: {self.style.BOLD(user.email)}')
            
            if user.first_name or user.last_name:
                self.stdout.write(f'📝 Nom complet: {user.first_name or ""} {user.last_name or ""}'.strip())
            
            # Rôle
            role_display = dict(User.ROLE_CHOICES).get(user.role, user.role)
            self.stdout.write(f'🎭 Rôle: {self.style.WARNING(role_display)}')
            
            # Statut
            status_parts = []
            if user.is_active:
                status_parts.append(self.style.SUCCESS('✅ Actif'))
            if user.is_verified:
                status_parts.append(self.style.SUCCESS('✅ Vérifié'))
            else:
                status_parts.append(self.style.ERROR('❌ Non vérifié'))
            if user.is_staff:
                status_parts.append(self.style.WARNING('👨‍💼 Staff'))
            if user.is_superuser:
                status_parts.append(self.style.ERROR('🔴 Superuser'))
            
            self.stdout.write(f'📊 Statut: {" | ".join(status_parts)}')
            
            # Informations de profil si disponibles
            if hasattr(user, 'profile') and user.profile:
                if user.profile.university:
                    university_name = user.profile.university.name if hasattr(user.profile.university, 'name') else str(user.profile.university)
                    self.stdout.write(f'🏫 Université: {university_name}')
                if user.profile.academic_year:
                    self.stdout.write(f'📚 Année académique: {user.profile.academic_year}')
            
            # Informations de connexion
            self.stdout.write('')
            self.stdout.write(self.style.SUCCESS('🔑 INFORMATIONS DE CONNEXION:'))
            self.stdout.write(f'   Email: {self.style.BOLD(user.email)}')
            self.stdout.write(f'   Username: {self.style.BOLD(user.username)}')
            self.stdout.write(self.style.WARNING('   ⚠️  Mot de passe: (Vérifiez dans les variables d\'environnement ou la configuration)'))
            
            # Date de création et dernière connexion
            self.stdout.write('')
            self.stdout.write(f'📅 Inscrit le: {user.date_joined.strftime("%Y-%m-%d %H:%M:%S")}')
            if user.last_login:
                self.stdout.write(f'🔐 Dernière connexion: {user.last_login.strftime("%Y-%m-%d %H:%M:%S")}')
            else:
                self.stdout.write(f'🔐 Dernière connexion: {self.style.WARNING("Jamais")}')
            
            self.stdout.write('')

        # Résumé final
        self.stdout.write(self.style.SUCCESS('=' * 80))
        self.stdout.write(self.style.SUCCESS('📊 RÉSUMÉ'))
        self.stdout.write(self.style.SUCCESS('=' * 80))
        
        verified_count = queryset.filter(is_verified=True).count()
        admin_count = queryset.filter(role='admin').count()
        university_admin_count = queryset.filter(role='university_admin').count()
        student_count = queryset.filter(role='student').count()
        
        self.stdout.write(f'✅ Total comptes actifs: {total}')
        self.stdout.write(f'✅ Comptes vérifiés: {verified_count}')
        self.stdout.write(f'👨‍💼 Admins globaux: {admin_count}')
        self.stdout.write(f'🏫 Admins d\'université: {university_admin_count}')
        self.stdout.write(f'👨‍🎓 Étudiants: {student_count}')
        self.stdout.write('')
        
        # Instructions pour activer un compte
        self.stdout.write(self.style.WARNING('💡 Pour activer un compte:'))
        self.stdout.write('   python manage.py activate_user --email user@example.com --verify')
        self.stdout.write('')

