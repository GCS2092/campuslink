# 🔧 Résolution du Problème de Contenu Mixte (Mixed Content)

## ❌ Problème

Erreur dans la console du navigateur :
```
Blocage du chargement du contenu mixte actif (mixed active content) 
« http://campuslink-krnabdjuy-gcs2092s-projects.vercel.app:8000/api/auth/login/ »
```

## 🔍 Cause

Cette erreur se produit quand :
- Votre site Vercel est en **HTTPS** (tous les sites Vercel le sont)
- Mais l'application essaie de charger des ressources en **HTTP**
- Les navigateurs modernes bloquent le contenu mixte (HTTPS → HTTP) pour des raisons de sécurité

## ✅ Solution

### Étape 1 : Configurer la variable d'environnement dans Vercel

1. Allez sur votre projet Vercel : https://vercel.com/dashboard
2. Cliquez sur votre projet `campuslink`
3. Allez dans **Settings** → **Environment Variables**
4. Ajoutez ou modifiez la variable suivante :

   **Variable :** `NEXT_PUBLIC_API_URL`
   
   **Valeur :** `https://campuslink-9knz.onrender.com/api`
   
   ⚠️ **IMPORTANT :** Utilisez **HTTPS** (pas HTTP) et l'URL de votre backend Render

5. Sélectionnez les environnements : **Production**, **Preview**, **Development**
6. Cliquez sur **Save**

### Étape 2 : Redéployer l'application

Après avoir ajouté/modifié la variable d'environnement :

1. Allez dans l'onglet **Deployments**
2. Cliquez sur les **3 points** (⋯) du dernier déploiement
3. Sélectionnez **Redeploy**
4. Ou faites un commit vide pour déclencher un nouveau déploiement :
   ```bash
   git commit --allow-empty -m "fix: Redéploiement pour appliquer NEXT_PUBLIC_API_URL"
   git push origin main
   ```

### Étape 3 : Vérifier la configuration

1. Ouvrez votre site Vercel : `https://campuslink-*.vercel.app`
2. Ouvrez la console du navigateur (F12)
3. Vérifiez qu'il n'y a plus d'erreur de contenu mixte
4. Vérifiez que les appels API fonctionnent

## 📋 Variables d'environnement requises dans Vercel

| Variable | Valeur | Description |
|----------|--------|-------------|
| `NEXT_PUBLIC_API_URL` | `https://campuslink-9knz.onrender.com/api` | URL de votre backend Render (en HTTPS) |
| `NEXT_PUBLIC_FIREBASE_API_KEY` | (votre clé Firebase) | Clé API Firebase |
| `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN` | (votre domaine Firebase) | Domaine d'authentification Firebase |
| `NEXT_PUBLIC_FIREBASE_PROJECT_ID` | (votre ID projet) | ID du projet Firebase |
| `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET` | (votre bucket) | Bucket de stockage Firebase |
| `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID` | (votre sender ID) | ID de l'expéditeur FCM |
| `NEXT_PUBLIC_FIREBASE_APP_ID` | (votre app ID) | ID de l'application Firebase |
| `NEXT_PUBLIC_FIREBASE_VAPID_KEY` | (votre clé VAPID) | Clé VAPID pour les notifications push |

## 🔍 Vérification

### Dans la console du navigateur, vous devriez voir :

✅ **Correct :**
```
✅ NEXT_PUBLIC_API_URL already set: https://campuslink-9knz.onrender.com/api
```

❌ **Incorrect (si vous voyez ceci, la variable n'est pas configurée) :**
```
⚠️ Mixed content warning: API URL is HTTP but page is HTTPS...
```

### Test de l'API

Ouvrez la console du navigateur et testez :
```javascript
console.log('API URL:', process.env.NEXT_PUBLIC_API_URL)
```

Vous devriez voir : `https://campuslink-9knz.onrender.com/api`

## 🐛 Dépannage

### Si l'erreur persiste après avoir configuré la variable :

1. **Vérifiez que la variable est bien définie :**
   - Allez dans Vercel → Settings → Environment Variables
   - Vérifiez que `NEXT_PUBLIC_API_URL` est présent
   - Vérifiez que la valeur commence par `https://` (pas `http://`)

2. **Vérifiez que vous avez redéployé :**
   - Les variables d'environnement ne sont appliquées qu'après un nouveau déploiement
   - Faites un redeploy ou un commit vide

3. **Vérifiez l'URL du backend :**
   - Testez l'URL dans votre navigateur : `https://campuslink-9knz.onrender.com/api/`
   - Elle doit être accessible en HTTPS

4. **Videz le cache du navigateur :**
   - Appuyez sur `Ctrl+Shift+R` (Windows) ou `Cmd+Shift+R` (Mac)
   - Ou ouvrez en navigation privée

## 📝 Notes

- Les variables `NEXT_PUBLIC_*` sont accessibles côté client (navigateur)
- Elles doivent être configurées dans Vercel pour la production
- Pour le développement local, utilisez `.env.local` dans le dossier `frontend/`
- Le code a été mis à jour pour détecter et prévenir ce problème à l'avenir

