// ============================================================
// SERVICE WORKER — Vanilla HTML / Static sites
// Lokacija: html/sw.js (root sajta, MORA biti na root pathi)
//
// Strategija:
//   HTML stranice  → Network First (uvijek svježe, fallback cache)
//   Slike          → Cache First (brzo, 30 dana)
//   CSS/JS/Fonts   → Cache First (brzo, 7 dana)
//   Offline        → /offline.html fallback
// ============================================================

const CACHE_NAME   = 'site-v1';
const OFFLINE_URL  = '/offline.html';

// Fajlovi koji se kešuju odmah pri instalaciji
const PRECACHE = [
  '/',
  '/offline.html',
  '/favicon.svg',
  '/manifest.json',
];

// ── Install ─────────────────────────────────────────────────
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(PRECACHE))
      .then(() => self.skipWaiting())
  );
});

// ── Activate — obriši stare cache verzije ───────────────────
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys
          .filter(key => key !== CACHE_NAME)
          .map(key => caches.delete(key))
      )
    ).then(() => self.clients.claim())
  );
});

// ── Fetch — routing strategija ──────────────────────────────
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);

  // Preskoči non-GET i cross-origin zahtjeve
  if (request.method !== 'GET' || url.origin !== location.origin) return;

  // API pozivi (Web3Forms i sl.) — bez kešanja
  if (url.pathname.startsWith('/api/') || url.hostname !== location.hostname) return;

  const isHTML   = request.headers.get('Accept')?.includes('text/html');
  const isImage  = /\.(webp|png|jpg|jpeg|svg|gif|avif|ico)$/i.test(url.pathname);
  const isAsset  = /\.(css|js|woff2|woff|ttf)$/i.test(url.pathname);

  if (isHTML) {
    // Network First — HTML uvijek svjež, padni na cache ako offline
    event.respondWith(networkFirst(request));
  } else if (isImage) {
    // Cache First — slike (30 dana)
    event.respondWith(cacheFirst(request, 30));
  } else if (isAsset) {
    // Cache First — CSS/JS/fontovi (7 dana)
    event.respondWith(cacheFirst(request, 7));
  }
});

// ── Network First ───────────────────────────────────────────
async function networkFirst(request) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, response.clone());
    }
    return response;
  } catch {
    const cached = await caches.match(request);
    return cached || caches.match(OFFLINE_URL);
  }
}

// ── Cache First ─────────────────────────────────────────────
async function cacheFirst(request, maxAgeDays = 7) {
  const cached = await caches.match(request);
  if (cached) {
    const date = cached.headers.get('date');
    if (date) {
      const age = (Date.now() - new Date(date).getTime()) / 86400000;
      if (age < maxAgeDays) return cached;
    } else {
      return cached;
    }
  }
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, response.clone());
    }
    return response;
  } catch {
    return cached || new Response('', { status: 408 });
  }
}
