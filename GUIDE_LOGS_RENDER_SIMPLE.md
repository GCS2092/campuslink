# 📋 Guide Simple pour Voir les Logs Render

## 🚀 Méthode la Plus Simple (Interface Web)

### Étape 1 : Aller sur Render Dashboard
1. Ouvrez votre navigateur
2. Allez sur : **https://dashboard.render.com**
3. Connectez-vous avec votre compte

### Étape 2 : Trouver votre Service
1. Dans le dashboard, cliquez sur votre service backend (ex: `campuslink-backend`)
2. Vous verrez une page avec plusieurs onglets

### Étape 3 : Voir les Logs
1. Cliquez sur l'onglet **"Logs"** (en haut de la page)
2. Les logs s'affichent en temps réel
3. Vous pouvez faire défiler pour voir les anciens logs

### Étape 4 : Filtrer les Erreurs
- Utilisez la barre de recherche en haut des logs
- Tapez : `error` ou `ERROR` ou `Exception` ou `Traceback`
- Seules les lignes contenant ces mots s'afficheront

---

## 🔍 Méthode Alternative (CLI - Optionnel)

Si vous voulez utiliser la ligne de commande :

### Installation (une seule fois)
```powershell
npm install -g render-cli
```

### Connexion (une seule fois)
```powershell
render login
```

### Voir les logs
```powershell
# Remplacez "campuslink-backend" par le nom exact de votre service
render logs campuslink-backend --follow
```

### Voir uniquement les erreurs
```powershell
render logs campuslink-backend --follow | Select-String -Pattern "error|ERROR|Exception|Traceback"
```

---

## 🎯 Trouver le Nom de Votre Service

1. Allez sur https://dashboard.render.com
2. Dans la liste des services, trouvez votre backend
3. Le nom est affiché en haut de la page du service

**Exemples de noms possibles :**
- `campuslink-backend`
- `campuslink-api`
- `campuslink-9knz` (basé sur votre URL)

---

## ⚡ Astuce Rapide

**Pour voir les erreurs récentes :**
1. Dashboard Render → Votre service → Onglet "Logs"
2. Cherchez les lignes en **rouge** ou contenant `ERROR` ou `Exception`
3. Cliquez sur une ligne pour voir plus de détails

---

## 🆘 Si vous ne voyez pas les logs

1. **Vérifiez que le service est actif** (statut "Live" en vert)
2. **Vérifiez que vous êtes sur le bon service** (backend, pas frontend)
3. **Rafraîchissez la page** (F5)
4. **Vérifiez la date/heure** - les logs peuvent être filtrés par date

---

## 📝 Exemple de ce que vous devriez voir

```
2024-12-04 14:30:15 INFO Starting server...
2024-12-04 14:30:16 INFO Application startup complete
2024-12-04 14:30:20 ERROR Error in my_events: ...
2024-12-04 14:30:25 ERROR Error loading messages: ...
```

Les lignes avec `ERROR` sont celles qui indiquent les problèmes !

