# 🚀 Démarrage Rapide - CampusLink

## ✅ Configuration Terminée !

Toutes les commandes nécessaires ont été exécutées avec succès :

### ✅ Migrations créées et appliquées
- ✅ `users` - Modèles utilisateurs
- ✅ `events` - Modèles événements  
- ✅ `social` - Modèles sociaux
- ✅ `notifications` - Modèles notifications
- ✅ `moderation` - Modèles modération

### ✅ Superutilisateur créé
- **Email**: `admin@campuslink.sn`
- **Password**: `admin123`
- **⚠️ IMPORTANT**: Changez le mot de passe après la première connexion !

### ✅ Vérification système
- Aucune erreur détectée dans la configuration Django

---

## 🎯 Prochaines Étapes

### 1. Démarrer le serveur Backend

```bash
cd backend
.\venv\Scripts\Activate.ps1
python manage.py runserver
```

Le serveur sera accessible sur : **http://localhost:8000**

### 2. Accéder à l'interface d'administration

- **URL**: http://localhost:8000/admin
- **Email**: admin@campuslink.sn
- **Password**: admin123

### 3. Documentation API

- **Swagger UI**: http://localhost:8000/api/docs/
- **ReDoc**: http://localhost:8000/api/redoc/

### 4. Démarrer le Frontend

Dans un nouveau terminal :

```bash
cd frontend
npm run dev
```

Le frontend sera accessible sur : **http://localhost:3000**

---

## 📋 Endpoints API Principaux

### Authentification
- `POST /api/auth/register/` - Inscription
- `POST /api/auth/login/` - Connexion
- `POST /api/auth/verify-phone/` - Vérification téléphone
- `GET /api/auth/verification-status/` - Statut vérification

### Utilisateurs
- `GET /api/users/` - Liste utilisateurs
- `GET /api/auth/profile/` - Profil utilisateur connecté

### Événements
- `GET /api/events/` - Liste événements
- `POST /api/events/` - Créer événement (vérifié uniquement)
- `GET /api/events/{id}/` - Détails événement

### Social
- `GET /api/social/posts/` - Liste posts
- `POST /api/social/posts/` - Créer post (vérifié uniquement)

---

## 🔧 Configuration Actuelle

### Base de Données
- ✅ PostgreSQL connecté
- ✅ Toutes les tables créées
- ✅ Index optimisés configurés

### Redis (Optionnel pour développement)
Si Redis n'est pas installé, certaines fonctionnalités (cache, OTP) fonctionneront en mode dégradé.

### Variables d'Environnement
Vérifiez que votre fichier `backend/.env` contient :
- Configuration PostgreSQL ✅
- `SECRET_KEY` ✅
- `DEBUG=True` ✅

---

## 🧪 Tester l'API

### Exemple avec curl

```bash
# Inscription
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@esmt.sn",
    "username": "testuser",
    "password": "test123",
    "password_confirm": "test123",
    "phone_number": "+221771234567"
  }'

# Connexion
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@esmt.sn",
    "password": "test123"
  }'
```

---

## 📚 Documentation Complète

- [SETUP.md](./SETUP.md) - Guide d'installation détaillé
- [README.md](./README.md) - Documentation principale
- [ARCHITECTURE.txt](./ARCHITECTURE.txt) - Architecture technique
- [description.txt](./description.txt) - Description du projet

---

## 🎉 Tout est prêt !

Votre projet CampusLink est maintenant configuré et prêt à être utilisé. 

**Bon développement ! 🚀**

