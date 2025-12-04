# 🔐 Logique des Permissions : Qui Peut Créer Quoi ?

## 📋 Résumé Rapide

| Rôle | Créer Événements | Créer Groupes | Raison |
|------|------------------|---------------|--------|
| **Admin** | ❌ **NON** | ❌ **NON** | Les admins gèrent, ne créent pas directement |
| **University Admin** | ❌ **NON** | ❌ **NON** | Les admins gèrent, ne créent pas directement |
| **Class Leader** | ✅ **OUI** | ✅ **OUI** | Responsables de classe, peuvent créer |
| **Student** | ✅ **OUI** | ✅ **OUI** | Étudiants, peuvent créer |
| **Teacher** | ✅ **OUI** | ✅ **OUI** | Professeurs, peuvent créer |

**IMPORTANT** : Tous doivent être **actifs** (`is_active=True`) et **vérifiés** (`is_verified=True`)

---

## 🎯 Détails par Type de Création

### 1️⃣ **Créer un Événement**

#### ✅ **PEUVENT créer** :
- **Étudiants** (`role='student'`)
- **Responsables de classe** (`role='class_leader'`)
- **Professeurs** (`role='teacher'`)
- **Tout utilisateur vérifié** (sauf admins)

#### ❌ **NE PEUVENT PAS créer** :
- **Admins** (`role='admin'`)
- **Admins d'université** (`role='university_admin'`)
- **Superusers** (`is_superuser=True`)
- **Staff** (`is_staff=True`)

#### 📝 **Code de la restriction** :
```python
# backend/events/views.py ligne 256-263
def perform_create(self, serializer):
    """Create event (only verified users, not admins)."""
    # Prevent admins from creating events directly
    if (self.request.user.is_staff or 
        self.request.user.is_superuser or 
        self.request.user.role == 'admin'):
        raise PermissionDenied('Les administrateurs ne peuvent pas créer d\'événements directement.')
```

#### 🔑 **Permissions requises** :
- `IsAuthenticated` : Utilisateur connecté
- `IsVerifiedOrReadOnly` : Utilisateur actif ET vérifié

---

### 2️⃣ **Créer un Groupe**

#### ✅ **PEUVENT créer** :
- **Étudiants** (`role='student'`)
- **Responsables de classe** (`role='class_leader'`)
- **Tout utilisateur vérifié** (sauf admins)

#### ❌ **NE PEUVENT PAS créer** :
- **Admins** (`role='admin'`)
- **Admins d'université** (`role='university_admin'`)
- **Superusers** (`is_superuser=True`)
- **Staff** (`is_staff=True`)

#### 📝 **Code de la restriction** :
```python
# backend/groups/views.py ligne 76-83
def perform_create(self, serializer):
    """Create group and add creator as admin (only verified users, not admins)."""
    # Prevent admins from creating groups directly
    if (self.request.user.is_staff or 
        self.request.user.is_superuser or 
        self.request.user.role == 'admin'):
        raise PermissionDenied('Les administrateurs ne peuvent pas créer de groupes directement.')
```

#### 🔑 **Permissions requises** :
- `IsAuthenticated` : Utilisateur connecté
- `IsActiveAndVerified` : Utilisateur actif ET vérifié

---

## 🎓 Logique Métier

### Pourquoi les Admins ne peuvent pas créer ?

**Philosophie** : Les admins sont des **modérateurs** et **gestionnaires**, pas des **créateurs de contenu**.

1. **Séparation des responsabilités** :
   - **Admins** = Gèrent, modèrent, valident
   - **Étudiants/Responsables** = Créent le contenu

2. **Workflow typique** :
   - Un étudiant crée un événement/groupe
   - L'admin le modère (valide, supprime, modifie le statut)
   - L'admin peut voir tous les événements/groupes (même non publiés)

3. **Contrôle qualité** :
   - Les admins peuvent **modérer** les créations des autres
   - Ils peuvent **publier** ou **supprimer** des événements/groupes
   - Mais ils ne créent pas directement pour éviter les conflits d'intérêts

---

## 🔍 Vérification des Permissions

### Code de vérification pour Événements :
```python
# backend/events/permissions.py
class IsVerifiedOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True  # Lecture autorisée pour tous
        return (request.user and 
                request.user.is_authenticated and 
                request.user.is_active and 
                request.user.is_verified)
```

### Code de vérification pour Groupes :
```python
# backend/users/permissions.py
class IsActiveAndVerified(permissions.BasePermission):
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        if not request.user.is_active:
            raise PermissionDenied('Votre compte n\'est pas activé.')
        if not request.user.is_verified:
            raise PermissionDenied('Votre compte n\'est pas vérifié.')
        return True
```

---

## 📊 Tableau Complet des Permissions

| Action | Admin | University Admin | Class Leader | Student | Teacher |
|--------|-------|------------------|--------------|---------|---------|
| **Créer Événement** | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Créer Groupe** | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Modérer Événement** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Modérer Groupe** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Voir Tous Événements** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Voir Tous Groupes** | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## ⚠️ Conditions Communes

Pour **TOUTES** les actions de création, l'utilisateur doit :

1. ✅ **Être authentifié** (`IsAuthenticated`)
2. ✅ **Être actif** (`is_active=True`)
3. ✅ **Être vérifié** (`is_verified=True`)
4. ✅ **Avoir un token JWT valide** (non expiré)

---

## 🚨 Messages d'Erreur Courants

### "Les administrateurs ne peuvent pas créer d'événements directement"
- **Cause** : Un admin essaie de créer un événement
- **Solution** : Utiliser un compte étudiant ou responsable de classe

### "Les administrateurs ne peuvent pas créer de groupes directement"
- **Cause** : Un admin essaie de créer un groupe
- **Solution** : Utiliser un compte étudiant ou responsable de classe

### "Votre compte doit être activé et vérifié"
- **Cause** : `is_active=False` ou `is_verified=False`
- **Solution** : Exécuter `python manage.py update_admins` ou `python manage.py activate_user --email ... --verify`

### "Token is expired"
- **Cause** : Le token JWT a expiré
- **Solution** : Se reconnecter pour obtenir un nouveau token

---

## 💡 Exemples Concrets

### ✅ Scénario 1 : Étudiant crée un événement
```
Utilisateur: stem (student)
is_active: True ✅
is_verified: True ✅
Résultat: ✅ Événement créé avec succès
```

### ❌ Scénario 2 : Admin essaie de créer un événement
```
Utilisateur: admin (admin)
is_active: True ✅
is_verified: True ✅
Résultat: ❌ PermissionDenied: "Les administrateurs ne peuvent pas créer d'événements directement"
```

### ✅ Scénario 3 : Étudiant crée un groupe
```
Utilisateur: etudiant (student)
is_active: True ✅
is_verified: True ✅
Résultat: ✅ Groupe créé avec succès
```

### ❌ Scénario 4 : Utilisateur non vérifié essaie de créer
```
Utilisateur: new_user (student)
is_active: True ✅
is_verified: False ❌
Résultat: ❌ PermissionDenied: "Votre compte doit être activé et vérifié"
```

---

## 🔧 Comment Tester

### 1. Créer un compte étudiant vérifié
```bash
python manage.py create_users
# Ou
python manage.py activate_user --email stem@esmt.sn --verify
```

### 2. Se connecter avec ce compte
- Email : `stem@esmt.sn`
- Mot de passe : `Password@123`

### 3. Essayer de créer un événement/groupe
- ✅ Devrait fonctionner si le compte est vérifié

---

## 📝 Résumé en Une Phrase

**Les étudiants et responsables de classe peuvent créer des événements et des groupes, mais les admins ne peuvent que les modérer, pas les créer directement.**

