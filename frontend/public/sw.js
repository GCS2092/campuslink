// Service Worker - Disable for API requests
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // Skip service worker for API requests
  if (url.pathname.startsWith('/api/') || url.hostname.includes('192.168.') || url.hostname.includes('localhost')) {
    // Let the browser handle API requests normally
    return;
  }
  
  // For other requests, use network first strategy
  event.respondWith(
    fetch(event.request).catch(() => {
      // If fetch fails, return a basic response
      return new Response('Offline', {
        status: 503,
        statusText: 'Service Unavailable',
        headers: new Headers({
          'Content-Type': 'text/plain'
        })
      });
    })
  );
});

// Skip waiting and activate immediately
self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

