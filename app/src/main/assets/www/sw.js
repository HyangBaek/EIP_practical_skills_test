// 오프라인 실행용 서비스워커
// - 앱 셸(index.html 등): 캐시 먼저 보여주고 백그라운드에서 갱신
// - 기출 파일 등 그 외 같은 출처 요청: 네트워크 우선(새로 push한 파일 즉시 반영), 오프라인이면 캐시
// - Gemini/GitHub API 등 외부 요청: 관여하지 않음
const CACHE = 'jcg-v2';
const SHELL = ['./', './index.html', './manifest.webmanifest', './icons/icon-192.png', './icons/icon-512.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL))); self.skipWaiting(); });
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))));
  self.clients.claim();
});
self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);
  if (e.request.method !== 'GET' || u.origin !== location.origin) return;
  const scope = new URL(self.registration.scope);
  const rel = u.pathname.slice(scope.pathname.length);
  const isShell = rel === '' || SHELL.includes('./' + rel);
  e.respondWith(caches.open(CACHE).then(async c => {
    const hit = await c.match(e.request, { ignoreSearch: true });
    const net = fetch(e.request).then(r => { if (r.ok) c.put(e.request, r.clone()); return r; });
    if (isShell) return hit || net;
    return net.catch(() => hit || Response.error());
  }));
});
