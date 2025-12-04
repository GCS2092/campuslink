# Guide : Migration vers Upstash Redis (Gratuit)

## Pourquoi Upstash Redis ?

✅ **Gratuit** jusqu'à 10,000 commandes/jour
✅ **Pay-as-you-go** très économique après
✅ **Service géré** (pas de maintenance)
✅ **Performance identique** à Redis classique
✅ **Parfait** pour 100-500 utilisateurs

## Étapes de migration

### 1. Créer un compte Upstash

1. Aller sur https://upstash.com
2. Créer un compte (gratuit)
3. Créer un nouveau Redis database
4. Choisir la région la plus proche (Europe pour vous)
5. Copier les credentials (URL Redis)

### 2. Configuration dans Render

Dans votre service backend sur Render :

1. Aller dans **Environment Variables**
2. Ajouter :
   ```
   REDIS_URL=redis://default:VOTRE_PASSWORD@VOTRE_ENDPOINT.upstash.io:6379
   ```
   (Upstash vous donne l'URL complète)

3. Ou si vous utilisez Redis avec TLS :
   ```
   REDIS_URL=rediss://default:VOTRE_PASSWORD@VOTRE_ENDPOINT.upstash.io:6379
   ```

### 3. Modifier settings.py

```python
# Dans settings.py, remplacer la section Cache par :

# Cache Configuration - Upstash Redis
REDIS_URL = env('REDIS_URL', default=None)
USE_REDIS_CACHE = bool(REDIS_URL)

if USE_REDIS_CACHE:
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.redis.RedisCache',
            'LOCATION': REDIS_URL,
            'OPTIONS': {
                'CLIENT_CLASS': 'django_redis.client.DefaultClient',
                'SOCKET_CONNECT_TIMEOUT': 5,
                'SOCKET_TIMEOUT': 5,
                'CONNECTION_POOL_KWARGS': {
                    'retry_on_timeout': True,
                    'health_check_interval': 30,
                }
            }
        }
    }
else:
    # Fallback: Database Cache si Redis non disponible
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.db.DatabaseCache',
            'LOCATION': 'cache_table',
            'OPTIONS': {
                'MAX_ENTRIES': 10000,
                'CULL_FREQUENCY': 3,
            },
            'TIMEOUT': 300,
        }
    }
```

### 4. Installer django-redis (optionnel mais recommandé)

```bash
pip install django-redis
```

Ajouter à `requirements.txt` :
```
django-redis>=5.2.0
```

### 5. Tester la connexion

```python
# Dans Django shell ou une vue de test
from django.core.cache import cache

# Test
cache.set('test', 'hello', 60)
print(cache.get('test'))  # Devrait afficher 'hello'
```

### 6. Déployer

1. Commit les changements
2. Push vers GitHub
3. Render redéploiera automatiquement
4. Vérifier les logs pour confirmer la connexion Redis

## Coût estimé pour 100-500 utilisateurs

**Scénario optimiste (60% cache hits) :**
- 50,000-250,000 requêtes/jour
- Cache hits : 30,000-150,000 commandes/jour
- **GRATUIT** (dans la limite de 10,000 commandes/jour)

**Scénario réaliste (80% cache hits) :**
- 50,000-250,000 requêtes/jour
- Cache hits : 40,000-200,000 commandes/jour
- **~$2-5/mois** (très économique)

**Conclusion : Probablement GRATUIT ou très peu cher !** 🎉

## Avantages vs Database Cache

| Critère | Database Cache | Upstash Redis |
|---------|----------------|---------------|
| Coût | Gratuit | Gratuit ou ~$2-5/mois |
| Latence | 5-10ms | 1-2ms |
| Charge PostgreSQL | Oui | Non |
| Scalabilité | Moyenne | Excellente |
| Cache distribué | Non | Oui |

## Rollback si problème

Si Upstash ne fonctionne pas, le code actuel avec `core/cache.py` gère déjà le fallback :
- Si Redis n'est pas disponible, les fonctions retournent `None`
- L'application continue de fonctionner sans cache
- Vous pouvez facilement revenir à Database Cache

## Support

- Documentation Upstash : https://docs.upstash.com
- Support gratuit inclus
- Dashboard pour monitoring

