#!/usr/bin/env node

import { pathToFileURL } from 'node:url';

const DEFAULTS = {
  siteUrl: 'https://alp3rol.github.io/CineFile/',
  proxyUrl: 'https://cinefile-tmdb.alp3rol17.workers.dev',
  firebaseApiKey: 'AIzaSyAFj_zdN3IctmGLMWlrFprSR9aTUJk0Xqk',
  firebaseAppId: '1:521976219913:web:afb75aedda726d625c2bd8',
  firebaseProjectNumber: '521976219913',
  searchQuery: 'Inception',
};

class HealthCheckError extends Error {
  constructor(check, message) {
    super(message);
    this.name = 'HealthCheckError';
    this.check = check;
  }
}

async function timed(check, operation) {
  const started = performance.now();
  try {
    const detail = await operation();
    return { check, ok: true, durationMs: Math.round(performance.now() - started), detail };
  } catch (error) {
    throw new HealthCheckError(
      check,
      `${error instanceof Error ? error.message : error} (${Math.round(performance.now() - started)} ms)`,
    );
  }
}

async function get(fetchImpl, url, check) {
  const response = await fetchImpl(url, {
    headers: { Accept: 'application/json,text/html,*/*', 'User-Agent': 'CineFile-Synthetic/1.0' },
    signal: AbortSignal.timeout(15_000),
  });
  if (!response.ok) throw new Error(`${check} returned HTTP ${response.status}`);
  return response;
}

export async function runHealthChecks(options = {}, fetchImpl = fetch) {
  const config = { ...DEFAULTS, ...options };
  const results = [];
  const site = new URL(config.siteUrl);

  results.push(await timed('web-app', async () => {
    const index = await get(fetchImpl, site, 'Web app');
    const html = await index.text();
    if (!html.includes('flutter_bootstrap.js')) throw new Error('Flutter bootstrap is missing');

    const bundle = await get(fetchImpl, new URL('main.dart.js', site), 'Web bundle');
    const javascript = await bundle.text();
    if (!javascript.includes(config.firebaseAppId)) {
      throw new Error('Expected Firebase app ID is missing from the live bundle');
    }
    return `HTTP 200; Firebase app ${config.firebaseAppId} is deployed`;
  }));

  results.push(await timed('firebase-init', async () => {
    const url = new URL('https://identitytoolkit.googleapis.com/v1/projects');
    url.searchParams.set('key', config.firebaseApiKey);
    const response = await get(fetchImpl, url, 'Firebase project config');
    const data = await response.json();
    if (data.projectId !== config.firebaseProjectNumber) {
      throw new Error(`Unexpected Firebase project: ${data.projectId ?? 'missing'}`);
    }
    const liveHostAuthorized = Array.isArray(data.authorizedDomains) &&
      data.authorizedDomains.includes(site.hostname);
    return `project ${data.projectId}; live domain ${liveHostAuthorized ? 'authorized' : 'not listed (redirect sign-in risk)'}`;
  }));

  results.push(await timed('tmdb-search', async () => {
    const url = new URL('/search/multi', config.proxyUrl);
    url.searchParams.set('query', config.searchQuery);
    url.searchParams.set('language', 'en-US');
    url.searchParams.set('page', '1');
    const response = await get(fetchImpl, url, 'TMDb proxy search');
    const data = await response.json();
    if (!Array.isArray(data.results) || data.results.length === 0) {
      throw new Error('TMDb search returned no results');
    }
    if (response.headers.get('x-ratelimit-limit') !== '120') {
      throw new Error('Atomic rate-limit headers are missing');
    }
    return `${data.results.length} results; quota ${response.headers.get('x-ratelimit-remaining')}/120`;
  }));

  return results;
}

async function main() {
  try {
    const results = await runHealthChecks({
      siteUrl: process.env.CINEFILE_SITE_URL || DEFAULTS.siteUrl,
      proxyUrl: process.env.CINEFILE_PROXY_URL || DEFAULTS.proxyUrl,
      firebaseApiKey: process.env.CINEFILE_FIREBASE_API_KEY || DEFAULTS.firebaseApiKey,
    });
    for (const result of results) {
      console.log(`[PASS] ${result.check} (${result.durationMs} ms): ${result.detail}`);
    }
    console.log(`[PASS] CineFile synthetic health: ${results.length}/${results.length} checks healthy`);
  } catch (error) {
    const check = error instanceof HealthCheckError ? error.check : 'unexpected';
    console.error(`[FAIL] ${check}: ${error instanceof Error ? error.message : error}`);
    process.exitCode = 1;
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) await main();
