#!/usr/bin/env python
"""
Script pour tester la connexion à la base de données hébergée sur Render.
Ce script simule la configuration utilisée sur Render avec DATABASE_URL.
"""
import os
import sys
import django

# Configuration Django minimale pour tester la connexion
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'campuslink.settings')

# Ajouter le répertoire parent au path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    django.setup()
    
    from django.db import connection
    from django.conf import settings
    
    print("=" * 60)
    print("TEST DE CONNEXION À LA BASE DE DONNÉES")
    print("=" * 60)
    print()
    
    # Afficher la configuration (sans le mot de passe complet)
    db_config = settings.DATABASES['default']
    print(f"Engine: {db_config.get('ENGINE', 'N/A')}")
    print(f"Host: {db_config.get('HOST', 'N/A')}")
    print(f"Port: {db_config.get('PORT', 'N/A')}")
    print(f"Database: {db_config.get('NAME', 'N/A')}")
    print(f"User: {db_config.get('USER', 'N/A')}")
    password = db_config.get('PASSWORD', '')
    if password:
        print(f"Password: {'*' * min(len(password), 10)}...")
    print()
    
    # Tester la connexion
    print("Tentative de connexion...")
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT version();")
            version = cursor.fetchone()
            print(f"✅ CONNEXION RÉUSSIE!")
            print(f"PostgreSQL Version: {version[0]}")
            print()
            
            # Tester quelques requêtes simples
            cursor.execute("SELECT current_database();")
            db_name = cursor.fetchone()[0]
            print(f"Base de données actuelle: {db_name}")
            
            cursor.execute("SELECT current_user;")
            current_user = cursor.fetchone()[0]
            print(f"Utilisateur actuel: {current_user}")
            
            # Vérifier si PostGIS est disponible
            try:
                cursor.execute("SELECT PostGIS_version();")
                postgis_version = cursor.fetchone()[0]
                print(f"PostGIS Version: {postgis_version}")
            except Exception as e:
                print(f"PostGIS non disponible: {str(e)}")
            
            print()
            print("=" * 60)
            print("✅ TOUS LES TESTS SONT PASSÉS!")
            print("=" * 60)
            
    except Exception as e:
        print(f"❌ ERREUR DE CONNEXION: {str(e)}")
        print()
        print("Vérifiez que:")
        print("1. La variable DATABASE_URL est correctement configurée")
        print("2. La base de données est accessible depuis votre réseau")
        print("3. Les credentials sont corrects")
        sys.exit(1)
        
except Exception as e:
    print(f"❌ ERREUR LORS DE L'INITIALISATION: {str(e)}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

