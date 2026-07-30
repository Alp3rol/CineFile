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
  static String tmdbApiKey = const String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: defaultTmdbApiKey,
  );
}
