# 🔐 Identifiants de Connexion - CampusLink

## ⚠️ IMPORTANT - LISEZ D'ABORD

Les identifiants ci-dessous sont basés sur les fichiers de configuration. **Vous devez vérifier en base de données** pour confirmer quels comptes sont réellement actifs.

---

## 🔍 VÉRIFICATION EN BASE DE DONNÉES (PRIORITAIRE)

### Depuis le Shell Render, exécutez :

```bash
python manage.py get_active_accounts
```

Cette commande affichera tous les comptes actifs avec leurs identifiants.

---

## 📋 COMPTES SELON LES FICHIERS DE CONFIGURATION

### Mot de passe par défaut : `Password@123`

*(Pour tous les comptes créés via `create_users.py`)*

---

## 🔐 COMPTE ADMINISTRATEUR GLOBAL

### Option 1 (selon create_users.py) :
- **Email**: `slovengama@gmail.com`
- **Username**: `admin`
- **Mot de passe**: `Password@123`
- **Rôle**: `admin`
- **Statut**: Staff + Superuser

### Option 2 (selon INFORMATIONS_CONNEXION.md) :
- **Email**: `admin@campuslink.sn`
- **Username**: `admin`
- **Mot de passe**: `Password@123` (probablement)
- **Rôle**: `admin`
- **Statut**: Staff + Superuser

**⚠️ Essayez les deux emails si l'un ne fonctionne pas !**

---

## 🔐 COMPTE ADMIN UNIVERSITÉ

### Selon INFORMATIONS_CONNEXION.md :
- **Email**: `stem@esmt.sn`
- **Username**: `stem`
- **Mot de passe**: `Password@123` (probablement)
- **Rôle**: `university_admin`
- **Statut**: Actif et Vérifié

---

## 📝 AUTRES COMPTES CRÉÉS (peuvent être inactifs)

### Étudiant 1
- **Email**: `etudiant1@esmt.sn`
- **Username**: `etudiant1`
- **Mot de passe**: `Password@123`

### Étudiant 2
- **Email**: `etudiant2@esmt.sn`
- **Username**: `etudiant2`
- **Mot de passe**: `Password@123`

### Professeur 1
- **Email**: `professeur1@esmt.sn`
- **Username**: `professeur1`
- **Mot de passe**: `Password@123`

### Chef de Classe 1
- **Email**: `chef.classe1@esmt.sn`
- **Username**: `chef_classe1`
- **Mot de passe**: `Password@123`

### Admin Université 1
- **Email**: `admin.univ1@esmt.sn`
- **Username**: `admin_univ1`
- **Mot de passe**: `Password@123`

### Étudiant Principal
- **Email**: `etudiant@esmt.sn`
- **Username**: `etudiant`
- **Mot de passe**: `Password@123`

---

## 🚨 PROBLÈMES IDENTIFIÉS DANS LES LOGS RENDER

D'après les logs que vous avez partagés :

1. **Connexions WebSocket rejetées** - `WSREJECT /ws/chat/...`
2. **Tokens expirés** - `Token is expired`
3. **Erreurs 401** - `POST /api/auth/login/ 401`

### Causes possibles :

1. ✅ **Compte inactif** - Le compte n'est peut-être pas actif
2. ✅ **Compte non vérifié** - Le compte n'est peut-être pas vérifié
3. ✅ **Mauvais identifiants** - Email ou mot de passe incorrect
4. ✅ **Token expiré** - Les tokens JWT expirent après un certain temps

---

## ✅ SOLUTION ÉTAPE PAR ÉTAPE

### Étape 1 : Vérifier les comptes actifs

Dans le shell Render :
```bash
python manage.py get_active_accounts
```

### Étape 2 : Si aucun compte actif, activer le compte admin

```bash
# Essayer avec l'email du fichier create_users.py
python manage.py activate_user --email slovengama@gmail.com --verify

# OU essayer avec l'email du fichier INFORMATIONS_CONNEXION.md
python manage.py activate_user --email admin@campuslink.sn --verify
```

### Étape 3 : Essayer de se connecter

**Option A** (selon create_users.py) :
- Email: `slovengama@gmail.com`
- Username: `admin`
- Mot de passe: `Password@123`

**Option B** (selon INFORMATIONS_CONNEXION.md) :
- Email: `admin@campuslink.sn`
- Username: `admin`
- Mot de passe: `Password@123`

### Étape 4 : Si ça ne fonctionne toujours pas

Créer un nouveau superutilisateur :
```bash
python manage.py createsuperuser
```

---

## 🔄 COMMANDES UTILES SUR RENDER

### Vérifier tous les utilisateurs :
```bash
python manage.py list_users
```

### Vérifier les comptes actifs :
```bash
python manage.py get_active_accounts
```

### Activer un compte :
```bash
python manage.py activate_user --email email@example.com --verify
```

### Créer un superutilisateur :
```bash
python manage.py createsuperuser
```

### Vérifier les migrations :
```bash
python manage.py showmigrations
python manage.py migrate
```

---

## 📊 STATISTIQUES ATTENDUES

Selon le dernier rapport de désactivation :
- **Total comptes actifs**: 2-3 (admin + university_admin)
- **Total comptes inactifs**: 5+
- **Comptes admin/university_admin actifs**: 2

---

## ⚠️ NOTES IMPORTANTES

1. **Vérifiez toujours en base de données** avant d'essayer de vous connecter
2. Le mot de passe par défaut est `Password@123` pour les comptes créés via `create_users.py`
3. Si vous avez changé le mot de passe, vous devrez le réinitialiser
4. Les comptes peuvent être inactifs suite à la dernière opération de désactivation
5. Les tokens JWT expirent - si vous voyez "Token is expired", reconnectez-vous

---

## 🔐 SÉCURITÉ

**⚠️ IMPORTANT**: 
- Ne partagez jamais ces identifiants publiquement
- Changez les mots de passe en production
- Utilisez des mots de passe forts en production

---

**Dernière mise à jour**: Basé sur les fichiers `create_users.py` et `INFORMATIONS_CONNEXION.md`

