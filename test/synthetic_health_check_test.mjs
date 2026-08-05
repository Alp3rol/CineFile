import assert from 'node:assert/strict';
import test from 'node:test';
import { runHealthChecks } from '../tool/synthetic_health_check.mjs';

const config = {
  siteUrl: 'https://site.test/CineFile/',
  proxyUrl: 'https://proxy.test',
  firebaseApiKey: 'public-key',
  firebaseAppId: 'firebase-app-id',
  firebaseProjectNumber: '123',
};

function response(body, init = {}) {
  return new Response(typeof body === 'string' ? body : JSON.stringify(body), init);
}

test('all three production signals pass', async () => {
  const fetchImpl = async (input) => {
    const url = input.toString();
    if (url === config.siteUrl) return response('<script src="flutter_bootstrap.js"></script>');
    if (url.endsWith('/main.dart.js')) return response(`const app='${config.firebaseAppId}'`);
    if (url.includes('identitytoolkit')) {
      return response({ projectId: '123', authorizedDomains: ['site.test'] });
    }
    return response({ results: [{ title: 'Inception' }] }, {
      headers: { 'X-RateLimit-Limit': '120', 'X-RateLimit-Remaining': '119' },
    });
  };
  const results = await runHealthChecks(config, fetchImpl);
  assert.deepEqual(results.map((item) => item.check), ['web-app', 'firebase-init', 'tmdb-search']);
  assert.ok(results.every((item) => item.ok));
});

test('an empty TMDb search fails with a named diagnostic', async () => {
  const fetchImpl = async (input) => {
    const url = input.toString();
    if (url === config.siteUrl) return response('flutter_bootstrap.js');
    if (url.endsWith('/main.dart.js')) return response(config.firebaseAppId);
    if (url.includes('identitytoolkit')) return response({ projectId: '123' });
    return response({ results: [] }, { headers: { 'X-RateLimit-Limit': '120' } });
  };
  await assert.rejects(
    runHealthChecks(config, fetchImpl),
    (error) => error.check === 'tmdb-search' && /no results/.test(error.message),
  );
});

test('a non-200 web response fails before downstream checks', async () => {
  await assert.rejects(
    runHealthChecks(config, async () => response('down', { status: 503 })),
    (error) => error.check === 'web-app' && /HTTP 503/.test(error.message),
  );
});

