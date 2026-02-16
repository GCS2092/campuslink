# Vérifications connexion Backend ↔ Expo

## 1. Backend (déjà vérifié / corrigé)

- **ALLOWED_HOSTS** : en DEBUG contient `*`, `localhost`, `127.0.0.1`, ton IP locale, `10.0.2.2` (émulateur Android). Pas d’espace en trop dans les entrées.
- **CORS** : en DEBUG, `CORS_ALLOW_ALL_ORIGINS = True` → toute origine acceptée (Expo, émulateur, téléphone).
- **Écoute** : le serveur doit être lancé sur **0.0.0.0:8000** :
  ```bash
  python manage.py runserver 0.0.0.0:8000
  ```
  Les messages « Redis not available, using InMemoryChannelLayer » sont normaux en dev.

## 2. Vérifier que le backend répond (sur le PC)

Dans un terminal (backend arrêté ou non) :

```powershell
# Test rapide (doit répondre quelque chose, pas "connexion refusée")
Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/" -UseBasicParsing -TimeoutSec 5
```

Si le backend tourne, tu auras une réponse (même 404 ou du HTML/JSON). Si « impossible de se connecter », démarre le backend.

Test du login (attendu : 400/401 sans identifiants valides) :

```powershell
Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/login/" -Method POST -ContentType "application/json" -Body '{"email":"x","password":"y"}' -UseBasicParsing -TimeoutSec 5
```

## 3. Script de vérification (optionnel)

Depuis `backend/` :

```powershell
cd c:\campusLink\backend
python verify_connection.py
```

Le script affiche ton IP locale et teste si le backend répond. Lance-le **avec le backend déjà démarré** dans un autre terminal.

## 4. Expo (constants.ts)

- **Émulateur Android** : `API_BASE_URL = 'http://10.0.2.2:8000/api'`
- **Téléphone réel** (même Wi‑Fi que le PC) : remplacer par l’IP de ton PC, ex. `http://192.168.1.xxx:8000/api`. Pour connaître l’IP : `ipconfig` (Adresse IPv4 de la carte Wi‑Fi).

## 5. Pare-feu Windows

Si l’app sur **téléphone réel** ne joint pas le backend alors que l’URL est bonne :

- Autoriser Python dans le pare-feu (réseau privé), ou
- Désactiver temporairement le pare-feu pour tester.

## Récap

| Étape | Action |
|-------|--------|
| 1 | Backend : `python manage.py runserver 0.0.0.0:8000` |
| 2 | Sur le PC : `Invoke-WebRequest http://127.0.0.1:8000/api/` → doit répondre |
| 3 | Expo `constants.ts` : URL = `10.0.2.2` (émulateur) ou IP du PC (téléphone) |
| 4 | Connexion : email `admin@campuslink.sn` + mot de passe défini avec `changepassword` |
