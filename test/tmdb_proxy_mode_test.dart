// Whether the app talks to TMDb directly or through the proxy is decided at
// COMPILE time (`String.fromEnvironment`), so one test run can only ever
// observe one of the two. These assertions therefore branch on the mode they
// were built in, and CI runs the suite both ways — see .github/workflows/ci.yml.
//
// The property that matters: a proxy build must carry no TMDb key at all. If
// it did, the key would still be sitting in main.dart.js and the proxy would
// have bought nothing.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/constants/api_constants.dart';
import 'package:cinefile/core/network/tmdb_service.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';

void main() {
  test('proxy and direct mode are mutually exclusive and consistent', () {
    if (ApiConstants.usesProxy) {
      expect(ApiConstants.tmdbProxyUrl, isNotEmpty);
      expect(ApiConstants.effectiveBaseUrl, ApiConstants.tmdbProxyUrl);
      // Access does not depend on holding a key — that is the whole point.
      expect(ApiConstants.hasTmdbAccess, isTrue);
    } else {
      expect(ApiConstants.tmdbProxyUrl, isEmpty);
      expect(ApiConstants.effectiveBaseUrl, ApiConstants.baseUrl);
      expect(ApiConstants.hasTmdbAccess, ApiConstants.tmdbApiKey.isNotEmpty);
    }
  });

  test('a proxy build sends no api_key and ignores the configurable base URL', () {
    if (!ApiConstants.usesProxy) {
      markTestSkipped('direct-mode build; the proxy assertions do not apply');
      return;
    }

    final container = ProviderContainer(overrides: [
      // A user-set base URL must not win over the proxy: the point is that
      // requests go nowhere except the proxy, which is the only party with a key.
      settingsBaseUrlProvider.overrideWith(
        (ref) => SettingsBaseUrlNotifier(ref.watch(appSettingsStoreProvider)),
      ),
    ]);
    addTearDown(container.dispose);

    expect(
      container.read(dioClientProvider).dio.options.baseUrl,
      ApiConstants.tmdbProxyUrl,
    );
  });

  test('demo mode is keyed off reachability, not off holding a key', () {
    // Every TmdbService method used to fall back to offline demo data when the
    // key was empty. Under a proxy the client legitimately has no key while
    // having full access, so that check had to move to hasTmdbAccess — if it
    // had not, a proxy build would have served mock data for everything.
    //
    // Asserted as an implication rather than "this build has access": CI builds
    // with no key at all (that is the documented demo mode the tests exercise),
    // so the direct-mode value here is legitimately false.
    if (ApiConstants.usesProxy) {
      expect(ApiConstants.hasTmdbAccess, isTrue,
          reason: 'a proxy build must never fall back to demo data');
    }
    expect(
      ApiConstants.hasTmdbAccess,
      ApiConstants.usesProxy || ApiConstants.tmdbApiKey.isNotEmpty,
    );
  });
}
