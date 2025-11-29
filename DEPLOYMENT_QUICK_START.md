# 🚀 Guide de Déploiement Rapide - CampusLink

## Architecture de Déploiement

```
Frontend (Next.js)  →  Vercel (Gratuit)
Backend (Django)    →  Railway (Gratuit)
Base de données     →  Railway PostgreSQL (Gratuit)
```

## ⚡ Déploiement Rapide (15 minutes)

### Partie 1 : Backend sur Railway (5 min)

1. **Créer un compte Railway**
   - Allez sur https://railway.app
   - Connectez-vous avec GitHub

2. **Créer un nouveau projet**
   - Cliquez sur "New Project"
   - "Deploy from GitHub repo"
   - Sélectionnez votre repo `campusLink`

3. **Ajouter PostgreSQL**
   - Dans le projet, cliquez sur "+ New"
   - "Database" → "PostgreSQL"
   - Railway créera automatiquement `DATABASE_URL`

4. **Configurer le service Django**
   - Cliquez sur "+ New" → "GitHub Repo"
   - Sélectionnez votre repo
   - Railway détectera Django automatiquement

5. **Variables d'environnement** (Railway → Variables)
   ```bash
   SECRET_KEY=<générez-une-clé-aléatoire>
   DEBUG=False
   ALLOWED_HOSTS=*.railway.app
   CORS_ALLOWED_ORIGINS=https://your-app.vercel.app
   ```

6. **Build & Start Commands** (Railway → Settings)
   - Build: `pip install -r requirements.txt`
   - Start: `python manage.py migrate && python manage.py collectstatic --noinput && gunicorn campuslink.wsgi:application --bind 0.0.0.0:$PORT`

7. **Créer un superuser**
   - Railway → Service → Terminal
   - `python manage.py createsuperuser`

8. **Obtenir l'URL du backend**
   - Railway → Service → Settings → "Generate Domain"
   - Copiez l'URL (ex: `https://campuslink-production.up.railway.app`)

### Partie 2 : Frontend sur Vercel (5 min)

1. **Créer un compte Vercel**
   - Allez sur https://vercel.com
   - Connectez-vous avec GitHub

2. **Importer le projet**
   - "Add New Project"
   - Importez votre repo GitHub
   - **Root Directory** : `frontend`
   - Framework : Next.js (détecté automatiquement)

3. **Variables d'environnement** (Vercel → Settings → Environment Variables)
   ```bash
   NEXT_PUBLIC_API_URL=https://your-backend.railway.app/api
   ```
   Remplacez `your-backend.railway.app` par l'URL de votre backend Railway

4. **Déployer**
   - Cliquez sur "Deploy"
   - Attendez 2-3 minutes
   - Votre site sera sur `https://your-app.vercel.app`

### Partie 3 : Configuration CORS (2 min)

Dans votre backend Railway, ajoutez dans les variables d'environnement :

```bash
CORS_ALLOWED_ORIGINS=https://your-app.vercel.app,https://your-app-git-main.vercel.app
```

Redéployez le backend.

### Partie 4 : Test (3 min)

1. Ouvrez votre site Vercel : `https://your-app.vercel.app`
2. Testez la connexion :
   - Créez un compte
   - Connectez-vous
   - Vérifiez que les données se chargent

## 📋 Checklist Complète

### Backend (Railway)
- [ ] Projet créé
- [ ] PostgreSQL ajouté
- [ ] Service Django configuré
- [ ] Variables d'environnement ajoutées
- [ ] Build/Start commands configurés
- [ ] Migrations appliquées
- [ ] Superuser créé
- [ ] URL backend obtenue
- [ ] API testée (`https://your-backend.railway.app/api/events/`)

### Frontend (Vercel)
- [ ] Projet créé
- [ ] Root directory = `frontend`
- [ ] Variable `NEXT_PUBLIC_API_URL` configurée
- [ ] Build réussi
- [ ] Site accessible
- [ ] API calls fonctionnent

### Configuration
- [ ] CORS configuré dans backend
- [ ] Backend redéployé après CORS
- [ ] Site testé et fonctionnel

## 🔧 Commandes Utiles

### Backend (Railway Terminal)
```bash
# Créer superuser
python manage.py createsuperuser

# Appliquer migrations
python manage.py migrate

# Collecter fichiers statiques
python manage.py collectstatic --noinput

# Vérifier la configuration
python manage.py check
```

### Frontend (Local - pour tester)
```bash
cd frontend
npm install
npm run build  # Teste le build avant déploiement
```

## 🐛 Problèmes Courants

### "API URL not found"
- Vérifiez `NEXT_PUBLIC_API_URL` dans Vercel
- Redéployez après modification

### Erreur CORS
- Vérifiez `CORS_ALLOWED_ORIGINS` dans Railway
- Ajoutez toutes les URLs Vercel (production + previews)
- Redéployez le backend

### Build échoue sur Vercel
- Vérifiez que `Root Directory` = `frontend`
- Vérifiez les logs dans Vercel Dashboard
- Testez `npm run build` localement

### Backend ne démarre pas
- Vérifiez les logs dans Railway
- Vérifiez que `gunicorn` est dans `requirements.txt`
- Vérifiez que le Start Command est correct

## 📚 Documentation Complète

- **Frontend** : Voir `frontend/VERCEL_DEPLOYMENT.md`
- **Backend** : Voir `backend/RAILWAY_DEPLOYMENT.md`

## 🎉 C'est Fait !

Votre application est maintenant en ligne :
- **Frontend** : `https://your-app.vercel.app`
- **Backend** : `https://your-backend.railway.app/api`

