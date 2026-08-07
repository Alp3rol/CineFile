# Production synthetic health check

`node tool/synthetic_health_check.mjs` checks the public production path without
credentials or test data mutations:

1. GitHub Pages returns the Flutter bootstrap and deployed bundle.
2. The bundle contains the expected Firebase web app ID and Firebase Identity
   Toolkit returns the expected project configuration.
3. The live TMDb proxy returns a non-empty `/search/multi` result and the atomic
   rate-limit headers.

Each check prints its duration and a diagnostic. Any HTTP error, timeout,
configuration mismatch, empty search result, or missing quota header exits with
code 1 and names the failed check.

GitHub Actions runs this every six hours at minute 17 and also exposes a manual
**Synthetic health** workflow. The schedule is intentionally offset from the
top of the hour, when public CI and edge services commonly see traffic spikes.

Optional environment overrides are available for preview environments:

```text
CINEFILE_SITE_URL=https://preview.example/ \
CINEFILE_PROXY_URL=https://preview-worker.example \
CINEFILE_FIREBASE_API_KEY=<public-web-api-key> \
node tool/synthetic_health_check.mjs
```

The Firebase project currently does not list `alp3rol.github.io` among its
authorized domains. Firebase initialization and the current e-mail/password
flow remain observable, but redirect-based providers may require adding that
domain in Firebase Authentication settings before they are enabled.
