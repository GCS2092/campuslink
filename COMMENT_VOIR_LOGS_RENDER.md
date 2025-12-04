# Comment voir les logs Render

## Option 1 : Interface Web (Recommandé) ✅

1. Allez sur https://dashboard.render.com
2. Connectez-vous à votre compte
3. Cliquez sur votre service backend (campuslink)
4. Cliquez sur l'onglet **"Logs"** dans le menu de gauche
5. Les logs s'affichent en temps réel avec toutes les erreurs

**Avantages** :
- Interface graphique facile à utiliser
- Filtrage par date/heure
- Recherche dans les logs
- Coloration syntaxique

## Option 2 : Shell Render (si vous êtes déjà connecté)

Si vous êtes déjà dans le shell Render via SSH, vous pouvez voir les logs avec :

```bash
# Voir les logs récents
tail -f /var/log/render.log

# Ou voir les logs de l'application Django
# (si les logs sont redirigés vers un fichier)
tail -f /var/log/django.log

# Voir les dernières 100 lignes
tail -n 100 /var/log/render.log
```

**Note** : Le chemin exact des logs peut varier selon la configuration Render.

## Option 3 : CLI Render (sur votre machine locale)

Si vous avez installé le CLI Render sur votre machine locale :

```bash
# Installer le CLI Render (si pas déjà fait)
npm install -g render-cli

# Se connecter
render login

# Voir les logs en temps réel
render logs --tail --service <service-id>
```

## Pour déboguer l'erreur 500 sur /api/messaging/messages/

1. **Allez sur l'interface web Render** → Logs
2. **Filtrez par** : "Error in MessageViewSet" ou "500"
3. **Cherchez** les lignes qui contiennent :
   - `Error in MessageViewSet.list:`
   - `Traceback:`
   - `Error in get_queryset for messages:`

4. **Copiez l'erreur complète** et partagez-la pour qu'on puisse identifier le problème exact

## Exemple de ce qu'il faut chercher dans les logs

```
ERROR Error in MessageViewSet.list: <message d'erreur>
ERROR Traceback: <stack trace complet>
ERROR Request user: <user info>
ERROR Conversation ID: <conversation id>
```

Ces informations nous permettront de voir exactement ce qui cause l'erreur 500.

