# 🚀 Guide d'Hébergement - CampusLink

## 🎯 Recommandations pour Tester la Plateforme

### ⭐ **Option 1 : Railway (Recommandé pour débuter)**

**Pourquoi Railway ?**
- ✅ **Gratuit** pour commencer (500h/mois gratuits)
- ✅ **Très simple** à configurer
- ✅ **PostgreSQL inclus** (gratuit jusqu'à 5GB)
- ✅ **Déploiement automatique** depuis GitHub
- ✅ **Backend + Base de données** sur la même plateforme
- ✅ **Frontend** peut aussi être déployé

**Coût :** Gratuit pour tester, puis ~$5-10/mois pour un usage modéré

**Limites gratuites :**
- 500 heures de runtime/mois
- 5GB de stockage PostgreSQL
- 100GB de bande passante/mois

---

### ⭐ **Option 2 : Render (Alternative gratuite)**

**Pourquoi Render ?**
- ✅ **Gratuit** pour commencer
- ✅ **PostgreSQL gratuit** (90 jours, puis $7/mois)
- ✅ **Déploiement automatique** depuis GitHub
- ✅ **Backend + Frontend** sur la même plateforme

**Coût :** Gratuit 90 jours, puis ~$7-15/mois

**Limites gratuites :**
- Services "spinnent" après 15 min d'inactivité
- PostgreSQL gratuit 90 jours

---

### ⭐ **Option 3 : Vercel (Frontend) + Railway (Backend)**

**Pourquoi cette combinaison ?**
- ✅ **Vercel** = **GRATUIT** et optimisé pour Next.js
- ✅ **Railway** = Backend + PostgreSQL
- ✅ **Performance optimale** pour Next.js
- ✅ **CDN global** pour le frontend

**Coût :** Gratuit pour tester

---

## 📋 Plan d'Action Recommandé : Railway (Tout-en-un)

### Étape 1 : Préparer le Projet

#### 1.1 Créer un fichier `Procfile` pour Railway

Créez `backend/Procfile` :
```
web: python manage.py migrate && python manage.py collectstatic --noinput && gunicorn campuslink.wsgi:application --bind 0.0.0.0:$PORT
```

#### 1.2 Créer `railway.json` à la racine

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "cd backend && python manage.py migrate && gunicorn campuslink.wsgi:application --bind 0.0.0.0:$PORT",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

#### 1.3 Créer `runtime.txt` dans `backend/`

```
python-3.11.0
```

#### 1.4 Mettre à jour `requirements.txt`

Ajoutez `gunicorn` et `whitenoise` :
```txt
gunicorn==21.2.0
whitenoise==6.6.0
psycopg2-binary==2.9.9
```

#### 1.5 Créer `.railwayignore` (optionnel)

```
venv/
__pycache__/
*.pyc
.env
*.log
node_modules/
.next/
```

---

### Étape 2 : Configurer Railway

#### 2.1 Créer un compte Railway

1. Allez sur [railway.app](https://railway.app)
2. Cliquez sur "Login with GitHub"
3. Autorisez Railway à accéder à votre GitHub

#### 2.2 Créer un nouveau projet

1. Cliquez sur "New Project"
2. Sélectionnez "Deploy from GitHub repo"
3. Choisissez votre repository CampusLink
4. Railway détectera automatiquement le projet

#### 2.3 Ajouter PostgreSQL

1. Dans votre projet Railway, cliquez sur "+ New"
2. Sélectionnez "Database" → "PostgreSQL"
3. Railway créera automatiquement une base PostgreSQL
4. **Notez les variables de connexion** (elles seront ajoutées automatiquement)

#### 2.4 Configurer les Variables d'Environnement

Dans Railway, allez dans votre service backend → "Variables" et ajoutez :

```env
# Django Settings
DJANGO_SECRET_KEY=votre_secret_key_généré
DEBUG=False
ALLOWED_HOSTS=votre-app.railway.app,*.railway.app

# Database (Railway l'ajoute automatiquement)
DATABASE_URL=${{Postgres.DATABASE_URL}}

# CORS (ajoutez votre domaine Railway)
CORS_ALLOWED_ORIGINS=https://votre-app.railway.app,https://votre-frontend.vercel.app

# Cloudinary (si vous l'utilisez)
CLOUDINARY_CLOUD_NAME=votre_cloud_name
CLOUDINARY_API_KEY=votre_api_key
CLOUDINARY_API_SECRET=votre_api_secret

# Redis (si vous l'utilisez)
REDIS_URL=${{Redis.REDIS_URL}}

# Autres variables
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=votre_email@gmail.com
EMAIL_HOST_PASSWORD=votre_app_password
```

#### 2.5 Générer SECRET_KEY

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

---

### Étape 3 : Configurer Django pour la Production

#### 3.1 Mettre à jour `settings.py`

Ajoutez à la fin de `backend/campuslink/settings.py` :

```python
# Railway Configuration
import dj_database_url

# Database
if 'DATABASE_URL' in os.environ:
    DATABASES['default'] = dj_database_url.config(
        conn_max_age=600,
        conn_health_checks=True,
    )

# Static files (WhiteNoise)
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Media files (utilisez Cloudinary en production)
if not DEBUG:
    DEFAULT_FILE_STORAGE = 'cloudinary_storage.storage.MediaCloudinaryStorage'

# Security
if not DEBUG:
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_BROWSER_XSS_FILTER = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    X_FRAME_OPTIONS = 'DENY'
```

#### 3.2 Installer les dépendances nécessaires

Ajoutez à `requirements.txt` :
```txt
dj-database-url==2.1.0
gunicorn==21.2.0
whitenoise==6.6.0
```

---

### Étape 4 : Déployer le Frontend (Optionnel sur Railway)

#### Option A : Déployer sur Vercel (Recommandé pour Next.js)

1. Allez sur [vercel.com](https://vercel.com)
2. Connectez votre GitHub
3. Importez votre repository
4. Vercel détectera automatiquement Next.js
5. Configurez les variables d'environnement :

```env
NEXT_PUBLIC_API_URL=https://votre-backend.railway.app/api
```

#### Option B : Déployer sur Railway

1. Dans Railway, ajoutez un nouveau service
2. Sélectionnez votre repo
3. Railway détectera Next.js
4. Configurez les variables d'environnement

---

## 🔧 Configuration Alternative : Render

### Étape 1 : Préparer pour Render

#### 1.1 Créer `render.yaml` à la racine

```yaml
services:
  - type: web
    name: campuslink-backend
    env: python
    buildCommand: cd backend && pip install -r requirements.txt
    startCommand: cd backend && python manage.py migrate && gunicorn campuslink.wsgi:application --bind 0.0.0.0:$PORT
    envVars:
      - key: DJANGO_SECRET_KEY
        generateValue: true
      - key: DEBUG
        value: False
      - key: DATABASE_URL
        fromDatabase:
          name: campuslink-db
          property: connectionString
      - key: ALLOWED_HOSTS
        value: campuslink-backend.onrender.com
      - key: CORS_ALLOWED_ORIGINS
        value: https://campuslink-frontend.onrender.com

databases:
  - name: campuslink-db
    plan: free
```

#### 1.2 Créer un compte Render

1. Allez sur [render.com](https://render.com)
2. Créez un compte
3. Connectez votre GitHub

#### 1.3 Créer la base de données

1. "New" → "PostgreSQL"
2. Choisissez "Free" (90 jours gratuits)
3. Notez la connection string

#### 1.4 Créer le service Web

1. "New" → "Web Service"
2. Connectez votre repo
3. Configurez :
   - **Build Command:** `cd backend && pip install -r requirements.txt`
   - **Start Command:** `cd backend && python manage.py migrate && gunicorn campuslink.wsgi:application --bind 0.0.0.0:$PORT`
   - **Environment:** Python 3

---

## 🎯 Comparaison Rapide

| Plateforme | Gratuit | Facilité | PostgreSQL | Déploiement Auto |
|------------|---------|----------|------------|------------------|
| **Railway** | ✅ 500h/mois | ⭐⭐⭐⭐⭐ | ✅ Inclus | ✅ Oui |
| **Render** | ✅ 90 jours | ⭐⭐⭐⭐ | ✅ 90 jours | ✅ Oui |
| **Vercel** | ✅ Illimité | ⭐⭐⭐⭐⭐ | ❌ Non | ✅ Oui |
| **Fly.io** | ✅ 3 VMs | ⭐⭐⭐ | ❌ Non | ✅ Oui |
| **Heroku** | ❌ Payant | ⭐⭐⭐⭐ | ✅ Payant | ✅ Oui |

---

## 📝 Checklist de Déploiement

### Avant de déployer

- [ ] `DEBUG = False` en production
- [ ] `SECRET_KEY` généré et sécurisé
- [ ] `ALLOWED_HOSTS` configuré
- [ ] `CORS_ALLOWED_ORIGINS` configuré
- [ ] Base de données PostgreSQL configurée
- [ ] Variables d'environnement définies
- [ ] `requirements.txt` à jour
- [ ] `gunicorn` et `whitenoise` ajoutés
- [ ] Migrations prêtes
- [ ] Static files configurés (WhiteNoise ou Cloudinary)

### Après le déploiement

- [ ] Tester l'API backend
- [ ] Tester le frontend
- [ ] Vérifier les migrations
- [ ] Créer un superutilisateur
- [ ] Tester l'inscription
- [ ] Tester la connexion
- [ ] Vérifier les fichiers statiques
- [ ] Vérifier les uploads d'images

---

## 🚀 Commandes Utiles

### Créer un superutilisateur sur Railway

```bash
# Via Railway CLI
railway run python backend/manage.py createsuperuser

# Ou via le dashboard Railway → Shell
```

### Appliquer les migrations

```bash
railway run python backend/manage.py migrate
```

### Collecter les fichiers statiques

```bash
railway run python backend/manage.py collectstatic --noinput
```

---

## 💡 Conseils pour Tester

1. **Commencez avec Railway** - C'est le plus simple
2. **Utilisez le plan gratuit** - Assez pour tester
3. **Déployez d'abord le backend** - Testez l'API
4. **Puis déployez le frontend** - Sur Vercel (gratuit)
5. **Testez toutes les fonctionnalités** - Inscription, connexion, etc.
6. **Surveillez les logs** - Railway et Vercel ont de bons logs

---

## 🔗 Liens Utiles

- [Railway Documentation](https://docs.railway.app)
- [Render Documentation](https://render.com/docs)
- [Vercel Documentation](https://vercel.com/docs)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/stable/howto/deployment/checklist/)

---

## ⚠️ Notes Importantes

1. **Ne commitez jamais** vos `.env` ou `SECRET_KEY`
2. **Utilisez des variables d'environnement** pour tous les secrets
3. **Activez HTTPS** en production (automatique sur Railway/Render)
4. **Configurez CORS** correctement
5. **Surveillez les logs** pour détecter les erreurs
6. **Faites des backups** réguliers de la base de données

---

**Dernière mise à jour :** 2024

