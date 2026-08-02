import 'api_key.dart';

class ApiConstants {
  ApiConstants._();

  static const String defaultBaseUrl = 'https://api.themoviedb.org/3';
  static String baseUrl = defaultBaseUrl;
  static const String imagePathOriginal = 'https://images.weserv.nl/?url=https://image.tmdb.org/t/p/original';
  // Backdrops are shown blurred/gradient-masked and full-bleed, never at
  // native detail — w780 looks identical in that context while being a
  // fraction of "original"'s decode/memory cost.
  static const String imagePathW780 = 'https://images.weserv.nl/?url=https://image.tmdb.org/t/p/w780';
  static const String imagePathW500 = 'https://images.weserv.nl/?url=https://image.tmdb.org/t/p/w500';
  static const String imagePathW185 = 'https://images.weserv.nl/?url=https://image.tmdb.org/t/p/w185';

  /// The TMDb key requests are signed with.
  ///
  /// Prefers `--dart-define=TMDB_API_KEY=...` over the git-ignored
  /// `api_key.dart`, so a build can be given a key without one ever touching
  /// the working tree. That matters most for the web release: TMDb takes the
  /// key as a *query parameter*, so whatever is compiled in ends up in
  /// `main.dart.js` and is served to every visitor. The web deploy therefore
  /// passes a separate, disposable key (see yayinla.bat) instead of the
  /// developer's own, and CI passes nothing at all.
  ///
  /// Still mutable: SettingsKeyNotifier overwrites it with the key the user
  /// entered in Settings, which is read back from the platform keystore.
  static String tmdbApiKey = _resolveTmdbApiKey();

  static String _resolveTmdbApiKey() {
    const keyFromEnv = String.fromEnvironment('TMDB_API_KEY');
    final trimmed = keyFromEnv.trim();
    if (trimmed.isNotEmpty && trimmed != 'none') {
      return trimmed;
    }
    return defaultTmdbApiKey;
  }

  /// Origin of a server-side TMDb proxy, e.g.
  /// `--dart-define=TMDB_PROXY_URL=https://cinefile-tmdb.<name>.workers.dev`.
  ///
  /// Empty by default, which keeps the direct-to-TMDb behaviour. When set, the
  /// app talks only to this origin and never carries a TMDb key at all — the
  /// proxy holds it (see tools/tmdb-proxy/). That is the only way to stop the
  /// key being published: TMDb takes it as a *query parameter*, so a key
  /// compiled into the web build is served to every visitor inside
  /// `main.dart.js`, and a key compiled into a native build can be read out of
  /// the APK. A proxy also gives the rate limiting the app has nowhere else.
  static const String tmdbProxyUrl = String.fromEnvironment('TMDB_PROXY_URL');

  static bool get usesProxy => tmdbProxyUrl.isNotEmpty;

  /// Whether TMDb can actually be reached — either this build holds a key, or a
  /// proxy holds one on its behalf.
  ///
  /// Every TmdbService method used to branch on `apiKey.isEmpty` to decide
  /// whether to fall back to offline demo data. Under a proxy the client
  /// legitimately has no key while still having full access, so that question
  /// has to be asked here instead.
  static bool get hasTmdbAccess => usesProxy || tmdbApiKey.isNotEmpty;

  /// Where TMDb requests should be sent by default.
  static String get effectiveBaseUrl => usesProxy ? tmdbProxyUrl : baseUrl;
}
