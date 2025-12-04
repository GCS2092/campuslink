# 🔄 Guide de Déploiement - Migration Messaging

## 📋 Situation Actuelle

### ✅ Commit Local
- **Commit ID** : `ded441c`
- **Migration** : `0006_message_attachment_name_message_attachment_size_and_more.py`
- **Statut** : ✅ Commitée et poussée vers GitHub

### ⚠️ Problème Détecté sur Render
Le log Render montre :
```
No migrations to apply.
```

Cela peut signifier :
1. ✅ La migration a déjà été appliquée (peu probable)
2. ⚠️ Render n'a pas encore récupéré le dernier commit
3. ⚠️ Le déploiement automatique n'a pas été déclenché

---

## 🔧 Solutions

### Option 1 : Vérifier le Déploiement Automatique (Recommandé)

1. **Vérifier sur Render** :
   - Aller sur le dashboard Render
   - Vérifier si un nouveau déploiement est en cours ou récent
   - Vérifier la date du dernier déploiement

2. **Si le déploiement n'a pas été déclenché** :
   - Cliquer sur "Manual Deploy" → "Deploy latest commit"
   - Attendre la fin du déploiement

### Option 2 : Appliquer la Migration Manuellement

Si le déploiement automatique ne fonctionne pas, connectez-vous au shell Render et exécutez :

```bash
cd backend
python manage.py migrate messaging
```

### Option 3 : Vérifier que la Migration est Présente

Sur le shell Render, vérifiez que la migration existe :

```bash
ls -la backend/messaging/migrations/0006_*.py
```

Si le fichier n'existe pas, Render n'a pas récupéré le dernier commit.

---

## ✅ Vérification Post-Déploiement

### Backend (Render)
1. Vérifier que la migration a été appliquée :
   ```bash
   python manage.py showmigrations messaging
   ```
   Vous devriez voir `[X] 0006_message_attachment_name_message_attachment_size_and_more`

2. Vérifier que les nouveaux champs existent :
   ```bash
   python manage.py shell
   >>> from messaging.models import Message
   >>> Message._meta.get_field('attachment_url')
   ```

### Frontend (Vercel)
1. Vérifier que le build a réussi (status 200 dans les logs)
2. Tester l'upload de fichier dans les messages
3. Tester la recherche dans les messages

---

## 🚨 Actions Immédiates

### 1. Vérifier Render
- [ ] Aller sur https://dashboard.render.com
- [ ] Vérifier le statut du dernier déploiement
- [ ] Si nécessaire, déclencher un déploiement manuel

### 2. Vérifier Vercel
- [ ] Aller sur https://vercel.com
- [ ] Vérifier que le dernier déploiement est récent
- [ ] Vérifier que le build a réussi

### 3. Tester les Fonctionnalités
- [ ] Tester l'upload de fichier dans `/messages`
- [ ] Tester la recherche dans les messages
- [ ] Vérifier que les pièces jointes s'affichent correctement

---

## 📝 Notes

- **Migration** : `0006_message_attachment_name_message_attachment_size_and_more.py`
- **Champs ajoutés** :
  - `attachment_url` (URLField)
  - `attachment_name` (CharField)
  - `attachment_size` (IntegerField)
- **Endpoint ajouté** : `/api/messaging/messages/upload_attachment/`

---

*Document créé le 2025-12-04*

