// Crash reports are the one place where a TMDb key could leave the device
// after all the work done to keep it out of the bundle: a failed request's URL
// shows up in the exception text and in the HTTP breadcrumbs the SDK records on
// its own. These pin the scrubbing, and pin that a build without a DSN behaves
// exactly as it did before Sentry existed.
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/observability/error_reporting.dart';

void main() {
  group('Sentry release metadata', () {
    test('keeps release, commit and environment supplied by deployment', () {
      expect(
        resolveSentryMetadata(
          release: 'cinefile@1.7.2+12',
          commit: 'd735059',
          environment: 'production',
          isReleaseMode: true,
        ),
        (
          release: 'cinefile@1.7.2+12',
          commit: 'd735059',
          environment: 'production',
        ),
      );
    });

    test('uses explicit, searchable local fallbacks', () {
      expect(
        resolveSentryMetadata(
          release: '',
          commit: '',
          environment: '',
          isReleaseMode: false,
        ),
        (
          release: 'cinefile@development',
          commit: 'local',
          environment: 'development',
        ),
      );
    });
  });

  group('redactSecrets', () {
    test('strips a TMDb key out of a request URL', () {
      expect(
        redactSecrets(
          'https://api.themoviedb.org/3/movie/550?api_key=0123456789abcdef0123456789abcdef&language=tr-TR',
        ),
        'https://api.themoviedb.org/3/movie/550?api_key=REDACTED&language=tr-TR',
      );
    });

    test('keeps the parameter name so the request stays recognisable', () {
      expect(redactSecrets('?api_key=abc'), '?api_key=REDACTED');
    });

    test('strips a key embedded in exception text', () {
      expect(
        redactSecrets(
          'DioException: connection error to /3/search/movie?query=dune&api_key=deadbeef',
        ),
        'DioException: connection error to /3/search/movie?query=dune&api_key=REDACTED',
      );
    });

    test('strips token-shaped parameters too', () {
      expect(
        redactSecrets('https://x/y?access_token=aaa&token=bbb&auth=ccc'),
        'https://x/y?access_token=REDACTED&token=REDACTED&auth=REDACTED',
      );
    });

    test('is case insensitive', () {
      expect(redactSecrets('?API_KEY=abc'), '?API_KEY=REDACTED');
    });

    test('leaves innocent parameters alone', () {
      expect(
        redactSecrets('https://api.themoviedb.org/3/movie/550?language=tr-TR'),
        'https://api.themoviedb.org/3/movie/550?language=tr-TR',
      );
    });

    test('passes null through', () {
      expect(redactSecrets(null), isNull);
    });
  });

  group('without a DSN', () {
    // No --dart-define reaches `flutter test`, so this is the state every test
    // run and every local `flutter run` is in.
    test('reporting is off', () {
      expect(errorReportingEnabled, isFalse);
      expect(sentryDsn, isEmpty);
    });

    test('runWithErrorReporting still runs the app', () async {
      var ran = false;
      await runWithErrorReporting(() async {
        ran = true;
      });
      expect(ran, isTrue);
    });

    test('reportError does not throw when there is nowhere to report', () {
      expect(
        () => reportError(Exception('boom'), StackTrace.current, where: 'test'),
        returnsNormally,
      );
    });
  });
}
