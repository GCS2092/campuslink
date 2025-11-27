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

