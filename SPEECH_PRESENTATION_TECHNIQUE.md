# Speech — Présentation “Technique” (public dev / IT)

## 1) Contexte & objectifs (20–30s)
Je vous présente **CampusLink**, une plateforme orientée “vie étudiante” avec **3 clients** :
- **Web** (Next.js)
- **Mobile** (Flutter)
- **Backend** (Django) exposant une **API REST** + une couche **temps réel** via WebSockets.

Objectif : fournir un socle produit (events, groups, feed, messaging, notifications) avec une architecture maintenable et déployable.

## 2) Stack (30–45s)
- **Backend** : Django 4.2 + Django REST Framework
- **Auth** : JWT (SimpleJWT)
- **Temps réel** : Django Channels + Daphne (ASGI)
- **DB** : PostgreSQL
- **Cache / channel layer** : Redis (`channels-redis`)
- **Doc API** : drf-yasg (Swagger/ReDoc)

- **Frontend Web** : Next.js 14 / React 18 / TypeScript / Tailwind
  - Data fetching : Axios
  - State : React Query (server-state) + Zustand (client-state)

- **Mobile** : Flutter
  - HTTP : Dio (interceptors)
  - state : Provider / Get
  - storage : secure storage / shared prefs

## 3) Architecture & flux (45s–1m)
### 3.1 REST
- Le web et le mobile consomment l’API REST sur `.../api/...`.
- Les endpoints sont regroupés par domaines : `users`, `events`, `groups`, `messaging`, `feed`, `notifications`, etc.
- Les docs Swagger/ReDoc sont exposées sur `/api/docs/` et `/api/redoc/`.

### 3.2 WebSockets
- Les features de chat utilisent **Channels**.
- ASGI est initialisé dans `backend/campuslink/asgi.py`.
- Le routing WS se fait via `messaging.routing`.

### 3.3 Déploiement recommandé
- **Frontend** sur **Vercel** (root directory `frontend`)
- **Backend** sur **Railway** ou **Render**
- DB PostgreSQL + Redis sur la plateforme backend

## 4) Points durs rencontrés (et comment ils ont été résolus) (1m)
Je mets l’accent sur trois sujets “réalistes” rencontrés en prod :

### 4.1 Mixed Content (HTTPS → HTTP)
- Problème : Vercel force HTTPS, mais une API en HTTP déclenche un blocage navigateur.
- Fix : `NEXT_PUBLIC_API_URL` doit pointer vers une URL API **HTTPS** + redeploy.

### 4.2 CORS cross-domain (Vercel ↔ backend)
- Problème : appels API bloqués ou 401/erreurs si CORS mal configuré.
- Fix : config `CORS_ALLOWED_ORIGINS` ou `CORS_ALLOW_ALL_ORIGINS=True` selon la stratégie (notamment pour les preview deployments Vercel).

### 4.3 WebSocket auth cross-domain
- Problème : `AuthMiddlewareStack` (sessions) ne convient pas en cross-domain stateless.
- Fix : ajout d’un middleware **JWTAuthMiddleware** pour WebSocket :
  - token lu depuis `?token=...` ou header `Authorization`
  - côté front, inclusion du token dans l’URL WS.

## 5) Qualité / maintenabilité (30–45s)
- Séparation par domaines (apps Django) + routes API structurées.
- Validation et sécurité côté API : JWT + permissions.
- Documentation d’API automatiquement générée.
- Côté web : typage TS + validation Zod + form handling.
- Côté mobile : services dédiés + parsing robuste + gestion d’erreurs.

## 6) Limites techniques / prochaines étapes (30–45s)
- **Tests** : présents côté web (Jest/Playwright) et backend (pytest) mais extensibles.
- **Temps réel** : en production, Redis + ASGI sont recommandés (sinon dégradations).
- **Observabilité** : Sentry est dans la stack mais nécessite configuration.
- **Scalabilité** : possibilité d’optimiser cache, pagination, rate limiting, et tâches async (Celery).

## 7) Conclusion (10–15s)
En bref : CampusLink est un projet full-stack multi-client, avec une API Django documentée, une UI moderne Next.js, un client Flutter, et un vrai temps réel via WebSockets — avec les contraintes prod classiques (CORS, HTTPS, auth WS) déjà prises en compte.
