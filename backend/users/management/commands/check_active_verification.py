"""
Commande Django pour vérifier que la logique de blocage d'accès pour les comptes inactifs est bien implémentée
Usage: python manage.py check_active_verification
"""

import os
import re
from django.core.management.base import BaseCommand
from pathlib import Path


class Command(BaseCommand):
    help = 'Vérifie que la logique de blocage d\'accès pour les comptes inactifs est bien implémentée'

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write(self.style.SUCCESS('VÉRIFICATION DE LA LOGIQUE DE BLOCAGE D\'ACCÈS'))
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write('')

        # Chemin du backend
        backend_path = Path(__file__).parent.parent.parent.parent
        views_path = backend_path / 'users' / 'views.py'
        permissions_path = backend_path / 'users' / 'permissions.py'

        # Vérifier la permission IsActiveAndVerified
        self.stdout.write(self.style.SUCCESS('1. Vérification de la permission IsActiveAndVerified'))
        self.stdout.write('-' * 70)
        
        if permissions_path.exists():
            with open(permissions_path, 'r', encoding='utf-8') as f:
                permissions_content = f.read()
            
            # Vérifier que IsActiveAndVerified vérifie is_active
            if 'is_active' in permissions_content and 'IsActiveAndVerified' in permissions_content:
                self.stdout.write(self.style.SUCCESS('   ✅ IsActiveAndVerified vérifie is_active'))
                
                # Extraire la logique
                match = re.search(r'class IsActiveAndVerified.*?def has_permission.*?return (.*?)\n', 
                                permissions_content, re.DOTALL)
                if match:
                    logic = match.group(1).strip()
                    self.stdout.write(f'   📝 Logique: {logic}')
            else:
                self.stdout.write(self.style.ERROR('   ❌ IsActiveAndVerified ne vérifie pas is_active'))
        else:
            self.stdout.write(self.style.ERROR(f'   ❌ Fichier non trouvé: {permissions_path}'))
        
        self.stdout.write('')

        # Vérifier les vues qui utilisent IsActiveAndVerified
        self.stdout.write(self.style.SUCCESS('2. Vérification des vues utilisant IsActiveAndVerified'))
        self.stdout.write('-' * 70)
        
        views_to_check = []
        if views_path.exists():
            with open(views_path, 'r', encoding='utf-8') as f:
                views_content = f.read()
            
            # Chercher toutes les utilisations de IsActiveAndVerified
            pattern = r'@permission_classes\(\[.*?IsActiveAndVerified.*?\]\)'
            matches = re.finditer(pattern, views_content, re.DOTALL)
            
            for match in matches:
                # Trouver la fonction suivante
                start = match.end()
                func_match = re.search(r'def (\w+)\(', views_content[start:start+200])
                if func_match:
                    func_name = func_match.group(1)
                    views_to_check.append(func_name)
                    self.stdout.write(self.style.SUCCESS(f'   ✅ {func_name} utilise IsActiveAndVerified'))
        
        if not views_to_check:
            self.stdout.write(self.style.WARNING('   ⚠️  Aucune vue trouvée utilisant IsActiveAndVerified'))
        
        self.stdout.write('')

        # Vérifier les autres apps
        self.stdout.write(self.style.SUCCESS('3. Vérification des autres applications'))
        self.stdout.write('-' * 70)
        
        apps_to_check = ['groups', 'events', 'feed', 'messaging']
        for app_name in apps_to_check:
            app_views_path = backend_path / app_name / 'views.py'
            if app_views_path.exists():
                with open(app_views_path, 'r', encoding='utf-8') as f:
                    app_content = f.read()
                
                if 'IsActiveAndVerified' in app_content:
                    self.stdout.write(self.style.SUCCESS(f'   ✅ {app_name}/views.py utilise IsActiveAndVerified'))
                else:
                    self.stdout.write(self.style.WARNING(f'   ⚠️  {app_name}/views.py n\'utilise pas IsActiveAndVerified'))
        
        self.stdout.write('')

        # Vérifier l'authentification
        self.stdout.write(self.style.SUCCESS('4. Vérification de l\'authentification'))
        self.stdout.write('-' * 70)
        
        auth_path = backend_path / 'users' / 'authentication.py'
        if auth_path.exists():
            with open(auth_path, 'r', encoding='utf-8') as f:
                auth_content = f.read()
            
            if 'CustomJWTAuthentication' in auth_content and 'is_active' in auth_content:
                # Vérifier que l'authentification permet les utilisateurs inactifs
                if 'Don\'t check is_active' in auth_content or 'not check is_active' in auth_content:
                    self.stdout.write(self.style.SUCCESS('   ✅ L\'authentification permet les utilisateurs inactifs (correct)'))
                    self.stdout.write(self.style.SUCCESS('   ℹ️  Le blocage se fait au niveau des permissions'))
                else:
                    self.stdout.write(self.style.WARNING('   ⚠️  Vérifiez que l\'authentification permet les utilisateurs inactifs'))
        
        self.stdout.write('')

        # Résumé
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write(self.style.SUCCESS('RÉSUMÉ'))
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write('')
        self.stdout.write('La logique de blocage fonctionne comme suit:')
        self.stdout.write('1. L\'authentification JWT permet aux utilisateurs inactifs de s\'authentifier')
        self.stdout.write('2. Les permissions IsActiveAndVerified bloquent l\'accès aux actions pour les comptes inactifs')
        self.stdout.write('3. Les utilisateurs inactifs peuvent voir leur statut mais ne peuvent pas effectuer d\'actions')
        self.stdout.write('')
        self.stdout.write(self.style.SUCCESS('✅ Vérification terminée'))

