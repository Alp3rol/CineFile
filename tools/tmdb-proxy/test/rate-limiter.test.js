import assert from 'node:assert/strict';
import test from 'node:test';
import worker, { RATE_LIMIT, RateLimiter, checkRateLimit } from '../src/index.js';

class AtomicStorage {
  data = new Map();
  tail = Promise.resolve();

  transaction(callback) {
    const run = this.tail.then(() => callback({
      get: async (key) => this.data.get(key),
      put: async (key, value) => { this.data.set(key, value); },
    }));
    this.tail = run.catch(() => {});
    return run;
  }
}

function namespace() {
  const objects = new Map();
  return {
    idFromName: (name) => name,
    get(id) {
      if (!objects.has(id)) objects.set(id, new RateLimiter({ storage: new AtomicStorage() }));
      const object = objects.get(id);
      return { fetch: (url, init) => object.fetch(new Request(url, init)) };
    },
  };
}

function request(ip) {
  return new Request('https://proxy.invalid/movie/popular', {
    headers: ip ? { 'CF-Connecting-IP': ip } : {},
  });
}

test('parallel requests share one atomic per-IP quota', async () => {
  const env = { RATE_LIMITER: namespace() };
  const results = await Promise.all(Array.from({ length: 150 }, () =>
    checkRateLimit(request('203.0.113.1'), env, 30_000)));
  assert.equal(results.filter((result) => result.allowed).length, RATE_LIMIT.requests);
  assert.equal(results.filter((result) => !result.allowed).length, 30);
});

test('different IPs have separate quotas and the window resets', async () => {
  const env = { RATE_LIMITER: namespace() };
  for (let index = 0; index < RATE_LIMIT.requests; index += 1) {
    assert.equal((await checkRateLimit(request('203.0.113.1'), env, 1_000)).allowed, true);
  }
  assert.equal((await checkRateLimit(request('203.0.113.1'), env, 1_000)).allowed, false);
  assert.equal((await checkRateLimit(request('203.0.113.2'), env, 1_000)).allowed, true);
  assert.equal((await checkRateLimit(request('203.0.113.1'), env, 61_000)).allowed, true);
});

test('missing IP uses a shared anonymous bucket instead of bypassing quota', async () => {
  const env = { RATE_LIMITER: namespace() };
  for (let index = 0; index < RATE_LIMIT.requests; index += 1) {
    await checkRateLimit(request(), env, 1_000);
  }
  assert.equal((await checkRateLimit(request(), env, 1_000)).allowed, false);
});

test('configured origin allowlist rejects untrusted browser callers', async () => {
  const response = await worker.fetch(new Request('https://proxy.invalid/movie/popular', {
    headers: { Origin: 'https://evil.example' },
  }), {
    ALLOWED_ORIGINS: 'https://alp3rol.github.io',
    TMDB_API_KEY: 'test',
    RATE_LIMITER: namespace(),
  });
  assert.equal(response.status, 403);
});

test('exhausted quota returns 429 with reset metadata', async () => {
  const limiter = namespace();
  const env = { RATE_LIMITER: limiter, TMDB_API_KEY: 'test' };
  const clientRequest = request('203.0.113.9');
  const now = Date.now();
  for (let index = 0; index < RATE_LIMIT.requests; index += 1) {
    await checkRateLimit(clientRequest, env, now);
  }
  const response = await worker.fetch(clientRequest, env);
  assert.equal(response.status, 429);
  assert.equal(response.headers.get('X-RateLimit-Limit'), String(RATE_LIMIT.requests));
  assert.equal(response.headers.get('X-RateLimit-Remaining'), '0');
  assert.ok(Number(response.headers.get('Retry-After')) >= 1);
});

test('limiter failure is fail-closed', async () => {
  const originalError = console.error;
  console.error = () => {};
  const response = await worker.fetch(request('203.0.113.1'), { TMDB_API_KEY: 'test' });
  console.error = originalError;
  assert.equal(response.status, 503);
  assert.equal(response.headers.get('Retry-After'), '5');
});
