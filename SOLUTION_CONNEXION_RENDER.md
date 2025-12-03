# 🔐 Solution Immédiate - Connexion sur Render

## ⚡ SOLUTION RAPIDE (Sans attendre le déploiement)

### Option 1 : Utiliser la commande existante `list_users`

Sur le shell Render, exécutez :

```bash
python manage.py list_users
```

Cette commande affichera **tous les utilisateurs** avec leur statut (actif/inactif).

Pour voir uniquement les actifs, utilisez :

```bash
python manage.py list_users --role admin
```

---

### Option 2 : Script Python simple (à exécuter directement)

Créez un fichier temporaire sur Render et exécutez-le :

```bash
cat > /tmp/check_users.py << 'EOF'
import os
import sys
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'campuslink.settings')
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()

print('=' * 80)
print('🔐 COMPTES ACTIFS')
print('=' * 80)
active = User.objects.filter(is_active=True)
print(f'Total actifs: {active.count()}\n')

for user in active:
    print(f'👤 {user.username} ({user.email})')
    print(f'   Rôle: {user.role}')
    print(f'   Vérifié: {user.is_verified}')
    print(f'   Staff: {user.is_staff}')
    print(f'   Superuser: {user.is_superuser}')
    print(f'   🔑 Email: {user.email} | Username: {user.username}')
    print(f'   🔐 Mot de passe: Password@123 (par défaut)')
    print('')
EOF

python /tmp/check_users.py
```

---

### Option 3 : Utiliser le shell Django directement

```bash
python manage.py shell
```

Puis dans le shell Python :

```python
from django.contrib.auth import get_user_model
User = get_user_model()

# Voir tous les utilisateurs actifs
active = User.objects.filter(is_active=True)
print(f"Total actifs: {active.count()}")

for user in active:
    print(f"\n👤 {user.username} ({user.email})")
    print(f"   Rôle: {user.role}")
    print(f"   Actif: {user.is_active}")
    print(f"   Vérifié: {user.is_verified}")
    print(f"   🔑 Email: {user.email}")
    print(f"   🔐 Mot de passe: Password@123")
```

---

## 🔄 Après le prochain déploiement Render

Une fois que Render aura redéployé (après le push que je viens de faire), vous pourrez utiliser :

```bash
python manage.py get_active_accounts
```

Ou le script :

```bash
python check_active_users.py
```

---

## 🔐 IDENTIFIANTS À ESSAYER (en attendant)

Basé sur les fichiers de configuration :

### Compte Admin 1 :
- **Email**: `slovengama@gmail.com`
- **Username**: `admin`
- **Mot de passe**: `Password@123`

### Compte Admin 2 :
- **Email**: `admin@campuslink.sn`
- **Username**: `admin`
- **Mot de passe**: `Password@123`

### Compte Admin Université :
- **Email**: `stem@esmt.sn`
- **Username**: `stem`
- **Mot de passe**: `Password@123`

---

## ✅ ACTIONS IMMÉDIATES

1. **Sur Render Shell**, exécutez :
   ```bash
   python manage.py list_users
   ```

2. **Notez les emails des comptes actifs** affichés

3. **Essayez de vous connecter** avec :
   - Email: (celui affiché par list_users)
   - Mot de passe: `Password@123`

4. **Si aucun compte actif**, activez-en un :
   ```bash
   python manage.py activate_user --email slovengama@gmail.com --verify
   ```

---

## 🚨 Si rien ne fonctionne

Créez un nouveau superutilisateur :

```bash
python manage.py createsuperuser
```

Suivez les instructions pour créer un nouveau compte admin.

