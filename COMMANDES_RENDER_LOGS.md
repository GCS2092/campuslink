# 📋 Commandes pour Voir les Logs Render en Temps Réel

## 🔧 Installation de la CLI Render

### Windows (PowerShell)
```powershell
# Installer via npm (si Node.js est installé)
npm install -g render-cli

# OU via scoop (si scoop est installé)
scoop install render-cli
```

### macOS/Linux
```bash
# Installer via npm
npm install -g render-cli

# OU via Homebrew (macOS)
brew install render-cli
```

---

## 📊 Commandes Principales

### 1. Se connecter à Render
```bash
render login
```
Cela ouvrira votre navigateur pour l'authentification.

---

### 2. Voir les logs en temps réel (LIVE)
```bash
# Voir les logs du service (remplacez SERVICE_NAME par le nom de votre service)
render logs SERVICE_NAME --follow

# Exemple pour un service nommé "campuslink-backend"
render logs campuslink-backend --follow
```

**Options utiles :**
- `--follow` ou `-f` : Suivre les logs en temps réel (comme `tail -f`)
- `--tail N` : Afficher les N dernières lignes (ex: `--tail 100`)
- `--since 1h` : Afficher les logs depuis 1 heure

**Exemple complet :**
```bash
render logs campuslink-backend --follow --tail 50
```

---

### 3. Voir les logs d'un service spécifique
```bash
# Lister tous vos services
render services list

# Voir les logs d'un service par ID
render logs <SERVICE_ID> --follow
```

---

### 4. Filtrer les logs (erreurs uniquement)
```bash
# Voir uniquement les erreurs
render logs campuslink-backend --follow | grep -i "error\|exception\|traceback"

# Sur Windows PowerShell
render logs campuslink-backend --follow | Select-String -Pattern "error|exception|traceback"
```

---

### 5. Voir les logs récents (sans follow)
```bash
# Dernières 100 lignes
render logs campuslink-backend --tail 100

# Logs depuis 1 heure
render logs campuslink-backend --since 1h

# Logs depuis une date spécifique
render logs campuslink-backend --since "2024-12-04T10:00:00Z"
```

---

## 🖥️ Alternative : Shell Render (SSH)

Si SSH est activé sur votre service Render :

### 1. Se connecter au shell
```bash
# Via l'interface Render : Settings → Shell → Connect
# OU via la CLI
render shell connect <SERVICE_NAME>
```

### 2. Une fois connecté, voir les logs
```bash
# Si vous utilisez systemd
journalctl -u your-service -f

# Ou voir les logs du processus Django
tail -f /var/log/django.log

# Ou voir les logs de Daphne/Gunicorn
ps aux | grep daphne
```

---

## 🚀 Commandes Rapides pour Debug

### Voir les erreurs Django en temps réel
```bash
render logs campuslink-backend --follow | Select-String -Pattern "ERROR|Exception|Traceback"
```

### Voir les requêtes API
```bash
render logs campuslink-backend --follow | Select-String -Pattern "GET|POST|PUT|DELETE"
```

### Voir les erreurs de base de données
```bash
render logs campuslink-backend --follow | Select-String -Pattern "database|postgres|connection"
```

---

## 📝 Notes Importantes

1. **Nom du service** : Remplacez `campuslink-backend` par le nom exact de votre service Render
2. **Authentification** : Vous devez être connecté avec `render login` avant d'utiliser les commandes
3. **Limite de logs** : Render conserve les logs pendant une période limitée (généralement 7 jours)
4. **Performance** : Les logs en temps réel peuvent être volumineux, utilisez les filtres si nécessaire

---

## 🔍 Trouver le Nom de Votre Service

```bash
# Lister tous vos services
render services list

# Vous verrez quelque chose comme :
# SERVICE_ID    NAME                  TYPE    STATUS
# srv-xxxxx      campuslink-backend    web     live
```

---

## ⚡ Commande Rapide (Copier-Coller)

```bash
# 1. Installer la CLI (une seule fois)
npm install -g render-cli

# 2. Se connecter (une seule fois)
render login

# 3. Voir les logs en temps réel
render logs campuslink-backend --follow
```

**Remplacez `campuslink-backend` par le nom exact de votre service Render.**

