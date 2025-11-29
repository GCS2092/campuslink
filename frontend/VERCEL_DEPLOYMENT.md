# Guide de Déploiement sur Vercel

## 📋 Prérequis

1. Compte Vercel (gratuit) : https://vercel.com
2. Backend Django déployé (Railway, Render, Heroku, etc.)
3. Base de données PostgreSQL (Railway, Supabase, etc.)
4. Compte GitHub (pour connecter le repo)

## 🚀 Étape 1 : Préparer le Backend

### Option A : Railway (Recommandé - Gratuit)

1. Allez sur https://railway.app
2. Créez un nouveau projet
3. Ajoutez PostgreSQL
4. Ajoutez un service "Empty Service"
5. Connectez votre repo GitHub
6. Configurez les variables d'environnement :
   ```
   DATABASE_URL=<from-postgres-service>
   SECRET_KEY=<your-secret-key>
   DEBUG=False
   ALLOWED_HOSTS=your-app.railway.app
   CORS_ALLOWED_ORIGINS=https://your-frontend.vercel.app
   ```

### Option B : Render

1. Allez sur https://render.com
2. Créez un "Web Service"
3. Connectez votre repo
4. Configurez les variables d'environnement

## 🎨 Étape 2 : Déployer le Frontend sur Vercel

### Méthode 1 : Via l'interface Vercel (Recommandé)

1. **Connectez votre repo GitHub**
   - Allez sur https://vercel.com
   - Cliquez sur "Add New Project"
   - Importez votre repo GitHub
   - Sélectionnez le dossier `frontend`

2. **Configurez le projet**
   - Framework Preset : Next.js (détecté automatiquement)
   - Root Directory : `frontend`
   - Build Command : `npm run build`
   - Output Directory : `.next`

3. **Variables d'environnement**
   - Allez dans Settings → Environment Variables
   - Ajoutez :
     ```
     NEXT_PUBLIC_API_URL=https://your-backend-url.com/api
     ```
   - Remplacez `your-backend-url.com` par l'URL de votre backend déployé

4. **Déployez**
   - Cliquez sur "Deploy"
   - Attendez la fin du build
   - Votre site sera disponible sur `https://your-app.vercel.app`

### Méthode 2 : Via CLI Vercel

```bash
# Installer Vercel CLI
npm i -g vercel

# Dans le dossier frontend
cd frontend

# Se connecter à Vercel
vercel login

# Déployer
vercel

# Pour la production
vercel --prod
```

## ⚙️ Configuration des Variables d'Environnement

Dans Vercel Dashboard → Settings → Environment Variables :

| Variable | Valeur | Description |
|----------|--------|-------------|
| `NEXT_PUBLIC_API_URL` | `https://your-backend.railway.app/api` | URL de votre backend Django |
| `NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME` | (optionnel) | Si vous utilisez Cloudinary |

## 🔧 Configuration CORS du Backend

Dans votre backend Django (`settings.py`), ajoutez :

```python
CORS_ALLOWED_ORIGINS = [
    "https://your-app.vercel.app",
    "https://your-app-git-main.vercel.app",  # Preview deployments
]

# Ou pour le développement
CORS_ALLOW_ALL_ORIGINS = False  # Ne pas utiliser en production
```

## 📝 Checklist de Déploiement

### Backend
- [ ] Backend déployé et accessible
- [ ] Base de données PostgreSQL configurée
- [ ] Variables d'environnement configurées
- [ ] CORS configuré pour accepter Vercel
- [ ] Migrations appliquées
- [ ] Superuser créé
- [ ] API testée (ex: `https://your-backend.com/api/events/`)

### Frontend
- [ ] Repo GitHub connecté à Vercel
- [ ] Variables d'environnement configurées dans Vercel
- [ ] Build réussi sur Vercel
- [ ] Site accessible sur `https://your-app.vercel.app`
- [ ] API calls fonctionnent (vérifier la console du navigateur)

## 🐛 Dépannage

### Erreur : "API URL not found"
- Vérifiez que `NEXT_PUBLIC_API_URL` est bien configuré dans Vercel
- Redéployez après avoir ajouté la variable

### Erreur CORS
- Vérifiez que votre backend accepte les requêtes depuis Vercel
- Ajoutez l'URL Vercel dans `CORS_ALLOWED_ORIGINS`

### Build échoue
- Vérifiez les logs dans Vercel Dashboard
- Assurez-vous que toutes les dépendances sont dans `package.json`
- Vérifiez que `npm run build` fonctionne localement

### Images ne s'affichent pas
- Vérifiez la configuration `images` dans `next.config.js`
- Ajoutez les domaines dans `remotePatterns`

## 🔄 Déploiements Automatiques

Vercel déploie automatiquement :
- **Production** : À chaque push sur `main` ou `master`
- **Preview** : À chaque pull request

## 📚 Ressources

- [Documentation Vercel](https://vercel.com/docs)
- [Next.js sur Vercel](https://vercel.com/docs/frameworks/nextjs)
- [Variables d'environnement Vercel](https://vercel.com/docs/environment-variables)

