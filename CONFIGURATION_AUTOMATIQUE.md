# 🔄 Configuration Automatique par Détection d'IP

## ✅ SYSTÈME DE CONFIGURATION AUTOMATIQUE ACTIVÉ

Le projet détecte maintenant **automatiquement** votre adresse IP locale et configure tous les paramètres nécessaires.

## 🚀 DÉMARRAGE RAPIDE

### Option 1 : Démarrage Complet Automatique (Recommandé)

```bash
start-all.bat
```

Ce script :
1. ✅ Détecte automatiquement votre IP locale
2. ✅ Configure le backend (CORS, .env)
3. ✅ Configure le frontend (.env.local, next.config.js)
4. ✅ Démarre le backend dans une fenêtre séparée
5. ✅ Démarre le frontend dans une fenêtre séparée

### Option 2 : Démarrage Manuel

#### Backend
```bash
cd backend
start-auto.bat
```

Ou manuellement :
```bash
cd backend
python auto_config.py
python manage.py runserver 0.0.0.0:8000
```

#### Frontend
```bash
cd frontend
npm run dev:mobile
```

Ou manuellement :
```bash
cd frontend
node auto-config.js
npm run dev:auto
```

## 🔧 COMMENT ÇA FONCTIONNE

### 1. Détection Automatique de l'IP

Le système détecte automatiquement votre IP locale en :
- Se connectant à un serveur externe (8.8.8.8)
- Récupérant l'adresse IP de l'interface réseau active
- Gérant les cas d'erreur (fallback sur 127.0.0.1)

### 2. Configuration Backend

**Script** : `backend/auto_config.py`

**Actions** :
- ✅ Détecte l'IP locale
- ✅ Met à jour `.env` avec `LOCAL_IP` et `CORS_ALLOWED_ORIGINS`
- ✅ Crée `config.json` avec toutes les URLs
- ✅ Configure CORS pour accepter l'IP détectée

**Fichiers modifiés** :
- `backend/.env` → Ajoute `LOCAL_IP` et `CORS_ALLOWED_ORIGINS`
- `backend/config.json` → Sauvegarde la configuration

### 3. Configuration Frontend

**Script** : `frontend/auto-config.js`

**Actions** :
- ✅ Détecte l'IP locale (ou charge depuis `backend/config.json`)
- ✅ Met à jour `.env.local` avec `NEXT_PUBLIC_API_URL`
- ✅ Crée `config.json` avec toutes les URLs
- ✅ Configure `next.config.js` dynamiquement

**Fichiers modifiés** :
- `frontend/.env.local` → Ajoute `NEXT_PUBLIC_API_URL`
- `frontend/config.json` → Sauvegarde la configuration

### 4. Intégration Django

**Fichier** : `backend/campuslink/settings.py`

Le backend charge automatiquement l'IP depuis `config.json` :
```python
# Auto-detect local IP for CORS
try:
    import json
    config_path = BASE_DIR / 'config.json'
    if config_path.exists():
        with open(config_path, 'r') as f:
            config = json.load(f)
            local_ip = config.get('local_ip', '127.0.0.1')
            CORS_ALLOWED_ORIGINS = [
                'http://localhost:3000',
                'http://127.0.0.1:3000',
                f'http://{local_ip}:3000'
            ]
except Exception:
    pass
```

### 5. Intégration Next.js

**Fichier** : `frontend/next.config.js`

Next.js charge automatiquement l'API URL depuis la configuration :
```javascript
// Auto-detect IP and configure API URL
let apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api';

try {
  const autoConfig = require('./auto-config.js');
  if (autoConfig && autoConfig.apiUrl) {
    apiUrl = autoConfig.apiUrl;
  }
} catch (e) {
  console.log('Using default API URL:', apiUrl);
}
```

## 📁 FICHIERS CRÉÉS

### Backend
- `backend/auto_config.py` → Script de configuration automatique
- `backend/start-auto.bat` → Script de démarrage avec auto-config
- `backend/config.json` → Configuration sauvegardée

### Frontend
- `frontend/auto-config.js` → Script de configuration automatique
- `frontend/config.json` → Configuration sauvegardée
- `frontend/.env.local` → Variables d'environnement (généré automatiquement)

### Racine
- `start-all.bat` → Script de démarrage complet (backend + frontend)

## 🔄 MISE À JOUR AUTOMATIQUE

Le système se met à jour automatiquement à chaque démarrage :

1. **Backend** : `start-auto.bat` exécute `auto_config.py` avant de démarrer
2. **Frontend** : `npm run dev:mobile` exécute `auto-config.js` avant de démarrer
3. **Complet** : `start-all.bat` configure les deux avant de démarrer

## 📱 UTILISATION

### Scénario 1 : Première Utilisation
```bash
# Exécuter une fois pour configurer
cd backend
python auto_config.py

cd ../frontend
node auto-config.js

# Puis démarrer normalement
```

### Scénario 2 : Utilisation Quotidienne
```bash
# Tout est automatique !
start-all.bat
```

### Scénario 3 : Changement de Réseau
Si vous changez de réseau WiFi :
1. Exécutez `python auto_config.py` dans le backend
2. Exécutez `node auto-config.js` dans le frontend
3. Ou simplement utilisez `start-all.bat` qui fait tout automatiquement

## ✅ AVANTAGES

1. **Aucune configuration manuelle** nécessaire
2. **Détection automatique** de l'IP à chaque démarrage
3. **Synchronisation** entre backend et frontend
4. **Compatible mobile** : configuration automatique pour tests sur téléphone
5. **Fallback intelligent** : utilise localhost si détection échoue

## 🔍 VÉRIFICATION

Pour vérifier la configuration actuelle :

```bash
# Backend
cd backend
python auto_config.py
cat config.json

# Frontend
cd frontend
node auto-config.js
cat config.json
```

## 🛠️ DÉPANNAGE

### L'IP détectée est incorrecte
1. Vérifiez votre connexion réseau
2. Exécutez manuellement : `python backend/auto_config.py`
3. Vérifiez `backend/config.json`

### Le frontend ne se connecte pas au backend
1. Vérifiez que `frontend/.env.local` contient la bonne URL
2. Vérifiez que `frontend/config.json` existe
3. Redémarrez le serveur frontend

### CORS errors
1. Vérifiez que `backend/config.json` contient la bonne IP
2. Vérifiez que `CORS_ALLOW_ALL_ORIGINS = True` en développement
3. Redémarrez le serveur backend

## 📝 EXEMPLE DE CONFIGURATION

**IP détectée** : `192.168.1.118`

**Backend** (`backend/config.json`):
```json
{
  "local_ip": "192.168.1.118",
  "backend_url": "http://192.168.1.118:8000",
  "frontend_url": "http://192.168.1.118:3000",
  "api_url": "http://192.168.1.118:8000/api"
}
```

**Frontend** (`frontend/.env.local`):
```env
NEXT_PUBLIC_API_URL=http://192.168.1.118:8000/api
```

**URLs d'accès** :
- Frontend : `http://192.168.1.118:3000`
- Backend API : `http://192.168.1.118:8000/api`
- Admin Django : `http://192.168.1.118:8000/admin`

## 🎯 RÉSUMÉ

✅ **Configuration automatique** activée
✅ **Détection IP** automatique
✅ **Synchronisation** backend/frontend
✅ **Scripts de démarrage** créés
✅ **Documentation** complète

**Vous n'avez plus besoin de configurer manuellement l'IP !** 🚀

