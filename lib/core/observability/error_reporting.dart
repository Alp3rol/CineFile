import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Where crashes are sent, e.g.
/// `--dart-define=SENTRY_DSN=https://<key>@<org>.ingest.sentry.io/<project>`.
///
/// Empty by default, and an empty DSN means Sentry is never initialized at all
/// — not initialized-and-silent. Local runs, `flutter test` and anyone building
/// this repo without a Sentry account therefore behave exactly as they did
/// before crash reporting existed, and no test can accidentally reach out over
/// the network.
///
/// Unlike the TMDb key in `ApiConstants`, a DSN is *not* a secret: it is
/// designed to be readable in the client that sends events, and it only grants
/// the ability to submit them. It is a `--dart-define` for the same reason the
/// TMDb proxy URL is — so the value belongs to the deployment rather than to
/// the working tree.
const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
const String sentryRelease = String.fromEnvironment('SENTRY_RELEASE');
const String sentryCommit = String.fromEnvironment('SENTRY_COMMIT');
const String sentryEnvironment = String.fromEnvironment('SENTRY_ENVIRONMENT');

/// Metadata attached to every event. Production builds receive these values
/// from the release workflow; local builds deliberately keep readable
/// fallbacks so enabling a developer DSN does not create unlabeled events.
@visibleForTesting
({String release, String commit, String environment}) resolveSentryMetadata({
  required String release,
  required String commit,
  required String environment,
  required bool isReleaseMode,
}) => (
  release: release.isEmpty ? 'cinefile@development' : release,
  commit: commit.isEmpty ? 'local' : commit,
  environment: environment.isEmpty
      ? (isReleaseMode ? 'production' : 'development')
      : environment,
);

/// Whether this build reports errors anywhere other than the console.
bool get errorReportingEnabled => sentryDsn.isNotEmpty;

/// Runs [appRunner] with uncaught errors reported to Sentry, when [sentryDsn]
/// is set.
///
/// `SentryFlutter.init` installs the hooks this app has never had: it wraps
/// [appRunner] in a guarded zone and takes over `FlutterError.onError` and
/// `PlatformDispatcher.instance.onError`. Without a DSN those stay at their
/// framework defaults, which print to the console — which is the whole of the
/// old behaviour, and all a developer at a terminal needs.
Future<void> runWithErrorReporting(AppRunner appRunner) async {
  if (!errorReportingEnabled) {
    await appRunner();
    return;
  }

  final metadata = resolveSentryMetadata(
    release: sentryRelease,
    commit: sentryCommit,
    environment: sentryEnvironment,
    isReleaseMode: kReleaseMode,
  );

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.release = metadata.release;
      options.dist = metadata.commit;
      options.environment = metadata.environment;

      // Errors only, for now. Tracing is what consumes a Sentry quota fastest,
      // and the performance work this project needs is already identified in
      // AUDIT.md by measurement rather than by sampling.
      options.tracesSampleRate = 0.0;

      // This app is a private viewing journal sitting behind Firebase Auth.
      // Both of these already default to false; they are spelled out because
      // turning either on would attach someone's watch history or e-mail
      // address to a crash report. (attachViewHierarchy, which the SDK still
      // marks experimental, must stay off for the same reason.)
      options.sendDefaultPii = false;
      options.attachScreenshot = false;

      options.beforeBreadcrumb = (breadcrumb, hint) {
        if (breadcrumb == null) return null;
        breadcrumb.message = redactSecrets(breadcrumb.message);
        final data = breadcrumb.data;
        if (data != null) {
          for (final key in data.keys) {
            final value = data[key];
            if (value is String) data[key] = redactSecrets(value);
          }
        }
        return breadcrumb;
      };

      options.beforeSend = (event, hint) {
        event.request?.url = redactSecrets(event.request?.url);
        event.request?.queryString = redactSecrets(event.request?.queryString);
        final message = event.message;
        if (message != null) {
          message.formatted = redactSecrets(message.formatted)!;
          message.template = redactSecrets(message.template);
        }
        for (final exception in event.exceptions ?? const <SentryException>[]) {
          exception.value = redactSecrets(exception.value);
        }
        return event;
      };
    },
    appRunner: () async {
      await Sentry.configureScope((scope) {
        scope.setTag('commit', metadata.commit);
        scope.setTag('deployment_environment', metadata.environment);
      });
      await appRunner();
    },
  );
}

/// Reports [error] to Sentry, or to the console when reporting is off.
///
/// For failures the app *handles* — it shows the user a retry screen and keeps
/// running — so no zone or framework hook would ever see them.
void reportError(Object error, StackTrace? stackTrace, {required String where}) {
  if (!errorReportingEnabled) {
    debugPrint('[$where] $error');
    return;
  }
  unawaited(
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) => scope.setTag('where', where),
    ),
  );
}

/// Query parameters that must never leave the device, regardless of which
/// field of an event they turn up in.
///
/// A TMDb key travels as `?api_key=...`, so it lands in request URLs, in the
/// text of a `DioException`, and in the HTTP breadcrumbs the SDK records
/// automatically. Everything this repo does about that key — the proxy, the
/// `--dart-define`, the deploy job that greps `main.dart.js` for it — assumes
/// the key is not published; a crash report quoting a failed request would
/// quietly undo all of it.
final RegExp _secretQueryParam = RegExp(
  r"""\b(api_key|access_token|token|auth)=[^&\s"']+""",
  caseSensitive: false,
);

/// Strips the values of [_secretQueryParam] out of [value], leaving the
/// parameter name so the shape of the failed request is still readable.
@visibleForTesting
String? redactSecrets(String? value) {
  if (value == null) return null;
  return value.replaceAllMapped(
    _secretQueryParam,
    (match) => '${match.group(1)}=REDACTED',
  );
}
