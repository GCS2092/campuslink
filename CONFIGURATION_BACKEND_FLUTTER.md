# 🔧 Configuration Backend pour Flutter

## ✅ Configuration Actuelle

Votre application Flutter est **déjà configurée** pour utiliser le backend Render en production.

### 📍 URL Backend Actuelle

```dart
// lib/utils/constants.dart
static const String apiBaseUrl = 'https://campuslink-9knz.onrender.com/api';
```

**✅ Vous pouvez utiliser directement le backend Render sans rien changer !**

---

## 🎯 Deux Options Disponibles

### Option 1 : Utiliser le Backend Render (Recommandé pour Production) ✅

**Avantages** :
- ✅ **Pas besoin de lancer le backend localement**
- ✅ **Toujours disponible** (24/7)
- ✅ **Données réelles** partagées avec le web
- ✅ **HTTPS sécurisé**
- ✅ **Prêt à l'emploi immédiatement**

**Inconvénients** :
- ⚠️ **Légère latence** (dépend de votre connexion)
- ⚠️ **Limites de rate** si beaucoup d'utilisateurs
- ⚠️ **Backend peut être en veille** (première requête peut être lente)

**Quand l'utiliser** :
- ✅ **Production** / **Tests finaux**
- ✅ **Démonstration** à des clients
- ✅ **Développement** si vous n'avez pas besoin de modifier le backend

---

### Option 2 : Utiliser le Backend Local (Recommandé pour Développement) 🔧

**Avantages** :
- ✅ **Plus rapide** (pas de latence réseau)
- ✅ **Pas de limites de rate**
- ✅ **Débogage facile** (logs en direct)
- ✅ **Modifications backend** en temps réel
- ✅ **Pas de coûts** (pas de consommation Render)

**Inconvénients** :
- ❌ **Doit lancer le backend** manuellement
- ❌ **Doit être sur le même réseau** (pour mobile)
- ❌ **Backend doit être actif** pendant le développement

**Quand l'utiliser** :
- ✅ **Développement actif** du backend
- ✅ **Débogage** de problèmes spécifiques
- ✅ **Tests de performance** locaux

---

## 🔄 Comment Basculer entre les Deux

### Pour Utiliser le Backend Render (Par Défaut) ✅

**Aucune modification nécessaire !** C'est déjà configuré.

```dart
// lib/utils/constants.dart
static const String apiBaseUrl = 'https://campuslink-9knz.onrender.com/api';
```

---

### Pour Utiliser le Backend Local 🔧

#### Étape 1 : Lancer le Backend Local

```bash
# Dans le dossier backend
cd backend
python manage.py runserver 0.0.0.0:8000
```

**Important** : Utilisez `0.0.0.0:8000` (pas `localhost:8000`) pour que le mobile puisse y accéder.

#### Étape 2 : Trouver votre IP Locale

**Sur Windows** :
```powershell
ipconfig
# Cherchez "IPv4 Address" (ex: 192.168.1.100)
```

**Sur Mac/Linux** :
```bash
ifconfig
# Cherchez "inet" (ex: 192.168.1.100)
```

#### Étape 3 : Modifier la Configuration Flutter

Modifiez `lib/utils/constants.dart` :

```dart
// lib/utils/constants.dart
class AppConstants {
  // Pour développement local, décommentez et modifiez :
  static const String apiBaseUrl = 'http://VOTRE_IP_LOCALE:8000/api';
  // Exemple : static const String apiBaseUrl = 'http://192.168.1.100:8000/api';
  
  // Pour production Render, commentez la ligne ci-dessus et décommentez :
  // static const String apiBaseUrl = 'https://campuslink-9knz.onrender.com/api';
}
```

**Remplacez `VOTRE_IP_LOCALE`** par votre adresse IP locale (ex: `192.168.1.100`).

#### Étape 4 : Redémarrer l'Application Flutter

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 Configuration pour Mobile (Émulateur vs Appareil Physique)

### Si vous utilisez un Émulateur Android

**Option A : Utiliser `10.0.2.2`** (IP spéciale pour accéder à localhost de la machine hôte)
```dart
static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
```

**Option B : Utiliser l'IP locale de votre machine**
```dart
static const String apiBaseUrl = 'http://192.168.1.100:8000/api';
```

### Si vous utilisez un Appareil Physique

**Vous DEVEZ utiliser l'IP locale de votre machine** :
```dart
static const String apiBaseUrl = 'http://192.168.1.100:8000/api';
```

**Important** : L'appareil et votre machine doivent être sur le **même réseau WiFi**.

---

## 🔒 Configuration CORS pour Backend Local

Si vous utilisez le backend local, assurez-vous que CORS est configuré :

```python
# backend/campuslink/settings.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://192.168.1.100:3000",  # Votre IP locale
]

# Pour mobile Flutter, vous pouvez aussi utiliser :
CORS_ALLOW_ALL_ORIGINS = True  # En développement uniquement
```

---

## 🎯 Recommandation

### Pour Commencer (Maintenant) ✅

**Utilisez directement le backend Render** :
- ✅ Pas de configuration supplémentaire
- ✅ Fonctionne immédiatement
- ✅ Données réelles

### Pour le Développement Actif 🔧

**Utilisez le backend local** si vous :
- Modifiez le backend fréquemment
- Déboguez des problèmes spécifiques
- Testez de nouvelles fonctionnalités

---

## 🚀 Workflow Recommandé

1. **Développement initial** : Utiliser Render (déjà configuré)
2. **Tests et débogage** : Basculer vers local si nécessaire
3. **Production** : Toujours utiliser Render

---

## ⚠️ Notes Importantes

### Backend Render en Veille

Le backend Render peut être en veille après 15 minutes d'inactivité. La première requête peut prendre 30-60 secondes pour "réveiller" le serveur.

**Solution** : C'est normal, les requêtes suivantes seront rapides.

### HTTPS vs HTTP

- **Render** : Utilise HTTPS (sécurisé)
- **Local** : Utilise HTTP (développement uniquement)

**Important** : En production, utilisez toujours HTTPS.

### Firewall

Si vous utilisez le backend local, assurez-vous que le port 8000 n'est pas bloqué par votre firewall.

---

## 📝 Résumé

| Configuration | URL | Quand l'utiliser |
|--------------|-----|------------------|
| **Render (Production)** | `https://campuslink-9knz.onrender.com/api` | ✅ **Par défaut** - Production, démo, tests |
| **Local (Développement)** | `http://VOTRE_IP:8000/api` | 🔧 Développement actif, débogage |

**Pour l'instant, vous pouvez utiliser directement Render sans rien changer !** 🎉

