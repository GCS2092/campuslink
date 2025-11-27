# CampusLink - Réseau Social Étudiant

Plateforme sociale destinée aux étudiants sénégalais pour découvrir et participer à des événements culturels, sportifs, éducatifs et festifs.

## 🚀 Stack Technologique

### Frontend
- **React 18** + **Next.js 14** - Framework moderne et performant
- **TailwindCSS** - Framework CSS utilitaire
- **TypeScript** - Typage statique
- **React Query** - Gestion d'état serveur
- **Zustand** - Gestion d'état client
- **Firebase** - Notifications push

### Backend
- **Django 4.2** - Framework Python
- **Django REST Framework** - API REST
- **Django Channels** - WebSockets pour chat temps réel
- **Celery** - Tâches asynchrones
- **PostgreSQL** - Base de données
- **Redis** - Cache et queue

### Services Externes
- **Cloudinary** - Stockage d'images
- **Twilio** - SMS/OTP
- **Firebase** - Notifications push
- **Sentry** - Monitoring d'erreurs

## 📁 Structure du Projet

```
campusLink/
├── backend/          # Django Backend
│   ├── campuslink/   # Configuration Django
│   ├── users/        # App Utilisateurs
│   ├── events/       # App Événements
│   ├── social/       # App Social
│   ├── notifications/# App Notifications
│   └── moderation/   # App Modération
│
├── frontend/         # Next.js Frontend
│   ├── src/
│   │   ├── app/      # Pages Next.js
│   │   ├── components/# Composants React
│   │   ├── services/ # Services API
│   │   └── context/  # Context API
│   └── public/       # Assets statiques
│
└── docs/            # Documentation
```

## 🛠️ Installation

### Prérequis
- Python 3.10+
- Node.js 18+
- PostgreSQL
- Redis

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Configurer .env avec vos paramètres
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### Frontend

```bash
cd frontend
npm install
cp .env.local.example .env.local
# Configurer .env.local avec vos paramètres
npm run dev
```

## 🗄️ Base de Données

La base de données PostgreSQL doit être créée et configurée dans `backend/.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_DATABASE=campuslink
```

## 🔐 Authentification

L'authentification utilise JWT (JSON Web Tokens):
- Access token: 15 minutes
- Refresh token: 7 jours

## ✅ Vérification Utilisateur

Phase 1 (MVP):
- Email universitaire (validation automatique des domaines)
- Téléphone (OTP SMS via Twilio)

Phase 2 (Post-MVP):
- Matricule (optionnel, validation manuelle)

## 📚 Documentation

- [Architecture Technique](./ARCHITECTURE.txt)
- [Description du Projet](./description.txt)
- [Guide d'Implémentation](./decriptionAjout.txt)

## 🧪 Tests

### Backend
```bash
cd backend
pytest
pytest --cov
```

### Frontend
```bash
cd frontend
npm test
npm run test:e2e
```

## 🚀 Déploiement

### Backend
- **Railway** ou **Render** pour Django
- Variables d'environnement configurées sur la plateforme

### Frontend
- **Vercel** pour Next.js
- Déploiement automatique depuis GitHub

## 📝 License

MIT License

## 👥 Équipe

CampusLink Team

