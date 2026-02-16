"""
Commande Django pour lister tous les utilisateurs
Usage: python manage.py list_users
"""

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.db.models import Count

User = get_user_model()


class Command(BaseCommand):
    help = 'Affiche la liste de tous les utilisateurs dans la base de données'

    def add_arguments(self, parser):
        parser.add_argument(
            '--detailed',
            action='store_true',
            help='Affiche des informations détaillées pour chaque utilisateur',
        )
        parser.add_argument(
            '--role',
            type=str,
            help='Filtre les utilisateurs par rôle',
        )

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write(self.style.SUCCESS('LISTE DES UTILISATEURS - CAMPUSLINK'))
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write('')

        # Filtrer par rôle si spécifié
        queryset = User.objects.all()
        if options['role']:
            queryset = queryset.filter(role=options['role'])
            self.stdout.write(self.style.WARNING(f'Filtre: Rôle = {options["role"]}'))
            self.stdout.write('')

        # Compter les utilisateurs
        total = queryset.count()
        self.stdout.write(self.style.SUCCESS(f'Nombre total d\'utilisateurs: {total}'))
        self.stdout.write('')

        if total == 0:
            self.stdout.write(self.style.WARNING('Aucun utilisateur trouve dans la base de donnees'))
            return

        # Statistiques générales
        active_users = queryset.filter(is_active=True).count()
        inactive_users = queryset.filter(is_active=False).count()
        staff_users = queryset.filter(is_staff=True).count()
        superusers = queryset.filter(is_superuser=True).count()

        self.stdout.write(self.style.SUCCESS('STATISTIQUES:'))
        self.stdout.write(f'   Utilisateurs actifs: {active_users}')
        self.stdout.write(f'   Utilisateurs inactifs: {inactive_users}')
        self.stdout.write(f'   Staff: {staff_users}')
        self.stdout.write(f'   Superusers: {superusers}')
        self.stdout.write('')

        # Répartition par rôle si disponible
        if hasattr(User, 'role'):
            self.stdout.write(self.style.SUCCESS('REPARTITION PAR ROLE:'))
            roles = queryset.values('role').annotate(count=Count('id')).order_by('-count')
            for role_data in roles:
                role = role_data['role'] or 'Aucun'
                count = role_data['count']
                self.stdout.write(f'   - {role}: {count}')
            self.stdout.write('')

        # Liste détaillée des utilisateurs
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write(self.style.SUCCESS('LISTE DÉTAILLÉE DES UTILISATEURS'))
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write('')

        users = queryset.order_by('username')
        
        for i, user in enumerate(users, 1):
            self.stdout.write(f'{i}. {self.style.SUCCESS(user.username)}')
            self.stdout.write(f'   Email: {user.email}')
            self.stdout.write(f'   Nom complet: {user.first_name} {user.last_name}')
            
            if hasattr(user, 'role'):
                self.stdout.write(f'   Role: {self.style.WARNING(user.role or "Aucun")}')
            
            self.stdout.write(f'   Inscrit le: {user.date_joined.strftime("%Y-%m-%d %H:%M:%S")}')
            
            if user.last_login:
                self.stdout.write(f'   Derniere connexion: {user.last_login.strftime("%Y-%m-%d %H:%M:%S")}')
            else:
                self.stdout.write(f'   Derniere connexion: {self.style.WARNING("Jamais")}')
            
            status = []
            if user.is_active:
                status.append(self.style.SUCCESS('Actif'))
            else:
                status.append(self.style.ERROR('Inactif'))
            
            if user.is_staff:
                status.append(self.style.WARNING('Staff'))
            
            if user.is_superuser:
                status.append(self.style.ERROR('Superuser'))
            
            if hasattr(user, 'is_verified') and user.is_verified:
                status.append(self.style.SUCCESS('Vérifié'))
            
            self.stdout.write(f'   Statut: {", ".join(status)}')
            
            # Informations supplémentaires si détaillé
            if options['detailed']:
                self.stdout.write(f'   ID: {user.id}')
                if hasattr(user, 'profile'):
                    profile = user.profile
                    if profile:
                        self.stdout.write(f'   Bio: {getattr(profile, "bio", "N/A")}')
                        if hasattr(profile, 'university'):
                            univ = profile.university
                            if univ:
                                if isinstance(univ, str):
                                    self.stdout.write(f'   Universite: {univ}')
                                else:
                                    self.stdout.write(f'   Universite: {getattr(univ, "name", "N/A")}')
            
            self.stdout.write('')

        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write(self.style.SUCCESS(f'Total: {total} utilisateur(s)'))
        self.stdout.write(self.style.SUCCESS('=' * 70))

