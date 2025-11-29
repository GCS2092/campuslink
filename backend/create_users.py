#!/usr/bin/env python
"""
Script pour créer des utilisateurs de test dans la base de données
Usage: python create_users.py
"""

import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'campuslink.settings')
django.setup()

from django.contrib.auth import get_user_model
from django.db import transaction

User = get_user_model()

# Liste des utilisateurs à créer
USERS_TO_CREATE = [
    {
        'username': 'admin',
        'email': 'slovengama@gmail.com',
        'password': 'Password@123',
        'role': 'admin',
        'first_name': 'Admin',
        'last_name': 'CampusLink',
        'is_staff': True,
        'is_superuser': True,
    },
    {
        'username': 'etudiant1',
        'email': 'etudiant1@esmt.sn',
        'password': 'Password@123',
        'role': 'student',
        'first_name': 'Étudiant',
        'last_name': 'Test 1',
    },
    {
        'username': 'etudiant2',
        'email': 'etudiant2@esmt.sn',
        'password': 'Password@123',
        'role': 'student',
        'first_name': 'Étudiant',
        'last_name': 'Test 2',
    },
    {
        'username': 'professeur1',
        'email': 'professeur1@esmt.sn',
        'password': 'Password@123',
        'role': 'teacher',
        'first_name': 'Professeur',
        'last_name': 'Test 1',
    },
    {
        'username': 'chef_classe1',
        'email': 'chef.classe1@esmt.sn',
        'password': 'Password@123',
        'role': 'class_leader',
        'first_name': 'Chef',
        'last_name': 'Classe 1',
    },
    {
        'username': 'admin_univ1',
        'email': 'admin.univ1@esmt.sn',
        'password': 'Password@123',
        'role': 'university_admin',
        'first_name': 'Admin',
        'last_name': 'Université 1',
    },
    {
        'username': 'stem',
        'email': 'stem@esmt.sn',
        'password': 'Password@123',
        'role': 'student',
        'first_name': 'Stem',
        'last_name': 'Student',
    },
    {
        'username': 'etudiant',
        'email': 'etudiant@esmt.sn',
        'password': 'Password@123',
        'role': 'student',
        'first_name': 'Étudiant',
        'last_name': 'Principal',
    },
]

def create_users():
    """Crée les utilisateurs dans la base de données"""
    print("=" * 60)
    print("CRÉATION DES UTILISATEURS")
    print("=" * 60)
    print()
    
    created_count = 0
    updated_count = 0
    error_count = 0
    
    with transaction.atomic():
        for user_data in USERS_TO_CREATE:
            username = user_data['username']
            email = user_data['email']
            password = user_data['password']
            role = user_data.get('role', 'student')
            
            try:
                # Vérifier si l'utilisateur existe déjà
                user, created = User.objects.get_or_create(
                    username=username,
                    defaults={
                        'email': email,
                        'first_name': user_data.get('first_name', ''),
                        'last_name': user_data.get('last_name', ''),
                        'is_active': True,
                        'is_staff': user_data.get('is_staff', False),
                        'is_superuser': user_data.get('is_superuser', False),
                    }
                )
                
                # Définir le mot de passe
                user.set_password(password)
                
                # Définir le rôle si le modèle le supporte
                if hasattr(user, 'role'):
                    user.role = role
                
                # Mettre à jour l'email si nécessaire
                if user.email != email:
                    user.email = email
                
                # Activer l'utilisateur
                user.is_active = True
                user.save()
                
                if created:
                    created_count += 1
                    print(f"✅ Créé: {username} ({email}) - Rôle: {role}")
                else:
                    updated_count += 1
                    print(f"🔄 Mis à jour: {username} ({email}) - Rôle: {role}")
                    
            except Exception as e:
                error_count += 1
                print(f"❌ Erreur pour {username}: {e}")
    
    print()
    print("=" * 60)
    print("RÉSUMÉ")
    print("=" * 60)
    print(f"✅ Utilisateurs créés: {created_count}")
    print(f"🔄 Utilisateurs mis à jour: {updated_count}")
    print(f"❌ Erreurs: {error_count}")
    print(f"📊 Total: {len(USERS_TO_CREATE)}")
    print()
    
    # Afficher tous les utilisateurs
    print("=" * 60)
    print("LISTE DES UTILISATEURS EN BASE DE DONNÉES")
    print("=" * 60)
    all_users = User.objects.all().order_by('username')
    print(f"Total: {all_users.count()} utilisateurs\n")
    
    for user in all_users:
        role = getattr(user, 'role', 'N/A')
        print(f"- {user.username} ({user.email})")
        print(f"  Rôle: {role} | Actif: {user.is_active} | Staff: {user.is_staff}")
    
    print()
    print("=" * 60)
    print("✅ TERMINÉ")
    print("=" * 60)
    print()
    print("🔐 Tous les utilisateurs ont le mot de passe: Password@123")
    print("👤 Admin: slovengama@gmail.com / admin")

if __name__ == "__main__":
    create_users()

