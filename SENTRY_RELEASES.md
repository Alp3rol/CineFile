# Sentry release metadata

Production events use one shared contract on web and native builds:

- `SENTRY_RELEASE=cinefile@<pubspec version>` (for example `cinefile@1.7.2+12`)
- `SENTRY_COMMIT=<12-character Git SHA>`
- `SENTRY_ENVIRONMENT=production` (use `preview` for preview builds)

The GitHub web deployment derives all three automatically. It stops before the
build if version or commit cannot be derived, and verifies that a Sentry-enabled
bundle contains the generated values. `yayinla.bat` derives the same metadata
for local web publishing and includes `SENTRY_DSN` when that environment
variable is set.

Native production builds must pass the same values explicitly. Example:

```text
flutter build apk --release \
  --dart-define=SENTRY_DSN=<dsn> \
  --dart-define=SENTRY_RELEASE=cinefile@1.7.2+12 \
  --dart-define=SENTRY_COMMIT=d73505951a62 \
  --dart-define=SENTRY_ENVIRONMENT=production
```

Sentry stores the release in its standard `release` field, the commit in both
`dist` and the `commit` tag, and the environment in its standard `environment`
field plus `deployment_environment`. Builds without a DSN do not initialize
Sentry. Developer builds with a DSN use the searchable fallbacks
`cinefile@development`, `local`, and `development`.
