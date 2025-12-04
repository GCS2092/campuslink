# Corrections Authentification Cross-Domain

## Problèmes identifiés

1. **401 Unauthorized** sur `/api/auth/profile/` - Token JWT non envoyé ou CORS bloqué
2. **500 Internal Server Error** sur `/api/messaging/messages/` - User anonyme causant crash
3. **WebSocket failed** - Authentification WebSocket non fonctionnelle en cross-domain

## Solutions implémentées

### 1. Configuration CORS (Backend)

**Fichier**: `backend/campuslink/settings.py`

- ✅ Ajout des URLs Vercel dans `CORS_ALLOWED_ORIGINS`
- ✅ Option `CORS_ALLOW_ALL_ORIGINS` pour supporter toutes les preview deployments Vercel
- ✅ `CORS_ALLOW_CREDENTIALS = True` pour permettre l'envoi de credentials

**Configuration Render** (à faire) :
```bash
# Option 1: Autoriser toutes les origines (recommandé pour Vercel preview deployments)
CORS_ALLOW_ALL_ORIGINS=True

# Option 2: Lister spécifiquement les URLs (plus sécurisé)
CORS_ALLOWED_ORIGINS=https://campuslink-sigma.vercel.app,https://campuslink-git-main-gcs2092s-projects.vercel.app
```

### 2. Authentification WebSocket JWT (Backend)

**Fichier**: `backend/messaging/middleware.py` (nouveau)

- ✅ Création d'un middleware JWT pour WebSocket
- ✅ Remplace `AuthMiddlewareStack` qui utilise les sessions (ne fonctionne pas cross-domain)
- ✅ Lit le token depuis :
  - Query parameter `?token=...`
  - Header `Authorization: Bearer ...`

**Fichier**: `backend/campuslink/asgi.py`

- ✅ Remplacement de `AuthMiddlewareStack` par `JWTAuthMiddleware`

### 3. Envoi du token dans WebSocket (Frontend)

**Fichier**: `frontend/src/hooks/useWebSocket.ts`

- ✅ Ajout du token JWT dans l'URL WebSocket : `?token=${token}`
- ✅ Vérification de la présence du token avant connexion

### 4. Gestion d'erreurs améliorée (Backend)

**Fichier**: `backend/messaging/views.py`

- ✅ Vérification `user.is_authenticated` dans `MessageViewSet.get_queryset()`
- ✅ Retour de `Message.objects.none()` si user non authentifié (au lieu de crash)

## Configuration Render requise

### Variables d'environnement à ajouter sur Render

1. **CORS Configuration** (choisir une option) :

   **Option A - Autoriser toutes les origines** (recommandé pour Vercel) :
   ```
   CORS_ALLOW_ALL_ORIGINS=True
   ```

   **Option B - Lister les URLs spécifiques** :
   ```
   CORS_ALLOWED_ORIGINS=https://campuslink-sigma.vercel.app,https://campuslink-git-main-gcs2092s-projects.vercel.app
   ```

2. **Vérifier que les autres variables sont bien configurées** :
   ```
   ALLOWED_HOSTS=campuslink-9knz.onrender.com
   DEBUG=False
   ```

## Vérification

### 1. Vérifier que le token est envoyé

Dans la console du navigateur, vérifier que les requêtes incluent :
```
Authorization: Bearer <token>
```

### 2. Vérifier la connexion WebSocket

Dans la console du navigateur, vérifier que l'URL WebSocket contient le token :
```
wss://campuslink-9knz.onrender.com/ws/chat/<conversation_id>/?token=<token>
```

### 3. Vérifier les logs Render

Après déploiement, vérifier les logs Render pour :
- ✅ Pas d'erreurs CORS
- ✅ WebSocket connections réussies
- ✅ Pas d'erreurs 401/500 sur `/api/messaging/messages/`

## Résumé des changements

| Fichier | Changement |
|---------|-----------|
| `backend/campuslink/settings.py` | Ajout URLs Vercel + option `CORS_ALLOW_ALL_ORIGINS` |
| `backend/messaging/middleware.py` | **NOUVEAU** - Middleware JWT pour WebSocket |
| `backend/campuslink/asgi.py` | Remplacement `AuthMiddlewareStack` par `JWTAuthMiddleware` |
| `backend/messaging/views.py` | Vérification `user.is_authenticated` dans `get_queryset()` |
| `frontend/src/hooks/useWebSocket.ts` | Ajout token dans URL WebSocket |

## Prochaines étapes

1. ✅ **Déployer le backend sur Render** avec les nouvelles modifications
2. ✅ **Configurer `CORS_ALLOW_ALL_ORIGINS=True`** sur Render (ou lister les URLs)
3. ✅ **Tester la connexion** depuis Vercel
4. ✅ **Vérifier les logs** pour confirmer que tout fonctionne

## Notes importantes

- ⚠️ Les wildcards (`*.vercel.app`) ne fonctionnent **pas** dans `CORS_ALLOWED_ORIGINS`
- ✅ Utiliser `CORS_ALLOW_ALL_ORIGINS=True` pour supporter toutes les preview deployments Vercel
- ✅ Le token JWT est maintenant envoyé dans l'URL WebSocket (query parameter)
- ✅ Le middleware JWT remplace complètement l'authentification par session pour WebSocket

