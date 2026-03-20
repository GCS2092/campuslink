# CampusLink — Résumé portfolio (format “CMS”)

## Liens
- **GitHub**
  - Label : GitHub
  - URL : https://github.com/tonpseudo
- **LinkedIn**
  - Label : LinkedIn
  - URL : https://linkedin.com/in/tonprofil

---

## Hero (FR)
- **Titre (Hero)**
  - CampusLink
- **Sous-titre (Hero)**
  - Plateforme de communication étudiante (web + mobile) : événements, groupes, feed, notifications et messagerie temps réel.

---

## Frameworks & outils (FR)
- **Titre (section)**
  - Frameworks & outils
- **Texte (section)**
  - Next.js 14 / React 18 / TypeScript / Tailwind côté web, Django REST + Channels côté backend, PostgreSQL + Redis pour les données et le temps réel, et un client mobile Flutter connecté à la même API.

---

## Bloc — Highlights (FR)
- **Titre**
  - Ce que je sais apporter sur un projet
- **Texte**
  - Approche “produit” : architecture claire, API documentée (Swagger/ReDoc), gestion des erreurs, auth JWT (incluant WebSocket cross-domain), et déploiement guidé (Vercel + Railway/Render). Je sais livrer une UI responsive, brancher une API proprement, et rendre l’ensemble maintenable.

---

## Projet (entrée portfolio)
- **Titre**
  - CampusLink
- **Slug**
  - campuslink
- **Année**
  - 2026
- **Statut**
  - En développement / En production
- **Lien externe**
  - https://...

### Description courte
Plateforme tout-en-un pour la vie étudiante : événements, groupes/clubs, feed, notifications et messagerie (privée + groupes) avec une API Django.

### Description complète
CampusLink est une application multi-clients (web + mobile) connectée à un backend Django.

Principales fonctionnalités :
- Authentification JWT, profils, rôles
- Événements : création, participation, interactions
- Groupes/clubs : gestion des membres et contenus
- Messagerie : conversations privées et de groupe, temps réel via WebSockets (Channels)
- Notifications et modération
- Documentation API : Swagger / ReDoc

Déploiement typique :
- Frontend Next.js sur Vercel
- Backend Django sur Railway ou Render
- PostgreSQL + Redis

### Tags (séparés par virgules)
Next.js, Django, API REST, WebSocket, Flutter, PostgreSQL, Redis, Auth JWT, Vercel, Render

### Stack (technologies)
- Next.js 14
- React 18
- TypeScript
- Tailwind CSS
- Django 4.2 + DRF
- Django Channels + Daphne
- PostgreSQL
- Redis
- Flutter (Dart)

---

## Architecture (Mermaid)
```mermaid
flowchart TD
  U[Utilisateur] --> W[Frontend Web (Next.js)]
  U --> M[Mobile (Flutter)]
  W -->|HTTP REST| API[Backend Django REST]
  M -->|HTTP REST| API
  W -->|WebSocket| WS[Channels / WebSocket]
  API --> DB[(PostgreSQL)]
  WS --> R[(Redis)]
  API --> R
```
