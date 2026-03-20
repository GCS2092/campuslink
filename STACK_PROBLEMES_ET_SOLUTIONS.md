# CampusLink — Stack, problèmes rencontrés, résolutions (et comment tout s’assemble)

## 1) Comment les briques fonctionnent ensemble
### 1.1 Flux “Web” (Next.js)
- L’utilisateur navigue sur le **frontend Next.js**.
- Le frontend appelle l’API via `NEXT_PUBLIC_API_URL`.
- L’API répond en JSON (Django REST Framework).
- Pour la messagerie temps réel, le frontend ouvre une connexion **WebSocket** vers le backend (Channels).

### 1.2 Flux “Mobile” (Flutter)
- L’application Flutter utilise `dio` pour appeler l’API REST.
- Le stockage local conserve tokens / sessions (secure storage / shared prefs).
- Les écrans affichent les données et gèrent les erreurs.

### 1.3 Backend (Django)
- DRF expose les endpoints REST.
- `simplejwt` gère access/refresh tokens.
- Channels + Daphne assurent l’ASGI et les WebSockets.
- PostgreSQL stocke les données.
- Redis sert de cache / channel layer (Channels) et peut servir de broker Celery.

---

## 2) Stack & rôle de chaque technologie
### 2.1 Backend
- **Django (4.2.7)**
  - Rôle : framework principal (routing, models, admin, middleware, settings).
  - Dans CampusLink : base de toutes les apps (`users`, `events`, `groups`, `messaging`, `feed`, etc.).

- **Django REST Framework**
  - Rôle : construction d’API REST (serializers, viewsets, permissions).
  - Dans CampusLink : endpoints `/api/...` (auth, events, messaging, etc.).

- **SimpleJWT (JWT access/refresh)**
  - Rôle : authentification stateless.
  - Dans CampusLink : login/refresh, protection des endpoints, token utilisé aussi côté WebSocket.

- **Django Channels + Daphne**
  - Rôle : WebSockets et asynchronisme serveur (ASGI).
  - Dans CampusLink : messagerie temps réel (routes WS, consumers) + `campuslink/asgi.py`.

- **PostgreSQL**
  - Rôle : stockage relationnel (données produits).
  - Dans CampusLink : users, posts, groupes, messages, événements, etc.

- **Redis**
  - Rôle : cache, channel layer Channels, broker/résultats Celery.
  - Dans CampusLink : support Channels via `channels-redis`.

- **Celery + django-celery-beat**
  - Rôle : tâches asynchrones (emails, notifications, jobs périodiques).
  - Dans CampusLink : présent dans la stack (à activer/configurer selon besoin).

- **drf-yasg (Swagger/ReDoc)**
  - Rôle : documentation d’API.
  - Dans CampusLink : `/api/docs/`, `/api/redoc/`.

- **django-cors-headers**
  - Rôle : autoriser le frontend (Vercel / previews) à appeler l’API.

- **Cloudinary**
  - Rôle : stockage média (images) en production.

- **Sentry**
  - Rôle : suivi d’erreurs et monitoring.

- **Twilio / SES**
  - Rôle : OTP SMS et email transactionnel (selon configuration).

### 2.2 Frontend Web
- **Next.js 14 (React 18)**
  - Rôle : UI web + routing (App Router), rendu, build.

- **TypeScript**
  - Rôle : typage et robustesse du code UI/services.

- **Tailwind CSS**
  - Rôle : styling rapide et design system utilitaire.

- **Axios**
  - Rôle : client HTTP.

- **React Query**
  - Rôle : cache, invalidation, synchronisation des données serveur.

- **Zustand**
  - Rôle : état client (UI, session, etc.).

- **Zod + React Hook Form**
  - Rôle : validation et formulaires.

- **Firebase (web)**
  - Rôle : push notifications (si configuré).

### 2.3 Mobile
- **Flutter (Dart)**
  - Rôle : client mobile multiplateforme.

- **Dio**
  - Rôle : appels HTTP + interceptors.

- **Provider / Get**
  - Rôle : gestion d’état.

- **flutter_secure_storage / shared_preferences**
  - Rôle : stockage local (tokens, préférences).

- **web_socket_channel**
  - Rôle : WebSocket temps réel.

---

## 3) Problèmes rencontrés & solutions (extraits consolidés)
### 3.1 Mixed Content en prod (Vercel HTTPS → API HTTP)
- **Symptôme** : navigateur bloque des requêtes vers `http://.../api/...` depuis un site `https://...vercel.app`.
- **Cause** : `NEXT_PUBLIC_API_URL` pointait vers une URL en HTTP.
- **Solution** : définir `NEXT_PUBLIC_API_URL` sur une URL **HTTPS** (ex: `https://campuslink-9knz.onrender.com/api`) et redéployer.
- **Doc source** : `frontend/FIX_MIXED_CONTENT.md`.

### 3.2 Auth cross-domain : 401 sur `/api/auth/profile/`
- **Symptôme** : 401 sur le profil lorsque le front est sur Vercel et le backend sur Render/Railway.
- **Cause** : token non envoyé / CORS bloque.
- **Solution** :
  - Côté backend : config CORS (origines Vercel) ou `CORS_ALLOW_ALL_ORIGINS=True` pour supporter les previews.
  - Côté front : s’assurer que l’Authorization header est bien présent.
- **Doc source** : `CORRECTIONS_AUTHENTIFICATION_CROSS_DOMAIN.md`.

### 3.3 WebSocket cross-domain : échec d’authentification
- **Symptôme** : WebSocket “failed” en production, surtout en cross-domain.
- **Cause** : `AuthMiddlewareStack` utilise des sessions; en cross-domain stateless, ça ne marche pas.
- **Solution** :
  - Ajout d’un middleware WebSocket JWT (`backend/messaging/middleware.py`).
  - Remplacement dans `backend/campuslink/asgi.py` pour utiliser `JWTAuthMiddleware`.
  - Côté front : envoi du token dans l’URL WS `?token=...`.
- **Doc source** : `CORRECTIONS_AUTHENTIFICATION_CROSS_DOMAIN.md`.

### 3.4 Backend 500 sur messaging : `MessageViewSet has no attribute action`
- **Symptôme** : 500 lors d’appels `/api/messaging/messages/`.
- **Cause** : usage de `self.action` dans un contexte où l’attribut n’est pas disponible.
- **Solution** : garde `hasattr(self, 'action')` avant accès.
- **Doc source** : `CORRECTIONS_APPLICATION.md`.

### 3.5 Backend 500 sur messaging : user anonyme
- **Symptôme** : crash si user non authentifié.
- **Cause** : queryset non protégé.
- **Solution** : check `user.is_authenticated` et retour `Message.objects.none()`.
- **Doc source** : `CORRECTIONS_AUTHENTIFICATION_CROSS_DOMAIN.md`.

### 3.6 Flutter UI : overflow sur dashboard
- **Symptôme** : overflow visuel sur cartes statistiques.
- **Cause** : paddings/typos trop grands pour certaines tailles d’écran.
- **Solution** : ajustements layout + `Flexible`, `maxLines`, `ellipsis`, ratios.
- **Doc source** : `CORRECTIONS_APPLICATION.md`.

### 3.7 Flutter : parsing types numériques (String vs num)
- **Symptôme** : `type 'String' is not a subtype of type 'num?'`.
- **Cause** : incohérence de types côté API (valeurs numériques renvoyées en string).
- **Solution** : parsing robuste côté modèle Flutter (cast safe String/int/num).
- **Doc source** : `CORRECTIONS_APPLICATION.md`.

### 3.8 Flutter : `setState() called after dispose()`
- **Symptôme** : erreur runtime dans `StudentsScreen`.
- **Cause** : async callback qui appelle `setState` après la destruction du widget.
- **Solution** : check `mounted` avant `setState`.
- **Doc source** : `CORRECTIONS_APPLICATION.md`.

---

## 4) Déploiement (résumé)
- **Frontend** : Vercel, root directory `frontend` (voir `frontend/vercel.json`).
- **Backend** : Railway ou Render.
  - Render : démarrage ASGI recommandé (Daphne) pour WebSockets.
- **Variables clés** :
  - Front : `NEXT_PUBLIC_API_URL=https://.../api`
  - Back : `SECRET_KEY`, `DEBUG=False`, `ALLOWED_HOSTS`, `DATABASE_URL`, CORS.

---

## 5) Checklist “ça marche ensemble”
- `NEXT_PUBLIC_API_URL` en **https** en prod.
- Backend : CORS autorise Vercel (prod + preview).
- WebSocket : token JWT envoyé (`?token=...` ou header) + middleware JWT côté backend.
- Redis disponible en prod si on veut un temps réel robuste.
