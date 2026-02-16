# CampusLink (Expo)

Application CampusLink en **Expo / React Native**, prête à être testée sur téléphone.

## Démarrer le backend (connexion réelle)

Pour te connecter avec le backend Django :

1. **Lancer le backend** (depuis la racine du repo) :
   ```bash
   cd backend
   .\venv\Scripts\activate   # ou: venv\Scripts\activate.bat
   python manage.py runserver 0.0.0.0:8000
   ```
   Ou utiliser `start_server.bat` dans `backend/`.

2. **Configurer l’URL API dans l’app** : dans `constants.ts`, remplace `API_BASE_URL` par l’URL de ton backend, par ex. `http://192.168.1.125:8000/api` (remplace par ton IP locale). Voir aussi `DEMARRER_BACKEND.md` à la racine du repo.

3. **Redirections par rôle** : après connexion, tu es redirigé selon ton rôle :
   - **Admin** → `/admin` (tableau de bord admin)
   - **University Admin** → `/university-admin`
   - **Class Leader** → `/class-leader`
   - **Étudiant** → `/(tabs)` (onglets classiques)

## Dépendances installées

- **Expo Router** — navigation (tabs + stack)
- **expo-secure-store** — token d’authentification
- **AsyncStorage** — stockage local
- **axios** — appels API
- **zustand** — état global
- **expo-image-picker** — photos (profil, pièces jointes)
- **expo-notifications** — notifications push
- **expo-device** — infos appareil
- **zod** + **react-hook-form** — validation de formulaires

## Lancer l’app

```bash
cd CampusExpo/campuslink-app
npm start
```

Puis :

- **Sur le même WiFi** : ouvre **Expo Go** sur ton téléphone (Android/iOS), scanne le QR code affiché dans le terminal.
- **Sans même WiFi (tunnel)** : installe le tunnel puis lance avec tunnel :
  ```bash
  npx expo install @expo/ngrok
  npx expo start --tunnel
  ```
  Ensuite scanne le QR code avec Expo Go.

## Structure

- `app/` — routes Expo Router
  - `_layout.tsx` — layout racine
  - `index.tsx` — redirection (token → tabs, sinon → login)
  - `(tabs)/` — onglets : Accueil, Feed, Événements, Groupes, Profil
  - `login.tsx`, `register.tsx` — auth (démo : token factice sans backend)

## Test rapide sur téléphone

1. Installe **Expo Go** depuis le Play Store ou l’App Store.
2. Lance `npm start` dans `campuslink-app`.
3. Scanne le QR code avec Expo Go (Android) ou l’app Caméra (iOS).
4. L’app s’ouvre : écran de connexion → saisis n’importe quel email/mot de passe → « Se connecter » pour entrer dans les onglets.

## Brancher le backend Django

Dans `app/login.tsx` et `app/register.tsx`, remplacer le stockage du token factice par un appel à ton API (ex. `POST /api/auth/login`) et stocker le vrai token avec `SecureStore.setItemAsync('auth_token', token)`.
