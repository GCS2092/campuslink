# 🔐 Identifiants de Connexion - CampusLink

## ⚠️ IMPORTANT
Ces identifiants sont basés sur le fichier `create_users.py`. Vérifiez en base de données avec la commande Django pour confirmer.

---

## 📋 Comptes Créés via create_users.py

**Mot de passe par défaut pour tous ces comptes**: `Password@123`

### 1. Administrateur Global
- **Email**: `slovengama@gmail.com`
- **Username**: `admin`
- **Mot de passe**: `Password@123`
- **Rôle**: `admin`
- **Statut**: Staff + Superuser
- **Note**: Ce compte devrait être actif et vérifié

---

### 2. Étudiant 1
- **Email**: `etudiant1@esmt.sn`
- **Username**: `etudiant1`
- **Mot de passe**: `Password@123`
- **Rôle**: `student`
- **Statut**: Peut être inactif (selon dernière désactivation)

---

### 3. Étudiant 2
- **Email**: `etudiant2@esmt.sn`
- **Username**: `etudiant2`
- **Mot de passe**: `Password@123`
- **Rôle**: `student`
- **Statut**: Peut être inactif (selon dernière désactivation)

---

### 4. Professeur 1
- **Email**: `professeur1@esmt.sn`
- **Username**: `professeur1`
- **Mot de passe**: `Password@123`
- **Rôle**: `teacher`
- **Statut**: Peut être inactif

---

### 5. Chef de Classe 1
- **Email**: `chef.classe1@esmt.sn`
- **Username**: `chef_classe1`
- **Mot de passe**: `Password@123`
- **Rôle**: `class_leader`
- **Statut**: Peut être inactif

---

### 6. Admin Université 1
- **Email**: `admin.univ1@esmt.sn`
- **Username**: `admin_univ1`
- **Mot de passe**: `Password@123`
- **Rôle**: `university_admin`
- **Statut**: Peut être inactif

---

### 7. Stem (Étudiant)
- **Email**: `stem@esmt.sn`
- **Username**: `stem`
- **Mot de passe**: `Password@123`
- **Rôle**: `student`
- **Statut**: Peut être inactif

---

### 8. Étudiant Principal
- **Email**: `etudiant@esmt.sn`
- **Username**: `etudiant`
- **Mot de passe**: `Password@123`
- **Rôle**: `student`
- **Statut**: Peut être inactif

---

## 🔍 Vérification en Base de Données

### Commande pour vérifier les comptes actifs (depuis le shell Render) :

```bash
python manage.py get_active_accounts
```

### Commande pour activer un compte :

```bash
python manage.py activate_user --email user@example.com --verify
```

### Commande pour lister tous les utilisateurs :

```bash
python manage.py list_users
```

---

## 🚨 Problèmes de Connexion Identifiés dans les Logs

D'après les logs Render, je vois :

1. **Tentatives de connexion WebSocket rejetées** - Les connexions WebSocket sont rejetées, probablement à cause de l'authentification
2. **Tokens expirés** - Des erreurs "Token is expired" apparaissent
3. **Erreurs 401** - Des tentatives de login retournent 401 (non autorisé)

### Causes possibles :

1. **Compte inactif** - Le compte que vous utilisez n'est peut-être pas actif
2. **Compte non vérifié** - Le compte n'est peut-être pas vérifié
3. **Mauvais mot de passe** - Le mot de passe peut avoir été changé
4. **Token expiré** - Les tokens JWT expirent après un certain temps

---

## ✅ Solution Recommandée

### 1. Vérifier les comptes actifs sur Render :

Dans le shell Render, exécutez :
```bash
python manage.py get_active_accounts
```

### 2. Si aucun compte actif, activer le compte admin :

```bash
python manage.py activate_user --email slovengama@gmail.com --verify
```

### 3. Essayer de se connecter avec :

- **Email**: `slovengama@gmail.com`
- **Username**: `admin`
- **Mot de passe**: `Password@123`

---

## 📝 Notes Importantes

- Le mot de passe par défaut est `Password@123` pour tous les comptes créés via `create_users.py`
- Si vous avez changé le mot de passe, vous devrez le réinitialiser
- Les comptes peuvent être inactifs suite à la dernière opération de désactivation
- Seul le compte `admin` devrait être actif selon la dernière désactivation

---

## 🔄 Commandes Utiles sur Render

### Vérifier les utilisateurs actifs :
```bash
python manage.py get_active_accounts
```

### Activer un compte :
```bash
python manage.py activate_user --email email@example.com --verify
```

### Créer un superutilisateur (si nécessaire) :
```bash
python manage.py createsuperuser
```

---

**⚠️ IMPORTANT**: Ne partagez jamais ces identifiants publiquement. Changez les mots de passe en production.

