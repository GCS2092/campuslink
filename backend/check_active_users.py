#!/usr/bin/env python
"""
Script simple pour vérifier les utilisateurs actifs - peut être exécuté directement
Usage: python check_active_users.py
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
print('🔐 COMPTES ACTIFS - INFORMATIONS DE CONNEXION')
print('=' * 80)
print('')

# Filtrer les utilisateurs actifs
active_users = User.objects.filter(is_active=True).select_related('profile').order_by('role', 'username')

total = active_users.count()
print(f'📊 Nombre total de comptes actifs: {total}')
print('')

if total == 0:
    print('⚠️  Aucun compte actif trouvé dans la base de données')
    print('')
    print('💡 Pour activer un compte:')
    print('   python manage.py activate_user --email user@example.com --verify')
    print('')
    
    # Afficher tous les utilisateurs pour référence
    all_users = User.objects.all().count()
    if all_users > 0:
        print(f'📋 Total utilisateurs en base: {all_users}')
        print('   (Utilisez "python manage.py list_users" pour voir tous les comptes)')
    sys.exit(0)

# Afficher les utilisateurs actifs
for i, user in enumerate(active_users, 1):
    print('─' * 80)
    print(f'📋 COMPTE {i}')
    print('─' * 80)
    
    print(f'👤 Username: {user.username}')
    print(f'📧 Email: {user.email}')
    
    if user.first_name or user.last_name:
        print(f'📝 Nom complet: {user.first_name or ""} {user.last_name or ""}'.strip())
    
    # Rôle
    role_display = dict(User.ROLE_CHOICES).get(user.role, user.role) if hasattr(User, 'ROLE_CHOICES') else user.role
    print(f'🎭 Rôle: {role_display}')
    
    # Statut
    status_parts = []
    if user.is_active:
        status_parts.append('✅ Actif')
    if user.is_verified:
        status_parts.append('✅ Vérifié')
    else:
        status_parts.append('❌ Non vérifié')
    if user.is_staff:
        status_parts.append('👨‍💼 Staff')
    if user.is_superuser:
        status_parts.append('🔴 Superuser')
    
    print(f'📊 Statut: {" | ".join(status_parts)}')
    
    # Informations de profil si disponibles
    if hasattr(user, 'profile') and user.profile:
        try:
            if user.profile.university:
                university_name = user.profile.university.name if hasattr(user.profile.university, 'name') else str(user.profile.university)
                print(f'🏫 Université: {university_name}')
        except:
            pass
    
    # Informations de connexion
    print('')
    print('🔑 INFORMATIONS DE CONNEXION:')
    print(f'   Email: {user.email}')
    print(f'   Username: {user.username}')
    print('   ⚠️  Mot de passe: Password@123 (par défaut si créé via create_users.py)')
    print('')
    
    # Date de création et dernière connexion
    print(f'📅 Inscrit le: {user.date_joined.strftime("%Y-%m-%d %H:%M:%S")}')
    if user.last_login:
        print(f'🔐 Dernière connexion: {user.last_login.strftime("%Y-%m-%d %H:%M:%S")}')
    else:
        print('🔐 Dernière connexion: Jamais')
    print('')

# Résumé final
print('=' * 80)
print('📊 RÉSUMÉ')
print('=' * 80)

verified_count = User.objects.filter(is_active=True, is_verified=True).count()
admin_count = User.objects.filter(is_active=True, role='admin').count()
university_admin_count = User.objects.filter(is_active=True, role='university_admin').count()
student_count = User.objects.filter(is_active=True, role='student').count()

print(f'✅ Total comptes actifs: {total}')
print(f'✅ Comptes vérifiés: {verified_count}')
print(f'👨‍💼 Admins globaux: {admin_count}')
print(f'🏫 Admins d\'université: {university_admin_count}')
print(f'👨‍🎓 Étudiants: {student_count}')
print('')

# Instructions
print('💡 Pour activer un compte:')
print('   python manage.py activate_user --email user@example.com --verify')
print('')
print('💡 Pour voir tous les utilisateurs:')
print('   python manage.py list_users')
print('')

