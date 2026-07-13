import 'api_key.dart';

class ApiConstants {
  ApiConstants._();

  static String baseUrl = 'https://api.themoviedb.org/3';
  static const String imagePathOriginal = 'https://images.weserv.nl/?url=https://image.tmdb.org/t/p/original';
  // Backdrops are shown blurred/gradient-masked and full-bleed, never at
  // native detail — w780 looks identical in that context while being a
  // fraction of "original"'s decode/memory cost.
  static const String imagePathW780 = 'https://images.weserv.nl/?url=https://image.tmdb.org/t/p/w780';
  static const String imagePathW500 = 'https://images.weserv.nl/?url=https://image.tmdb.org/t/p/w500';
  static const String imagePathW185 = 'https://images.weserv.nl/?url=https://image.tmdb.org/t/p/w185';

  // Automatically read from the Git-ignored config file
  static String tmdbApiKey = defaultTmdbApiKey; 
}
