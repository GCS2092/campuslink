# Configuration Cloudinary pour CampusLink

## Pourquoi Cloudinary ?

Cloudinary est un service cloud qui gère automatiquement :
- ✅ Le stockage des images
- ✅ La compression et optimisation automatique
- ✅ Le redimensionnement à la volée
- ✅ Le CDN global pour des chargements rapides
- ✅ La transformation d'images (crop, resize, etc.)
- ✅ Plan gratuit généreux (25GB de stockage, 25GB de bande passante)

## Installation

Les packages sont déjà installés dans `requirements.txt` :
- `django-cloudinary-storage==0.3.0`
- `cloudinary==1.36.0`

## Configuration

### 1. Créer un compte Cloudinary

1. Allez sur [https://cloudinary.com](https://cloudinary.com)
2. Créez un compte gratuit
3. Une fois connecté, allez dans le Dashboard
4. Copiez vos identifiants :
   - **Cloud Name**
   - **API Key**
   - **API Secret**

### 2. Configurer les variables d'environnement

Ajoutez ces variables dans votre fichier `.env` :

```env
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=votre_cloud_name
CLOUDINARY_API_KEY=votre_api_key
CLOUDINARY_API_SECRET=votre_api_secret

# Activer Cloudinary (même en développement pour tester)
USE_CLOUDINARY=True
```

### 3. En production

En production, définissez simplement :
```env
USE_CLOUDINARY=True
```

Et les images seront automatiquement stockées sur Cloudinary.

## Utilisation

Une fois configuré, les images uploadées via le modèle `FeedItem` seront automatiquement :
- Uploadées sur Cloudinary
- Accessibles via une URL CDN
- Optimisées automatiquement

## Avantages

1. **Pas de gestion de fichiers locaux** : Plus besoin de gérer le dossier `media/`
2. **CDN intégré** : Les images sont servies rapidement partout dans le monde
3. **Optimisation automatique** : Compression et format WebP automatique
4. **Transformations à la volée** : Vous pouvez redimensionner les images via l'URL
   - Exemple : `image.jpg?w=300,h=300,c_fill` pour une image 300x300

## Exemple de transformation d'image

Dans votre frontend, vous pouvez utiliser les transformations Cloudinary :

```typescript
// Image originale
const originalUrl = feedItem.image

// Image redimensionnée à 300x300
const thumbnailUrl = feedItem.image.replace('/upload/', '/upload/w_300,h_300,c_fill/')

// Image en format WebP
const webpUrl = feedItem.image.replace('/upload/', '/upload/f_webp/')
```

## Migration des images existantes

Si vous avez déjà des images en local et que vous voulez les migrer vers Cloudinary :

```python
# Script de migration (à exécuter une fois)
from feed.models import FeedItem
from cloudinary.uploader import upload

for item in FeedItem.objects.exclude(image=''):
    if item.image and not item.image.startswith('http'):
        # Upload vers Cloudinary
        result = upload(item.image.path, folder='campuslink/feed_images')
        item.image = result['secure_url']
        item.save()
```

## Support

- Documentation Cloudinary : https://cloudinary.com/documentation
- Documentation django-cloudinary-storage : https://github.com/klis87/django-cloudinary-storage

