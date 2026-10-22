// 오프라인 실행용 서비스워커 (v3)
// 같은 출처 요청은 모두 네트워크 우선 → push한 새 버전·새 기출 파일이 바로 반영됨
// 오프라인일 때만 마지막으로 받아둔 캐시를 사용. Gemini/GitHub API 등 외부 요청은 관여하지 않음
const CACHE = 'jcg-v3';
const SHELL = ['./', './index.html', './manifest.webmanifest', './icons/icon-192.png', './icons/icon-512.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL))); self.skipWaiting(); });
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);
  if (e.request.method !== 'GET' || u.origin !== location.origin) return;
  e.respondWith(
    fetch(e.request, { cache: 'no-store' })
      .then(r => { if (r.ok) caches.open(CACHE).then(c => c.put(e.request, r.clone())); return r; })
      .catch(() => caches.match(e.request, { ignoreSearch: true }).then(hit => hit || Response.error()))
  );
});
