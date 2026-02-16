const CACHE_NAME = 'campuslink-pwa-v1';

// Ne pas intercepter les requêtes API (toujours réseau)
function isApiOrExternal(req) {
  const url = new URL(req.url);
  if (url.pathname.startsWith('/api/')) return true;
  if (url.hostname !== self.location.hostname) return true;
  return false;
}

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  if (isApiOrExternal(event.request)) return;

  const url = new URL(event.request.url);
  const isNav = event.request.mode === 'navigate';

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        if (isNav && response.ok) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
        }
        return response;
      })
      .catch(() => {
        if (isNav) {
          return caches.match(event.request).then((cached) => cached || offlinePage());
        }
        return caches.match(event.request) || offlinePage();
      })
  );
});

function offlinePage() {
  return new Response(
    `<!DOCTYPE html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>CampusLink - Hors ligne</title></head><body style="font-family:sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f1f5f9;"><div style="text-align:center;padding:2rem;"><h1 style="color:#0ea5e9;">CampusLink</h1><p>Vous êtes hors ligne.</p><p>Reconnectez-vous pour continuer.</p></div></body></html>`,
    { status: 200, headers: { 'Content-Type': 'text/html; charset=utf-8' } }
  );
}
