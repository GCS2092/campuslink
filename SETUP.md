# Guide de Démarrage - CampusLink

Ce guide vous aidera à configurer et démarrer le projet CampusLink.

## 📋 Prérequis

- **Python 3.10+** installé
- **Node.js 18+** et npm installés
- **PostgreSQL** installé et en cours d'exécution
- **Redis** installé et en cours d'exécution

## 🚀 Installation Rapide

### 1. Configuration Backend

```bash
cd backend

# Créer environnement virtuel
python -m venv venv

# Activer l'environnement virtuel
# Windows:
venv\Scripts\Activate.ps1
# Linux/Mac:
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Créer le fichier .env (copier depuis .env.example et modifier)
cp .env.example .env

# Configurer la base de données dans .env
# DB_HOST=localhost
# DB_PORT=5432
# DB_USERNAME=postgres
# DB_PASSWORD=votre_mot_de_passe
# DB_DATABASE=campuslink

# Créer les migrations
python manage.py makemigrations

# Appliquer les migrations
python manage.py migrate

# Créer un superutilisateur
python manage.py createsuperuser

# Démarrer le serveur Django
python manage.py runserver
```

Le backend sera accessible sur `http://localhost:8000`

### 2. Configuration Frontend

```bash
cd frontend

# Installer les dépendances
npm install

# Créer le fichier .env.local (copier depuis .env.local.example)
cp .env.local.example .env.local

# Configurer l'URL de l'API dans .env.local
# NEXT_PUBLIC_API_URL=http://localhost:8000/api

# Démarrer le serveur de développement
npm run dev
```

Le frontend sera accessible sur `http://localhost:3000`

## 🗄️ Configuration Base de Données

### Créer la base de données PostgreSQL

```sql
CREATE DATABASE campuslink;
CREATE USER postgres WITH PASSWORD 'votre_mot_de_passe';
GRANT ALL PRIVILEGES ON DATABASE campuslink TO postgres;
```

### Configuration dans backend/.env

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=votre_mot_de_passe
DB_DATABASE=campuslink
```

## 🔧 Configuration Redis

### Windows
Télécharger et installer Redis depuis: https://github.com/microsoftarchive/redis/releases

### Linux/Mac
```bash
sudo apt-get install redis-server  # Ubuntu/Debian
brew install redis                 # Mac
```

Démarrer Redis:
```bash
redis-server
```

## 📝 Variables d'Environnement

### Backend (.env)

Variables essentielles:
- `SECRET_KEY` - Clé secrète Django (générer avec `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`)
- `DB_*` - Configuration PostgreSQL
- `REDIS_URL` - URL Redis
- `CORS_ALLOWED_ORIGINS` - Origines autorisées pour CORS

Variables optionnelles (pour production):
- `TWILIO_ACCOUNT_SID` / `TWILIO_AUTH_TOKEN` - Pour SMS/OTP
- `CLOUDINARY_URL` - Pour stockage d'images
- `SENTRY_DSN` - Pour monitoring d'erreurs

### Frontend (.env.local)

Variables essentielles:
- `NEXT_PUBLIC_API_URL` - URL de l'API backend

Variables optionnelles:
- `NEXT_PUBLIC_FIREBASE_*` - Pour notifications push
- `NEXT_PUBLIC_SENTRY_DSN` - Pour monitoring

## 🧪 Tests

### Backend
```bash
cd backend
pytest
pytest --cov  # Avec couverture de code
```

### Frontend
```bash
cd frontend
npm test
npm run test:e2e  # Tests E2E avec Playwright
```

## 📚 Documentation API

Une fois le serveur Django démarré, accédez à:
- **Swagger UI**: http://localhost:8000/api/docs/
- **ReDoc**: http://localhost:8000/api/redoc/

## 🐛 Dépannage

### Erreur de connexion à PostgreSQL
- Vérifier que PostgreSQL est démarré
- Vérifier les credentials dans `.env`
- Vérifier que la base de données existe

### Erreur de connexion à Redis
- Vérifier que Redis est démarré
- Vérifier `REDIS_URL` dans `.env`

### Erreurs CORS
- Vérifier `CORS_ALLOWED_ORIGINS` dans `backend/.env`
- S'assurer que l'URL du frontend est incluse

### Erreurs de migration
```bash
python manage.py makemigrations
python manage.py migrate
```

## 🚀 Commandes Utiles

### Backend
```bash
# Créer migrations
python manage.py makemigrations

# Appliquer migrations
python manage.py migrate

# Créer superutilisateur
python manage.py createsuperuser

# Shell Django
python manage.py shell

# Collecter fichiers statiques
python manage.py collectstatic
```

### Frontend
```bash
# Développement
npm run dev

# Build production
npm run build

# Démarrer production
npm start

# Linter
npm run lint
```

## 📖 Prochaines Étapes

1. ✅ Configuration complète
2. ✅ Base de données créée
3. ✅ Migrations appliquées
4. ⏭️ Créer un superutilisateur
5. ⏭️ Tester l'API via Swagger
6. ⏭️ Développer les fonctionnalités

## 🆘 Support

Pour toute question, consultez:
- [Documentation Architecture](./ARCHITECTURE.txt)
- [Description du Projet](./description.txt)
- [Guide d'Implémentation](./decriptionAjout.txt)

