# CampusLink - Plateforme de Communication Étudiante

CampusLink est une plateforme complète de communication et de gestion pour les étudiants, permettant la création d'événements, la gestion de groupes/clubs, la messagerie en temps réel, et bien plus encore.

## 🚀 Fonctionnalités Principales

### 👥 Gestion des Utilisateurs
- Inscription et authentification sécurisée
- Vérification par OTP (email/téléphone)
- Système d'amitié avec demandes d'amis
- Profils utilisateurs personnalisables
- Gestion des rôles (étudiant, responsable de classe, admin)

### 📅 Événements
- Création et gestion d'événements
- Système de participation et d'invitations
- Commentaires et likes
- Géolocalisation et recherche par proximité
- Analytics pour organisateurs

### 👨‍👩‍👧‍👦 Groupes/Clubs
- Création de groupes publics/privés
- Système de membres avec rôles (admin, modérateur, membre)
- Posts dans les groupes
- Invitations et demandes d'adhésion

### 💬 Messagerie
- **Conversations privées** : Discutez directement avec vos amis
- **Conversations de groupes** : Communiquez avec tous les membres d'un groupe
- Interface style WhatsApp avec séparation claire
- Notifications en temps réel pour nouveaux messages
- Support des messages texte

### 📢 Feed/Actualités
- Feed d'actualités et annonces
- Posts sociaux avec commentaires et likes
- Modération de contenu

### 🔔 Notifications
- Notifications pour demandes d'amis (envoi, acceptation, rejet)
- Notifications pour nouveaux messages
- Notifications pour événements et groupes
- Système de notifications en temps réel

### 👨‍💼 Administration
- Dashboard admin avec statistiques
- Gestion des utilisateurs (vérification, bannissement)
- Modération de contenu (posts, événements, groupes)
- Audit logs pour traçabilité
- Gestion des responsables de classe

## 🛠️ Technologies

### Backend
- **Django 4.2** - Framework Python
- **Django REST Framework** - API REST
- **PostgreSQL** - Base de données
- **Django Channels** - WebSockets pour temps réel
- **JWT** - Authentification
- **Celery** - Tâches asynchrones

### Frontend
- **Next.js 14** - Framework React
- **TypeScript** - Typage statique
- **Tailwind CSS** - Styling
- **Axios** - Client HTTP
- **React Hook Form** - Gestion de formulaires
- **Zod** - Validation de schémas

## 📋 Prérequis

- Python 3.10+
- Node.js 18+
- PostgreSQL 14+
- Redis (pour WebSockets et cache)

## 🔧 Installation

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

## 📁 Structure du Projet

```
campusLink/
├── backend/              # API Django
│   ├── users/           # Gestion des utilisateurs
│   ├── events/          # Gestion des événements
│   ├── groups/          # Gestion des groupes
│   ├── messaging/       # Système de messagerie
│   ├── notifications/   # Système de notifications
│   ├── moderation/      # Modération de contenu
│   └── ...
├── frontend/            # Application Next.js
│   ├── src/
│   │   ├── app/        # Pages Next.js
│   │   ├── components/ # Composants React
│   │   ├── services/   # Services API
│   │   └── context/    # Contextes React
│   └── ...
└── README.md
```

## 🔐 Configuration

### Variables d'Environnement Backend

Créez un fichier `.env` dans `backend/` :

```env
SECRET_KEY=your-secret-key
DEBUG=True
DATABASE_URL=postgresql://user:password@localhost:5432/campuslink
REDIS_URL=redis://localhost:6379/0
```

### Variables d'Environnement Frontend

Créez un fichier `.env.local` dans `frontend/` :

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
```

## 🎯 Utilisation

### Compte de Test

- **Email** : `etudiant@esmt.sn`
- **Mot de passe** : `Etudiant123!`

### Workflow Messagerie

1. **Conversations Privées** :
   - Aller dans Messages → Onglet "Privées"
   - Cliquer sur un ami pour démarrer une conversation
   - Ou utiliser le bouton "+" pour créer une nouvelle conversation

2. **Conversations de Groupes** :
   - Rejoindre un groupe depuis la page Groupes
   - Cliquer sur "Discuter" pour accéder à la conversation
   - Tous les membres peuvent voir et répondre aux messages

### Workflow Amitiés

1. Envoyer une demande d'ami → Notification envoyée
2. Accepter/Refuser → Notification envoyée à l'expéditeur
3. Une fois amis, vous pouvez démarrer une conversation

## 📝 API Endpoints Principaux

### Authentification
- `POST /api/auth/register/` - Inscription
- `POST /api/auth/login/` - Connexion
- `POST /api/auth/verify-otp/` - Vérification OTP

### Messagerie
- `GET /api/messaging/conversations/` - Liste des conversations
- `GET /api/messaging/conversations/group_conversation/?group_id=...` - Conversation de groupe
- `POST /api/messaging/conversations/create_private/` - Créer conversation privée
- `GET /api/messaging/messages/?conversation=...` - Messages d'une conversation
- `POST /api/messaging/messages/` - Envoyer un message

### Groupes
- `GET /api/groups/` - Liste des groupes
- `POST /api/groups/{id}/join/` - Rejoindre un groupe
- `POST /api/groups/{id}/leave/` - Quitter un groupe

## 🧪 Tests

```bash
# Backend
cd backend
pytest

# Frontend
cd frontend
npm test
```

## 📄 Licence

Ce projet est sous licence MIT.

## 👥 Contributeurs

- GCS2092

## 🔗 Liens

- **Repository GitHub** : https://github.com/GCS2092/campuslink
- **Documentation** : Voir les fichiers `.md` dans le projet

## 🆘 Support

Pour toute question ou problème, ouvrez une issue sur GitHub.

---

**Développé avec ❤️ pour la communauté étudiante**
