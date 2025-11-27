# 📱 Configuration pour Test sur Téléphone

## ✅ Configuration CORS Complète

### Backend (Django)
- ✅ **CORS activé pour toutes les origines en développement**
- ✅ **ALLOWED_HOSTS = ['*'] en développement**
- ✅ **Headers CORS complets** (Authorization, Content-Type, etc.)
- ✅ **Méthodes HTTP autorisées** (GET, POST, PUT, DELETE, OPTIONS)

### Frontend (Next.js)
- ✅ **Headers CORS ajoutés**
- ✅ **Serveur accessible depuis le réseau local**

## 🚀 Démarrage pour Mobile

### Option 1 : Scripts Automatiques (Recommandé)

#### Backend
```bash
cd backend
start-mobile.bat
```

#### Frontend
```bash
cd frontend
npm run dev:mobile
```

### Option 2 : Commandes Manuelles

#### 1. Obtenir votre IP locale
```bash
# Windows
ipconfig
# Cherchez "Adresse IPv4" sous votre connexion WiFi

# Ou utilisez le script Python
cd backend
python get_local_ip.py
```

#### 2. Démarrer le Backend
```bash
cd backend
.\venv\Scripts\Activate.ps1
python manage.py runserver 0.0.0.0:8000
```

#### 3. Démarrer le Frontend
```bash
cd frontend
# Option A: Avec le script
npm run dev:mobile

# Option B: Manuellement
next dev -H 0.0.0.0 -p 3000
```

#### 4. Configurer les variables d'environnement

**Backend** (`.env`):
```env
DEBUG=True
ALLOWED_HOSTS=*
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000,http://VOTRE_IP:3000
```

**Frontend** (`.env.local`):
```env
NEXT_PUBLIC_API_URL=http://VOTRE_IP:8000/api
```

Remplacez `VOTRE_IP` par votre adresse IP locale (ex: `192.168.1.100`)

## 📱 Accès depuis le Téléphone

1. **Assurez-vous que votre téléphone est sur le même réseau WiFi**

2. **Ouvrez le navigateur sur votre téléphone**

3. **Accédez à** :
   ```
   http://VOTRE_IP:3000
   ```
   (Remplacez `VOTRE_IP` par votre adresse IP locale)

## 🔒 Sécurité

⚠️ **IMPORTANT** : Cette configuration est **UNIQUEMENT pour le développement** !

En production :
- Ne jamais utiliser `ALLOWED_HOSTS = ['*']`
- Ne jamais utiliser `CORS_ALLOW_ALL_ORIGINS = True`
- Utiliser des origines spécifiques dans `CORS_ALLOWED_ORIGINS`
- Utiliser HTTPS

## 🛠️ Dépannage

### Le téléphone ne peut pas accéder au serveur
1. Vérifiez que le téléphone est sur le même réseau WiFi
2. Vérifiez le pare-feu Windows (autoriser les ports 3000 et 8000)
3. Vérifiez que les serveurs sont lancés sur `0.0.0.0` et non `localhost`

### Erreurs CORS
1. Vérifiez que `DEBUG=True` dans le backend
2. Vérifiez que `CORS_ALLOW_ALL_ORIGINS = True` est activé
3. Vérifiez que le middleware `corsheaders` est bien en premier dans `MIDDLEWARE`

### Erreurs de connexion API
1. Vérifiez `NEXT_PUBLIC_API_URL` dans `.env.local`
2. Utilisez l'IP locale, pas `localhost`
3. Vérifiez que le backend est accessible depuis le téléphone

## 📝 Exemple de Configuration

Si votre IP locale est `192.168.1.100` :

**Backend** (`.env`):
```env
DEBUG=True
ALLOWED_HOSTS=*
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000,http://192.168.1.100:3000
```

**Frontend** (`.env.local`):
```env
NEXT_PUBLIC_API_URL=http://192.168.1.100:8000/api
```

**URLs d'accès** :
- Frontend : `http://192.168.1.100:3000`
- Backend API : `http://192.168.1.100:8000/api`
- Admin Django : `http://192.168.1.100:8000/admin`

