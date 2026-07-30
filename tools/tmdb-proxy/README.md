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
2. Rebuild and redeploy the web app with `--dart-define=TMDB_PROXY_URL=...`
   (`yayinla.bat` accepts it), so the published bundle no longer contains a key.
3. Ship a native release built the same way.
4. Only now, regenerate the key in the TMDb dashboard and
   `npx wrangler secret put TMDB_API_KEY` with the new one.

Between 1 and 4 the old key still works, so nothing goes dark.

## Restricting browser callers

Once the web build has a stable URL, uncomment `ALLOWED_ORIGINS` in
`wrangler.toml`. Leave it unset for native-only deployments — apps send no
`Origin` header, and an empty list allows everything.

## Cost

Cloudflare's free tier covers 100k requests/day. Responses are edge-cached for
10 minutes, and the app's own `title_credits` cache removes most repeat traffic
before it ever reaches the network.
