# TMDb proxy

TMDb authenticates with an `api_key` **query parameter**. There is no way to
keep such a key secret in a client app:

- the web build compiles it into `main.dart.js`, which is served to every
  visitor of the published site;
- a native build carries it in the APK/IPA, where it can be read out.

So the key has to live on a server. This worker is that server, and it is the
only component that ever sees the key.

It also supplies two things the app has nowhere else: a per-IP **rate limit**,
and an **allowlist** of the endpoints the app actually calls — so a leaked
proxy URL cannot be turned into a general-purpose TMDb relay charged to your
account.

## Deploy

```bash
cd tools/tmdb-proxy
npm install
npx wrangler login
npx wrangler secret put TMDB_API_KEY   # paste the key; it is stored by Cloudflare, never committed
npx wrangler deploy
```

Wrangler prints the URL, e.g. `https://cinefile-tmdb.<subdomain>.workers.dev`.

The first deploy creates the SQLite-backed `RateLimiter` Durable Object namespace
declared in `wrangler.toml`. Never remove or rename migration tag `v1` after it
has reached Cloudflare; later schema changes need a new tag. Before deployment,
run the same proxy gate as CI with `npm run check`.

## Abuse controls

Each `CF-Connecting-IP` maps to one globally unique Durable Object. A storage
transaction atomically applies 120 accepted requests per 60 seconds, so
simultaneous edge requests cannot race past the quota. Missing IP headers share
an `anonymous` bucket instead of bypassing it. Responses expose standard quota
metadata; rejected requests return `429` and `Retry-After`.

If the limiter is unavailable, the proxy fails closed with `503` and does not
spend TMDb quota. Configure `ALLOWED_ORIGINS` to reject unknown browser origins
with `403`. Native callers without an `Origin` remain supported. The quota key
stays IP-based because non-browser callers can forge the `Origin` header.

## Point the app at it

```bash
flutter run   --dart-define=TMDB_PROXY_URL=https://cinefile-tmdb.<subdomain>.workers.dev
flutter build web --release --dart-define=TMDB_PROXY_URL=...
```

With `TMDB_PROXY_URL` set, the app sends **no** TMDb key at all: `_apiKey`
resolves to an empty string, the proxy strips whatever arrives and appends its
own. The domain-failover and DNS-over-HTTPS layers are also skipped, since both
exist to work around TMDb's own domains being blocked and neither applies to a
different origin.

Without it, nothing changes — the app talks to TMDb directly, exactly as before.
That is deliberate: deploying the proxy is a separate decision from merging this
code.

## Order of operations when rotating the leaked key

The key currently published in `gh-pages` is still live, and **installed native
builds use it too** — revoking it first would break both until they are
rebuilt. Do it in this order:

1. Deploy this worker with the current key.
2. Set the `TMDB_PROXY_URL` GitHub secret and redeploy the web app, so the
   published bundle no longer contains a key.
3. Ship a native release built the same way.
4. Only now, regenerate the key in the TMDb dashboard and
   `npx wrangler secret put TMDB_API_KEY` with the new one.

Between 1 and 4 the old key still works, so nothing goes dark.

## Adding a TMDb endpoint

**A new `_dio.get('/...')` in `lib/core/network/tmdb_service.dart` is not enough.**
`ALLOWED_PATHS` in `src/index.js` is an allowlist — anything not matching returns
404, so the app's request fails and, because the failure surfaces as an empty
result, it looks exactly like "TMDb has no data for this title". Nothing turns
red.

So, in order:

1. Add a regex to `ALLOWED_PATHS` (written against the path with the leading
   `/3` already stripped — see the normalisation in `fetch`).
2. Add any new query parameter to `ALLOWED_PARAMS`; the upstream query string is
   rebuilt from that list, so an unlisted parameter is silently dropped.
3. `npx wrangler deploy` — **before** the client change reaches anyone on a
   proxy build. The worker is backwards compatible, so deploying it early is
   free.

`test/tmdb_proxy_allowlist_test.dart` checks step 1 automatically: it reads both
files and asserts every path the service requests matches an allowlist entry.
Step 3 it cannot check.

Note that a build without `TMDB_PROXY_URL` talks to TMDb directly and never
touches this worker, so a missing allowlist entry works perfectly on a dev
machine and breaks only the web/proxy build.

## Restricting browser callers

Once the web build has a stable URL, uncomment `ALLOWED_ORIGINS` in
`wrangler.toml`. Leave it unset for native-only deployments — apps send no
`Origin` header, and an empty list allows everything.

## Cost

Cloudflare's free tier covers 100k requests/day. Responses are edge-cached for
10 minutes, and the app's own `title_credits` cache removes most repeat traffic
before it ever reaches the network.
