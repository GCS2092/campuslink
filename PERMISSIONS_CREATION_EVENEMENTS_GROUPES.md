# 🔐 Permissions pour Créer des Événements et des Groupes

## 📋 Résumé des Permissions

### ✅ **Créer un Événement**
**Permission requise :** `IsVerifiedOrReadOnly`
- ✅ L'utilisateur doit être **authentifié** (`IsAuthenticated`)
- ✅ L'utilisateur doit être **vérifié** (`is_verified=True`)
- ❌ Les **admins** peuvent créer des événements (pas de restriction)

**Code :** `backend/events/views.py` ligne 248-250
```python
elif self.action == 'create':
    # Only verified users can create (admins shouldn't create directly)
    return [IsAuthenticated(), IsVerifiedOrReadOnly()]
```

---

### ✅ **Créer un Groupe**
**Permission requise :** `IsActiveAndVerified`
- ✅ L'utilisateur doit être **authentifié** (`IsAuthenticated`)
- ✅ L'utilisateur doit être **actif** (`is_active=True`)
- ✅ L'utilisateur doit être **vérifié** (`is_verified=True`)
- ❌ Les **admins** **NE PEUVENT PAS** créer de groupes directement

**Code :** `backend/groups/views.py` ligne 68-70, 76-83
```python
elif self.action == 'create':
    # Only verified users can create (admins shouldn't create directly)
    return [IsAuthenticated(), IsActiveAndVerified()]

def perform_create(self, serializer):
    # Prevent admins from creating groups directly
    if (self.request.user.is_staff or 
        self.request.user.is_superuser or 
        self.request.user.role == 'admin'):
        raise PermissionDenied('Les administrateurs ne peuvent pas créer de groupes directement.')
```

---

## 🚨 Problèmes Courants

### ❌ Erreur : "Votre compte doit être activé et vérifié"
**Cause :** L'utilisateur n'est pas vérifié (`is_verified=False`) ou pas actif (`is_active=False`)

**Solution :**
1. Exécuter le script de mise à jour des admins :
   ```bash
   python manage.py update_admins
   ```
2. Ou activer/vérifier manuellement l'utilisateur :
   ```bash
   python manage.py activate_user --email user@example.com --verify
   ```

---

### ❌ Erreur : "Les administrateurs ne peuvent pas créer de groupes directement"
**Cause :** Un admin essaie de créer un groupe

**Solution :** Les admins ne peuvent pas créer de groupes. Seuls les étudiants et responsables de classe peuvent créer des groupes.

**Pour tester la création de groupes :**
- Utiliser un compte **étudiant** (`role='student'`)
- Le compte doit être **actif** et **vérifié**

---

## ✅ Vérifier les Permissions d'un Utilisateur

### Via le Shell Django
```python
python manage.py shell

from django.contrib.auth import get_user_model
User = get_user_model()

user = User.objects.get(email='user@example.com')
print(f"Actif: {user.is_active}")
print(f"Vérifié: {user.is_verified}")
print(f"Rôle: {user.role}")
```

### Via la Commande Django
```bash
python manage.py get_active_accounts --role student
python manage.py list_users
```

---

## 📝 Checklist pour Créer un Événement

- [ ] Utilisateur authentifié (connecté)
- [ ] `is_verified=True`
- [ ] Token JWT valide (non expiré)

---

## 📝 Checklist pour Créer un Groupe

- [ ] Utilisateur authentifié (connecté)
- [ ] `is_active=True`
- [ ] `is_verified=True`
- [ ] Rôle = `student` ou `class_leader` (pas `admin`)
- [ ] Token JWT valide (non expiré)

---

## 🔧 Commandes Utiles

### Mettre à jour tous les admins
```bash
python manage.py update_admins
```

### Activer et vérifier un utilisateur
```bash
python manage.py activate_user --email user@example.com --verify
```

### Lister les utilisateurs actifs
```bash
python manage.py get_active_accounts
```

### Lister tous les utilisateurs
```bash
python manage.py list_users
```

