# 📱 INSTRUCTIONS POUR TESTER SUR TÉLÉPHONE

## ✅ Configuration CORS Complète - TERMINÉE

Toutes les autorisations CORS ont été activées pour le développement mobile.

## 🚀 DÉMARRAGE RAPIDE

### 1. Obtenir votre IP locale
```bash
cd backend
python get_local_ip.py
```

**Votre IP locale est : `192.168.1.118`** (peut varier selon votre réseau)

### 2. Démarrer le Backend
```bash
cd backend
start-mobile.bat
```

Ou manuellement :
```bash
cd backend
.\venv\Scripts\Activate.ps1
python manage.py runserver 0.0.0.0:8000
```

### 3. Démarrer le Frontend
```bash
cd frontend
npm run dev:mobile
```

Ou manuellement :
```bash
cd frontend
next dev -H 0.0.0.0 -p 3000
```

### 4. Configurer les variables d'environnement

**Frontend** - Créer `.env.local` :
```env
NEXT_PUBLIC_API_URL=http://192.168.1.118:8000/api
```

⚠️ **Remplacez `192.168.1.118` par votre IP locale** (obtenue avec `python get_local_ip.py`)

## 📱 ACCÈS DEPUIS LE TÉLÉPHONE

1. **Assurez-vous que votre téléphone est sur le même réseau WiFi**

2. **Ouvrez le navigateur sur votre téléphone**

3. **Accédez à** :
   ```
   http://192.168.1.118:3000
   ```
   (Remplacez par votre IP locale)

## ✅ CE QUI A ÉTÉ CONFIGURÉ

### Backend (Django)
- ✅ `CORS_ALLOW_ALL_ORIGINS = True` en développement
- ✅ `ALLOWED_HOSTS = ['*']` en développement
- ✅ Headers CORS complets (Authorization, Content-Type, etc.)
- ✅ Méthodes HTTP autorisées (GET, POST, PUT, DELETE, OPTIONS)
- ✅ Cookies sécurisés désactivés en développement

### Frontend (Next.js)
- ✅ Headers CORS ajoutés
- ✅ Serveur accessible sur `0.0.0.0` (réseau local)
- ✅ Script `dev:mobile` pour démarrage automatique

## 🔒 SÉCURITÉ

⚠️ **IMPORTANT** : Cette configuration est **UNIQUEMENT pour le développement** !

En production :
- Ne jamais utiliser `ALLOWED_HOSTS = ['*']`
- Ne jamais utiliser `CORS_ALLOW_ALL_ORIGINS = True`
- Utiliser des origines spécifiques
- Utiliser HTTPS

## 🛠️ DÉPANNAGE

### Le téléphone ne peut pas accéder
1. ✅ Vérifiez que le téléphone est sur le même réseau WiFi
2. ✅ Vérifiez le pare-feu Windows (autoriser ports 3000 et 8000)
3. ✅ Vérifiez que les serveurs sont lancés sur `0.0.0.0` et non `localhost`

### Erreurs CORS
1. ✅ Vérifiez que `DEBUG=True` dans le backend
2. ✅ Vérifiez que `CORS_ALLOW_ALL_ORIGINS = True` est activé
3. ✅ Vérifiez que le middleware `corsheaders` est bien en premier

### Erreurs de connexion API
1. ✅ Vérifiez `NEXT_PUBLIC_API_URL` dans `.env.local`
2. ✅ Utilisez l'IP locale, pas `localhost`
3. ✅ Vérifiez que le backend est accessible depuis le téléphone

## 📝 EXEMPLE COMPLET

Si votre IP locale est `192.168.1.118` :

**Frontend** (`.env.local`):
```env
NEXT_PUBLIC_API_URL=http://192.168.1.118:8000/api
```

**URLs d'accès** :
- Frontend : `http://192.168.1.118:3000`
- Backend API : `http://192.168.1.118:8000/api`
- Admin Django : `http://192.168.1.118:8000/admin`

## 🎯 RÉSUMÉ

1. ✅ CORS activé pour toutes les origines en développement
2. ✅ Backend accessible sur `0.0.0.0:8000`
3. ✅ Frontend accessible sur `0.0.0.0:3000`
4. ✅ Scripts de démarrage créés
5. ✅ Documentation complète fournie

**Vous pouvez maintenant tester sur votre téléphone !** 📱

