# CampusLink Frontend

Frontend Next.js pour CampusLink - Réseau Social Étudiant.

## Technologies

- **Next.js 14** - Framework React
- **React 18** - Bibliothèque UI
- **TypeScript** - Typage statique
- **TailwindCSS** - Framework CSS
- **React Query** - Gestion d'état serveur
- **Zustand** - Gestion d'état client
- **Axios** - Client HTTP
- **Firebase** - Notifications push

## Installation

```bash
npm install
```

## Développement

```bash
npm run dev
```

Ouvrez [http://localhost:3000](http://localhost:3000) dans votre navigateur.

## Build Production

```bash
npm run build
npm start
```

## Tests

```bash
npm test
npm run test:e2e
```

## Structure

```
src/
├── app/              # Pages Next.js (App Router)
├── components/       # Composants React
├── context/          # Context API
├── services/         # Services API
├── hooks/            # Custom hooks
└── utils/            # Utilitaires
```

## Dépannage

### Erreurs "Could not establish connection. Receiving end does not exist" / "useCache"

Ces messages viennent des **extensions du navigateur** (React DevTools, bloqueurs de pub, etc.), pas de CampusLink. Vous pouvez les ignorer ou désactiver les extensions sur `localhost` pour une console plus propre.

### ERR_CONNECTION_TIMED_OUT vers l’API (192.168.x.x:8000)

L’app essaie de joindre le backend à l’URL configurée au démarrage de `npm run dev` (ou dans `.env.local`).

- **Vérifier que le backend Django tourne** sur la même machine que le frontend (ou sur l’IP affichée) :  
  `python manage.py runserver 0.0.0.0:8000`
- **Vérifier l’URL de l’API** : au lancement de `npm run dev`, la console affiche `🔗 API URL: http://...`. C’est cette machine qui doit faire tourner le backend.
- Si vous avez un **.env.local** avec `NEXT_PUBLIC_API_URL=...`, il a la priorité. Adaptez l’IP (ex. `http://192.168.1.127:8000/api`) puis redémarrez `npm run dev`.

