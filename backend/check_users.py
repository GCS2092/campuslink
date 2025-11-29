#!/usr/bin/env python
"""
Script pour vérifier les utilisateurs dans la base de données déployée
Usage: python check_users.py
"""

import os
import sys
import django
import dj_database_url
from django.db import connection

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'campuslink.settings')
django.setup()

from django.contrib.auth import get_user_model

User = get_user_model()

def check_users():
    """Vérifie les utilisateurs dans la base de données"""
    print("=" * 60)
    print("VÉRIFICATION DES UTILISATEURS EN BASE DE DONNÉES")
    print("=" * 60)
    
    try:
        # Test de connexion
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            print("✅ Connexion à la base de données réussie\n")
        
        # Récupérer les informations de la base de données
        db_config = connection.settings_dict
        print(f"📊 Base de données: {db_config.get('NAME', 'N/A')}")
        print(f"📍 Host: {db_config.get('HOST', 'N/A')}")
        print(f"👤 User: {db_config.get('USER', 'N/A')}\n")
        
        # Compter les utilisateurs
        total_users = User.objects.count()
        print(f"👥 Nombre total d'utilisateurs: {total_users}\n")
        
        if total_users > 0:
            print("📋 Liste des utilisateurs:")
            print("-" * 60)
            
            users = User.objects.all().order_by('-date_joined')[:20]  # 20 derniers
            
            for i, user in enumerate(users, 1):
                print(f"{i}. {user.username} ({user.email})")
                print(f"   - ID: {user.id}")
                print(f"   - Rôle: {user.role if hasattr(user, 'role') else 'N/A'}")
                print(f"   - Inscrit le: {user.date_joined.strftime('%Y-%m-%d %H:%M:%S')}")
                print(f"   - Dernière connexion: {user.last_login.strftime('%Y-%m-%d %H:%M:%S') if user.last_login else 'Jamais'}")
                print(f"   - Actif: {'Oui' if user.is_active else 'Non'}")
                print(f"   - Vérifié: {'Oui' if user.is_verified if hasattr(user, 'is_verified') else 'N/A'}")
                print()
            
            if total_users > 20:
                print(f"... et {total_users - 20} autres utilisateurs")
            
            # Statistiques
            print("\n📊 Statistiques:")
            print("-" * 60)
            active_users = User.objects.filter(is_active=True).count()
            print(f"✅ Utilisateurs actifs: {active_users}")
            print(f"❌ Utilisateurs inactifs: {total_users - active_users}")
            
            if hasattr(User, 'is_verified'):
                verified_users = User.objects.filter(is_verified=True).count()
                print(f"✓ Utilisateurs vérifiés: {verified_users}")
                print(f"✗ Utilisateurs non vérifiés: {total_users - verified_users}")
            
            # Par rôle si disponible
            if hasattr(User, 'role'):
                print("\n👥 Répartition par rôle:")
                from django.db.models import Count
                roles = User.objects.values('role').annotate(count=Count('id')).order_by('-count')
                for role_data in roles:
                    role = role_data['role'] or 'Aucun'
                    count = role_data['count']
                    print(f"   - {role}: {count}")
        else:
            print("⚠️  Aucun utilisateur trouvé dans la base de données")
            print("   La base de données est vide ou les migrations n'ont pas été appliquées.")
        
        print("\n" + "=" * 60)
        print("✅ Vérification terminée")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        print("\nVérifiez que:")
        print("1. La variable DATABASE_URL est correctement configurée")
        print("2. La base de données est accessible")
        print("3. Les migrations ont été appliquées (python manage.py migrate)")
        sys.exit(1)

if __name__ == "__main__":
    check_users()

