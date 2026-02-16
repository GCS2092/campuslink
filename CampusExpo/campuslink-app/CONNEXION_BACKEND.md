# Connexion Expo → Backend

## Si tu utilises le backend sur ton PC (local)

1. **Démarre le backend** dans un terminal :
   ```bash
   cd c:\campusLink\backend
   python manage.py runserver 0.0.0.0:8000
   ```

2. **Dans l’app Expo**, pointe l’API vers ton PC :
   - Ouvre `constants.ts`.
   - Remplace `API_BASE_URL` par l’URL de ton backend :
     - **Téléphone réel** (même Wi‑Fi que le PC) : `http://IP_DE_TON_PC:8000/api`  
       Exemple : `http://192.168.1.100:8000/api`  
       (Pour connaître l’IP : `ipconfig` sous Windows, regarde « Adresse IPv4 ».)
     - **Émulateur Android** : `http://10.0.2.2:8000/api`
     - **Émulateur iOS** : même chose que le téléphone réel, avec l’IP du Mac/PC.

3. **Identifiants** : utilise l’email et le mot de passe du compte que tu as créé ou modifié en local (ex. `admin@campuslink.sn` + le mot de passe défini avec `changepassword`).

## Si tu utilises le backend sur Render

- Garde `API_BASE_URL = 'https://campuslink-9knz.onrender.com/api'` dans `constants.ts`.
- Les comptes et mots de passe sont ceux de la base sur Render (pas ceux de ta base locale). Si tu as oublié le mot de passe, il faut le réinitialiser ou créer un superuser sur l’instance Render (via le shell fourni par Render).

## En cas d’erreur au login

- L’app affiche maintenant des messages plus précis (réseau, serveur introuvable, identifiants incorrects).
- Vérifie que le backend tourne et que l’URL dans `constants.ts` correspond bien au serveur que tu utilises (local ou Render).
