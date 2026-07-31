/**
 * CineFile TMDb proxy.
 *
 * TMDb authenticates with an `api_key` *query parameter*, so any key the client
 * holds is exposed: in the web build it is served to every visitor inside
 * main.dart.js, and in a native build it can be read straight out of the APK.
 * There is no client-side fix for that — the key has to live somewhere the user
 * cannot reach, which means a server.
 *
 * This worker is that server. It is deliberately small: it forwards GET
 * requests to api.themoviedb.org, appends the key from a secret, and refuses
 * everything else. It also adds the two things the app has nowhere else — a
 * per-IP rate limit, and an allowlist of the endpoints the app actually calls,
 * so a leaked proxy URL cannot be turned into a general-purpose TMDb relay.
 *
 * Deploy:
 *   cd tools/tmdb-proxy
 *   npm install
 *   npx wrangler secret put TMDB_API_KEY     # paste the key, it is never committed
 *   npx wrangler deploy
 *
 * Then build the app against it:
 *   flutter build web --dart-define=TMDB_PROXY_URL=https://<name>.workers.dev
 */

const TMDB_ORIGIN = 'https://api.themoviedb.org';

/**
 * Endpoints the app calls, as regexes over the path after `/3`.
 * Anything else gets a 404 — see the module comment.
 */
const ALLOWED_PATHS = [
  /^\/search\/(multi|person)$/,
  /^\/movie\/(popular|top_rated)$/,
  /^\/tv\/(popular|top_rated)$/,
  /^\/trending\/(movie|tv)\/(day|week)$/,
  /^\/discover\/(movie|tv)$/,
  /^\/movie\/\d+$/,
  /^\/tv\/\d+$/,
  /^\/tv\/\d+\/season\/\d+$/,
  /^\/movie\/\d+\/watch\/providers$/,
  /^\/tv\/\d+\/watch\/providers$/,
  /^\/person\/\d+$/,
  /^\/person\/\d+\/combined_credits$/,
];

/** Query parameters that may be forwarded. `api_key` is deliberately absent. */
const ALLOWED_PARAMS = new Set([
  'query',
  'page',
  'language',
  'append_to_response',
  'sort_by',
  'with_genres',
  'with_crew',
  'with_cast',
  'with_people',
]);

const RATE_LIMIT = { requests: 120, windowSeconds: 60 };

function cors(origin, allowedOrigins) {
  // When ALLOWED_ORIGINS is unset every origin is allowed, which is the right
  // default for a native-only deployment (apps send no Origin header) and for
  // getting started. Set it once the web build has a stable URL.
  const allowAll = allowedOrigins.length === 0;
  const allowed = allowAll || (origin && allowedOrigins.includes(origin));
  return {
    'Access-Control-Allow-Origin': allowed ? (origin ?? '*') : 'null',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Max-Age': '86400',
    Vary: 'Origin',
  };
}

function json(status, body, headers) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', ...headers },
  });
}

/**
 * Fixed-window per-IP limit backed by the Cache API, so it needs no extra
 * binding to stand up. It is approximate — windows reset on the minute and
 * each edge location counts separately — which is the right trade for abuse
 * protection on a hobby deployment. Swap in a Durable Object if it ever needs
 * to be exact.
 */
async function isRateLimited(request, ctx) {
  const ip = request.headers.get('CF-Connecting-IP');
  if (!ip) return false;

  const window = Math.floor(Date.now() / 1000 / RATE_LIMIT.windowSeconds);
  const key = new Request(`https://ratelimit.invalid/${encodeURIComponent(ip)}/${window}`);
  const cache = caches.default;

  const seen = await cache.match(key);
  const count = seen ? Number(await seen.text()) : 0;
  if (count >= RATE_LIMIT.requests) return true;

  ctx.waitUntil(
    cache.put(
      key,
      new Response(String(count + 1), {
        headers: { 'Cache-Control': `max-age=${RATE_LIMIT.windowSeconds}` },
      }),
    ),
  );
  return false;
}

export default {
  async fetch(request, env, ctx) {
    const allowedOrigins = (env.ALLOWED_ORIGINS ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    const corsHeaders = cors(request.headers.get('Origin'), allowedOrigins);

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }
    if (request.method !== 'GET') {
      return json(405, { error: 'Only GET is supported' }, corsHeaders);
    }
    if (!env.TMDB_API_KEY) {
      // Fail loudly rather than forwarding an unauthenticated request and
      // returning TMDb's own confusing 401.
      return json(500, { error: 'Proxy is missing TMDB_API_KEY' }, corsHeaders);
    }

    const url = new URL(request.url);

    // Requests arrive BOTH ways, so both are accepted.
    //
    // TMDb's own base URL is `https://api.themoviedb.org/3`, i.e. the version
    // segment is part of the base rather than of each path. Pointing the app at
    // a proxy origin with no path therefore produces `/search/person`, not
    // `/3/search/person` — which an earlier version of this worker rejected
    // with a 404, breaking every request the app made. Normalising here means
    // the proxy URL can be configured with or without the `/3` suffix.
    const tmdbPath = url.pathname.startsWith('/3/')
      ? url.pathname.slice(2)
      : url.pathname;

    if (!ALLOWED_PATHS.some((re) => re.test(tmdbPath))) {
      return json(404, { error: 'Endpoint not proxied' }, corsHeaders);
    }

    if (await isRateLimited(request, ctx)) {
      return json(429, { error: 'Rate limit exceeded' }, {
        ...corsHeaders,
        'Retry-After': String(RATE_LIMIT.windowSeconds),
      });
    }

    // Rebuilt from an allowlist rather than copied: this is what guarantees a
    // client-supplied `api_key` can never be forwarded, and keeps the upstream
    // URL (and therefore the cache key) stable.
    const upstream = new URL(`${TMDB_ORIGIN}/3${tmdbPath}`);
    for (const [name, value] of url.searchParams) {
      if (ALLOWED_PARAMS.has(name)) upstream.searchParams.append(name, value);
    }
    upstream.searchParams.set('api_key', env.TMDB_API_KEY);

    const response = await fetch(upstream.toString(), {
      // TMDb responses are shared across all users, so let the edge cache them.
      cf: { cacheTtl: 600, cacheEverything: true },
      headers: { Accept: 'application/json' },
    });

    const out = new Response(response.body, response);
    for (const [k, v] of Object.entries(corsHeaders)) out.headers.set(k, v);
    // Never let an upstream header leak the key back out via a redirect target.
    out.headers.delete('Location');
    return out;
  },
};
