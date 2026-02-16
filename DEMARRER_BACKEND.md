# Démarrer le backend CampusLink

## Prérequis

- Python 3.10+
- Environnement virtuel (recommandé)

## 1. Créer et activer l'environnement virtuel

```bash
cd backend
python -m venv venv
```

**Windows (PowerShell):**
```powershell
.\venv\Scripts\Activate.ps1
```

**Windows (cmd):**
```cmd
venv\Scripts\activate.bat
```

**Linux / macOS:**
```bash
source venv/bin/activate
```

## 2. Installer les dépendances

```bash
pip install -r requirements.txt
```

## 3. Variables d'environnement

Créez un fichier `backend/.env` à la racine de `backend/` (copiez depuis `.env.example` si existant). Au minimum pour le dev local :

- `SECRET_KEY` (obligatoire)
- `DEBUG=True`
- `DATABASE_URL` ou configuration SQLite pour tester sans base externe

Exemple minimal pour SQLite (sans .env si Django accepte les défauts) :

```env
SECRET_KEY=votre-cle-secrete-dev
DEBUG=True
```

## 4. Migrations (si base de données configurée)

```bash
cd backend
python manage.py migrate
```

## 5. Lancer le serveur

**Windows :**
```cmd
cd backend
start_server.bat
```

Ou manuellement :
```bash
cd backend
python manage.py runserver 0.0.0.0:8000
```

Le backend est accessible sur :

- **Sur la machine :** http://localhost:8000/
- **Depuis le téléphone (même WiFi) :** http://VOTRE_IP:8000/

Pour connaître votre IP locale :
- **Windows :** `ipconfig` (cherchez "Adresse IPv4")
- **Exemple :** 192.168.1.125

## 6. Tester l’API

- Swagger : http://localhost:8000/api/docs/
- Login : `POST http://localhost:8000/api/auth/login/` avec `{"email": "...", "password": "..."}`

## 7. Configurer l’app Expo pour le backend local

Dans `CampusExpo/campuslink-app/constants.ts`, pour utiliser le backend sur votre machine :

1. Remplacez `API_BASE_URL` par votre IP :
   ```ts
   export const API_BASE_URL = 'http://192.168.1.125:8000/api';
   ```
2. Remettez l’URL Render en production :
   ```ts
   export const API_BASE_URL = 'https://campuslink-9knz.onrender.com/api';
   ```

Pensez à utiliser **la même adresse** que celle affichée par `npm start` (ex. `exp://192.168.1.125:8082`) pour que le téléphone et le backend soient sur le même réseau.
