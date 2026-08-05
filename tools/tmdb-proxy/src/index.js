/** CineFile TMDb proxy — API key isolation, endpoint allowlist and abuse control. */

const TMDB_ORIGIN = 'https://api.themoviedb.org';

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

const ALLOWED_PARAMS = new Set([
  'query', 'page', 'language', 'append_to_response', 'sort_by', 'with_genres',
  'with_crew', 'with_cast', 'with_people',
]);

export const RATE_LIMIT = { requests: 120, windowSeconds: 60 };

function cors(origin, allowedOrigins) {
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

function json(status, body, headers = {}) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', ...headers },
  });
}

/**
 * One instance exists per client key. The storage transaction makes the
 * fixed-window read/increment/write indivisible, including under concurrency.
 */
export class RateLimiter {
  constructor(state) {
    this.state = state;
  }

  async fetch(request) {
    if (request.method !== 'POST') return json(405, { error: 'Only POST is supported' });

    const { nowMs = Date.now(), limit, windowSeconds } = await request.json();
    if (!Number.isInteger(limit) || limit < 1 ||
        !Number.isInteger(windowSeconds) || windowSeconds < 1) {
      return json(400, { error: 'Invalid rate-limit configuration' });
    }

    const windowMs = windowSeconds * 1000;
    const windowStart = Math.floor(nowMs / windowMs) * windowMs;
    let result;

    await this.state.storage.transaction(async (txn) => {
      const stored = await txn.get('window');
      const count = stored?.windowStart === windowStart ? stored.count : 0;
      const allowed = count < limit;
      const nextCount = allowed ? count + 1 : count;
      await txn.put('window', { windowStart, count: nextCount });
      result = {
        allowed,
        limit,
        remaining: Math.max(0, limit - nextCount),
        resetAt: windowStart + windowMs,
      };
    });

    return json(200, result);
  }
}

function clientKey(request) {
  // Cloudflare always supplies CF-Connecting-IP in production. A shared
  // anonymous bucket is intentionally used in local/non-Cloudflare traffic so
  // a missing header never becomes a quota bypass.
  return request.headers.get('CF-Connecting-IP')?.trim() || 'anonymous';
}

export async function checkRateLimit(request, env, nowMs = Date.now()) {
  if (!env.RATE_LIMITER) throw new Error('RATE_LIMITER binding is missing');
  const id = env.RATE_LIMITER.idFromName(clientKey(request));
  const stub = env.RATE_LIMITER.get(id);
  const response = await stub.fetch('https://rate-limiter.internal/check', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ nowMs, limit: RATE_LIMIT.requests, windowSeconds: RATE_LIMIT.windowSeconds }),
  });
  if (!response.ok) throw new Error(`Rate limiter returned ${response.status}`);
  return response.json();
}

export default {
  async fetch(request, env) {
    const allowedOrigins = (env.ALLOWED_ORIGINS ?? '').split(',').map((s) => s.trim()).filter(Boolean);
    const origin = request.headers.get('Origin');
    const corsHeaders = cors(origin, allowedOrigins);

    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: corsHeaders });
    if (request.method !== 'GET') return json(405, { error: 'Only GET is supported' }, corsHeaders);
    if (allowedOrigins.length > 0 && origin && !allowedOrigins.includes(origin)) {
      return json(403, { error: 'Origin not allowed' }, corsHeaders);
    }
    if (!env.TMDB_API_KEY) return json(500, { error: 'Proxy is missing TMDB_API_KEY' }, corsHeaders);

    const url = new URL(request.url);
    const tmdbPath = url.pathname.startsWith('/3/') ? url.pathname.slice(2) : url.pathname;
    if (!ALLOWED_PATHS.some((re) => re.test(tmdbPath))) {
      return json(404, { error: 'Endpoint not proxied' }, corsHeaders);
    }

    let quota;
    try {
      quota = await checkRateLimit(request, env);
    } catch (error) {
      console.error('Rate limiter unavailable', error);
      return json(503, { error: 'Rate limiter unavailable' }, { ...corsHeaders, 'Retry-After': '5' });
    }

    const quotaHeaders = {
      'X-RateLimit-Limit': String(quota.limit),
      'X-RateLimit-Remaining': String(quota.remaining),
      'X-RateLimit-Reset': String(Math.ceil(quota.resetAt / 1000)),
    };
    if (!quota.allowed) {
      return json(429, { error: 'Rate limit exceeded' }, {
        ...corsHeaders,
        ...quotaHeaders,
        'Retry-After': String(Math.max(1, Math.ceil((quota.resetAt - Date.now()) / 1000))),
      });
    }

    const upstream = new URL(`${TMDB_ORIGIN}/3${tmdbPath}`);
    for (const [name, value] of url.searchParams) {
      if (ALLOWED_PARAMS.has(name)) upstream.searchParams.append(name, value);
    }
    upstream.searchParams.set('api_key', env.TMDB_API_KEY);

    const response = await fetch(upstream.toString(), {
      cf: { cacheTtl: 600, cacheEverything: true },
      headers: { Accept: 'application/json' },
    });
    const out = new Response(response.body, response);
    for (const [key, value] of Object.entries({ ...corsHeaders, ...quotaHeaders })) out.headers.set(key, value);
    out.headers.delete('Location');
    return out;
  },
};
