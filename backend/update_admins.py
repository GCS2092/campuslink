"""
Script pour mettre à jour tous les admins :
- Changer leurs emails (format générique pour éviter limite 15 min)
- Mettre le mot de passe à "password"
- S'assurer que is_verified=True et is_active=True
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'campuslink.settings')
django.setup()

from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password

User = get_user_model()

def update_admins():
    """Mettre à jour tous les admins."""
    # Trouver tous les admins (tous types)
    admins = User.objects.filter(
        role__in=['admin', 'university_admin', 'class_leader']
    ).exclude(
        is_superuser=False  # Inclure aussi les superusers
    ) | User.objects.filter(
        is_staff=True
    ) | User.objects.filter(
        is_superuser=True
    )
    
    # Éviter les doublons
    admin_ids = set(admins.values_list('id', flat=True))
    admins = User.objects.filter(id__in=admin_ids)
    
    print(f"🔍 Trouvé {admins.count()} admin(s) à mettre à jour\n")
    
    updated_count = 0
    
    for admin in admins:
        try:
            # Générer un email unique basé sur le rôle et l'ID
            role_slug = admin.role if admin.role else 'admin'
            if admin.is_superuser:
                role_slug = 'superuser'
            elif admin.is_staff:
                role_slug = 'staff'
            
            # Nouvel email : admin-{role}-{id}@campuslink.local
            new_email = f"admin-{role_slug}-{admin.id}@campuslink.local"
            
            # Sauvegarder l'ancien email dans username si nécessaire
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
            
            print(f"✅ Admin #{updated_count}:")
            print(f"   ID: {admin.id}")
            print(f"   Username: {admin.username}")
            print(f"   Email: {old_email} → {new_email}")
            print(f"   Rôle: {admin.role}")
            print(f"   Superuser: {admin.is_superuser}")
            print(f"   Staff: {admin.is_staff}")
            print(f"   Vérifié: {admin.is_verified}")
            print(f"   Actif: {admin.is_active}")
            print(f"   Mot de passe: password")
            print()
            
        except Exception as e:
            print(f"❌ Erreur lors de la mise à jour de l'admin {admin.id}: {str(e)}")
            continue
    
    print(f"\n✨ {updated_count} admin(s) mis à jour avec succès!")
    print("\n📋 Identifiants de connexion:")
    print("=" * 60)
    
    # Afficher les identifiants
    for admin in User.objects.filter(id__in=admin_ids):
        role_slug = admin.role if admin.role else 'admin'
        if admin.is_superuser:
            role_slug = 'superuser'
        elif admin.is_staff:
            role_slug = 'staff'
        
        print(f"\n👤 Admin {role_slug.upper()}:")
        print(f"   Email: {admin.email}")
        print(f"   Username: {admin.username}")
        print(f"   Mot de passe: password")
        print(f"   Rôle: {admin.role}")
        print(f"   Vérifié: {admin.is_verified} ✅")
        print(f"   Actif: {admin.is_active} ✅")

if __name__ == '__main__':
    print("🚀 Mise à jour des admins...")
    print("=" * 60)
    update_admins()

