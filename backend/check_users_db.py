#!/usr/bin/env python
"""
Script pour vérifier les utilisateurs en base de données et afficher les identifiants
Usage: python check_users_db.py
"""

import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'campuslink.settings')
django.setup()

from django.contrib.auth import get_user_model

User = get_user_model()

print('=' * 80)
print('🔐 VÉRIFICATION DES UTILISATEURS EN BASE DE DONNÉES')
print('=' * 80)
print('')

# Compter tous les utilisateurs
total_users = User.objects.count()
active_users = User.objects.filter(is_active=True).count()
verified_users = User.objects.filter(is_verified=True).count()

print(f'📊 Statistiques:')
print(f'   Total utilisateurs: {total_users}')
print(f'   Utilisateurs actifs: {active_users}')
print(f'   Utilisateurs vérifiés: {verified_users}')
print('')

if total_users == 0:
    print('⚠️  Aucun utilisateur trouvé dans la base de données')
    sys.exit(0)

# Afficher tous les utilisateurs actifs
active_users_list = User.objects.filter(is_active=True).select_related('profile').order_by('role', 'username')

print('=' * 80)
print('✅ COMPTES ACTIFS - INFORMATIONS DE CONNEXION')
print('=' * 80)
print('')

if active_users_list.count() == 0:
    print('⚠️  Aucun compte actif trouvé')
    print('')
    print('💡 Pour activer un compte, utilisez:')
    print('   python manage.py activate_user --email user@example.com --verify')
else:
    for i, user in enumerate(active_users_list, 1):
        print('─' * 80)
        print(f'📋 COMPTE {i}')
        print('─' * 80)
        print(f'👤 Username: {user.username}')
        print(f'📧 Email: {user.email}')
        
        if user.first_name or user.last_name:
            print(f'📝 Nom: {user.first_name or ""} {user.last_name or ""}'.strip())
        
        role_display = dict(User.ROLE_CHOICES).get(user.role, user.role)
        print(f'🎭 Rôle: {role_display}')
        
        status = []
        if user.is_active:
            status.append('✅ Actif')
        if user.is_verified:
            status.append('✅ Vérifié')
        else:
            status.append('❌ Non vérifié')
        if user.is_staff:
            status.append('👨‍💼 Staff')
        if user.is_superuser:
            status.append('🔴 Superuser')
        
        print(f'📊 Statut: {" | ".join(status)}')
        
        if hasattr(user, 'profile') and user.profile:
            if user.profile.university:
                university_name = user.profile.university.name if hasattr(user.profile.university, 'name') else str(user.profile.university)
                print(f'🏫 Université: {university_name}')
        
        print('')
        print('🔑 INFORMATIONS DE CONNEXION:')
        print(f'   Email: {user.email}')
        print(f'   Username: {user.username}')
        print('   ⚠️  Mot de passe: Password@123 (par défaut si créé via create_users.py)')
        print('')
        
        if user.last_login:
            print(f'🔐 Dernière connexion: {user.last_login.strftime("%Y-%m-%d %H:%M:%S")}')
        else:
            print('🔐 Dernière connexion: Jamais')
        print('')

# Afficher aussi les utilisateurs inactifs pour référence
inactive_users = User.objects.filter(is_active=False).count()
if inactive_users > 0:
    print('=' * 80)
    print(f'⚠️  COMPTES INACTIFS ({inactive_users})')
    print('=' * 80)
    print('')
    print('💡 Pour activer un compte inactif:')
    print('   python manage.py activate_user --email user@example.com --verify')
    print('')

print('=' * 80)
print('✅ Vérification terminée')
print('=' * 80)

