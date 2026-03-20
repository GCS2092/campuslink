# CampusLink — Documentation complète du projet

## 1) Vue d’ensemble
CampusLink est une plateforme de communication et de gestion de la vie étudiante.

Objectifs principaux :
- Centraliser les informations et échanges (feed, messagerie, notifications)
- Faciliter l’organisation (événements, groupes/clubs)
- Proposer un socle admin (modération, rôles, audit)
- Offrir plusieurs clients : web (Next.js) et mobile (Flutter)

---

## 2) Fonctionnalités (produit)
### 2.1 Gestion utilisateurs
- Inscription / connexion
- Authentification JWT
- Vérification OTP (email / téléphone) (prévue via services)
- Gestion de rôles (étudiant, responsable, admin)
- Profils et relations sociales (ex: amitiés)

### 2.2 Événements
- Création / gestion d’événements
- Participation, invitations
- Interactions (commentaires / likes)
- Géolocalisation / proximité (selon configuration)

### 2.3 Groupes / clubs
- Groupes publics / privés
- Rôles de membres (admin, modérateur, membre)
- Publications internes au groupe

### 2.4 Messagerie & temps réel
- Conversations privées et de groupe
- WebSockets via Django Channels
- Auth WebSocket en JWT (support cross-domain)

### 2.5 Feed / actualités
- Posts, commentaires, likes
- Modération

### 2.6 Notifications
- Notifications d’amitié
- Notifications de messages
- Notifications liées à événements / groupes

### 2.7 Administration
- Dashboard admin
- Modération de contenu
- Audit logs (traçabilité)

---

## 3) Architecture (technique)
### 3.1 Macro-architecture
- **Backend** : Django + Django REST Framework (API REST) + Channels (WebSockets)
- **Frontend Web** : Next.js 14 (React 18) + TypeScript + Tailwind CSS
- **Client Mobile** : Flutter (Dart)
- **Base de données** : PostgreSQL
- **Cache / broker / Channels layer** : Redis

### 3.2 Diagramme (Mermaid)
```mermaid
flowchart TD
  U[Utilisateur] --> W[Frontend Web (Next.js)]
  U --> M[Mobile (Flutter)]

  W -->|HTTP REST| API[Backend Django REST]
  M -->|HTTP REST| API

  W -->|WebSocket| WS[Channels / WebSocket]
  M -->|WebSocket (optionnel)| WS

  API --> DB[(PostgreSQL)]
  WS --> R[(Redis)]
  API --> R
```

### 3.3 Structure du repository
- `backend/` : API Django + WebSockets (Channels)
- `frontend/` : application Next.js
- `lib/`, `android/`, `ios/`, … : application Flutter (racine Flutter)
- `CampusExpo/` : sous-projet expo / tests (présent dans le repo)
- Plusieurs fichiers `.md` : guides, récap, corrections, déploiement

---

## 4) Stack & dépendances principales
### 4.1 Backend (Python)
Dépendances clés (voir `backend/requirements.txt`) :
- `Django==4.2.7` : socle web
- `djangorestframework==3.14.0` : API REST
- `djangorestframework-simplejwt==5.5.1` : JWT access/refresh
- `channels==4.0.0` + `daphne==4.0.0` : ASGI & WebSockets
- `channels-redis==4.1.0` + `redis==5.0.1` : layer Channels & cache
- `psycopg2-binary==2.9.10` + `dj-database-url==2.1.0` : PostgreSQL
- `celery==5.3.4` + `django-celery-beat==2.5.0` : tâches asynchrones
- `drf-yasg==1.21.7` : documentation Swagger / ReDoc
- `django-cors-headers==4.3.1` : CORS
- `cloudinary` + `django-cloudinary-storage` : stockage médias
- `sentry-sdk` : monitoring
- `twilio` + `django-ses` : SMS/email (selon configuration)

Apps Django (extrait de `INSTALLED_APPS`) :
- `users`, `events`, `groups`, `messaging`, `notifications`, `moderation`, `payments`, `feed`, `social`, `core`

### 4.2 Frontend Web (Node)
Dépendances clés (voir `frontend/package.json`) :
- `next@14.0.4`, `react@18` : framework UI
- `typescript` : typage
- `tailwindcss` : styling
- `axios` : client HTTP
- `react-query` : gestion d’état “serveur”
- `zustand` : état client
- `zod` + `react-hook-form` : formulaires & validation
- `socket.io-client` : client temps réel côté web (selon usage)
- `firebase` : notifications push (configuration requise)

### 4.3 Mobile (Flutter)
Dépendances clés (voir `pubspec.yaml`) :
- `dio` : HTTP
- `provider` / `get` : state management
- `flutter_secure_storage` / `shared_preferences` : stockage local
- `web_socket_channel` : WebSocket
- `intl` : formats / i18n
- `cached_network_image` : images
- `firebase_core` / `firebase_crashlytics` : monitoring crash (config requise)

---

## 5) Exécution en local
### 5.1 Prérequis
- Python 3.10+
- Node 18+
- PostgreSQL
- Redis

### 5.2 Backend (Django)
Voir `SETUP.md` et `README.md`.

Résumé :
- Créer un venv
- `pip install -r backend/requirements.txt`
- Configurer `backend/.env`
- `python manage.py migrate`
- `python manage.py runserver`

### 5.3 Frontend (Next.js)
- `npm install`
- Configurer `frontend/.env.local` :
  - `NEXT_PUBLIC_API_URL=http://localhost:8000/api`
- `npm run dev`

### 5.4 Mobile (Flutter)
- `flutter pub get`
- Configurer l’URL backend dans `lib/utils/constants.dart` (voir `CONFIGURATION_BACKEND_FLUTTER.md`)
- `flutter run`

---

## 6) Variables d’environnement (référence)
### 6.1 Backend
- `SECRET_KEY`
- `DEBUG`
- `ALLOWED_HOSTS`
- `DATABASE_URL` (prod) ou `DB_HOST`/`DB_PORT`/`DB_USERNAME`/`DB_PASSWORD`/`DB_DATABASE` (local)
- `REDIS_URL` (ou variables Redis selon hébergeur)
- `CORS_ALLOWED_ORIGINS` ou `CORS_ALLOW_ALL_ORIGINS=True` (selon stratégie)
- Optionnels : Cloudinary, Twilio, AWS SES, Sentry, Celery…

### 6.2 Frontend
- `NEXT_PUBLIC_API_URL` (doit être en **https** en prod)
- Optionnels : `NEXT_PUBLIC_FIREBASE_*`

---

## 7) API — points d’entrée
- Documentation :
  - Swagger UI : `/api/docs/`
  - ReDoc : `/api/redoc/`
- Routes principales (voir `backend/campuslink/urls.py`) :
  - `/api/auth/`, `/api/users/`
  - `/api/events/`
  - `/api/groups/`, `/api/messaging/`, `/api/notifications/`, `/api/social/`, `/api/moderation/`, `/api/search/`, etc.

---

## 8) Déploiement
Références :
- `DEPLOYMENT_QUICK_START.md`
- `backend/RAILWAY_DEPLOYMENT.md`
- `backend/RENDER_DEPLOYMENT.md`
- `frontend/vercel.json`

### 8.1 Recommandation simple
- **Frontend** sur **Vercel** (root directory : `frontend`)
- **Backend** sur **Railway** ou **Render**
- **PostgreSQL** sur la même plateforme que le backend

### 8.2 Points d’attention
- CORS : inclure l’URL Vercel (prod + previews) côté backend
- Mixed content : `NEXT_PUBLIC_API_URL` doit être en `https://...` (voir `frontend/FIX_MIXED_CONTENT.md`)
- WebSockets : en production, utiliser ASGI (`daphne`) pour Channels

---

## 9) Qualité, tests, maintenance
- Frontend : Jest + Playwright (scripts disponibles)
- Backend : `pytest` (config `backend/pytest.ini`)

---

## 10) Liens
- Repo : (à renseigner)
- Démo : (à renseigner)

