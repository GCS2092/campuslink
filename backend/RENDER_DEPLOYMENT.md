# Guide de Déploiement Backend sur Render

## Configuration Render

### 1. Root Directory
```
backend
```

### 2. Python Version
Render utilisera automatiquement la version spécifiée dans `runtime.txt` (Python 3.12).
Si vous devez spécifier manuellement, utilisez **Python 3.12** dans les paramètres du service.

### 3. Build Command
```bash
pip install -r requirements.txt && python manage.py collectstatic --noinput
```

### 4. Start Command
```bash
python manage.py migrate && daphne -b 0.0.0.0 -p $PORT campuslink.asgi:application
```

## Variables d'Environnement Requises

Ajoutez ces variables dans la section "Environment Variables" de Render :

### Base de données
```
DATABASE_URL=postgresql://user:password@hostname:port/dbname
```
*(Render fournit automatiquement cette variable si vous créez une base de données PostgreSQL)*

### Django
```
SECRET_KEY=votre-secret-key-tres-long-et-aleatoire
DEBUG=False
ALLOWED_HOSTS=votre-app.render.com,*.render.com
```

### CORS
```
CORS_ALLOWED_ORIGINS=https://votre-frontend.vercel.app,https://votre-frontend.vercel.app
```

### Cloudinary (Stockage de fichiers)
```
CLOUDINARY_CLOUD_NAME=votre-cloud-name
CLOUDINARY_API_KEY=votre-api-key
CLOUDINARY_API_SECRET=votre-api-secret
```

### Redis (Cache et WebSockets)
```
REDIS_HOST=votre-redis-host
REDIS_PORT=6379
REDIS_PASSWORD=votre-redis-password
```
*(Créez un service Redis sur Render et utilisez les variables fournies)*

### Twilio (SMS)
```
TWILIO_ACCOUNT_SID=votre-account-sid
TWILIO_AUTH_TOKEN=votre-auth-token
TWILIO_PHONE_NUMBER=votre-numero-twilio
```

### Email (AWS SES)
```
AWS_ACCESS_KEY_ID=votre-access-key
AWS_SECRET_ACCESS_KEY=votre-secret-key
AWS_SES_REGION_NAME=us-east-1
DEFAULT_FROM_EMAIL=noreply@votre-domaine.com
```

### Celery (Optionnel - pour les tâches asynchrones)
```
CELERY_BROKER_URL=redis://votre-redis-host:6379/0
CELERY_RESULT_BACKEND=redis://votre-redis-host:6379/0
```

## Étapes de Déploiement

1. **Créer un nouveau Web Service sur Render**
   - Connectez votre repository GitHub
   - Sélectionnez le branch `main`
   - Choisissez "Python 3" comme environnement
   - **Important**: Assurez-vous que Render utilise Python 3.12 (vérifiez dans les paramètres du service)
   - Le fichier `runtime.txt` dans le dossier `backend` spécifie déjà Python 3.12

2. **Configurer le service**
   - **Root Directory**: `backend`
   - **Build Command**: `pip install -r requirements.txt && python manage.py collectstatic --noinput`
   - **Start Command**: `python manage.py migrate && daphne -b 0.0.0.0 -p $PORT campuslink.asgi:application`

3. **Créer une base de données PostgreSQL**
   - Dans Render Dashboard, créez un nouveau "PostgreSQL" service
   - Notez l'URL de connexion (Render la fournira automatiquement comme `DATABASE_URL`)

4. **Créer un service Redis** (Recommandé)
   - Créez un nouveau "Redis" service
   - Utilisez les variables d'environnement fournies pour `REDIS_HOST`, `REDIS_PORT`, etc.

5. **Ajouter les variables d'environnement**
   - Ajoutez toutes les variables listées ci-dessus dans la section "Environment Variables"

6. **Déployer**
   - Render déploiera automatiquement après chaque push sur `main`
   - Vérifiez les logs pour s'assurer que tout fonctionne

## Notes Importantes

- **WebSockets**: L'utilisation de `daphne` (ASGI) est nécessaire pour supporter les WebSockets (messaging en temps réel)
- **Port**: Render fournit automatiquement le port via la variable `$PORT`
- **Migrations**: Les migrations sont exécutées automatiquement au démarrage
- **Static Files**: Les fichiers statiques sont collectés pendant le build

## Vérification

Une fois déployé, testez :
- L'API REST : `https://votre-app.render.com/api/`
- Les WebSockets : Connectez-vous via le frontend et testez le chat en temps réel

## Troubleshooting

### Erreur de connexion à la base de données
- Vérifiez que `DATABASE_URL` est correctement configuré
- Assurez-vous que la base de données PostgreSQL est créée et accessible

### Erreur Redis
- Si Redis n'est pas disponible, l'application utilisera `InMemoryChannelLayer` en mode DEBUG
- Pour la production, créez un service Redis sur Render

### Erreur de migrations
- Vérifiez les logs de déploiement
- Les migrations sont exécutées automatiquement au démarrage

