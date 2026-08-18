import 'dart:ui' show Locale;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../l10n/l10n_lookup.dart';
import 'dio_client.dart';
import 'tmdb_exception.dart';
import '../../features/settings/presentation/settings_provider.dart';

part 'tmdb_search_resource.dart';
part 'tmdb_details_resource.dart';
part 'tmdb_people_resource.dart';
part 'tmdb_season_resource.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  // Behind a proxy the user-configurable base URL is ignored: the whole point
  // is that requests go nowhere except the proxy, which is the only party
  // holding a TMDb key.
  final baseUrl = ApiConstants.usesProxy
      ? ApiConstants.tmdbProxyUrl
      : ref.watch(settingsBaseUrlProvider);
  return DioClient(baseUrl: baseUrl);
});

/// TMDb's `language` values for the languages the app ships.
const _tmdbLanguageTags = {'tr': 'tr-TR', 'en': 'en-US'};

/// The TMDb `language` query value matching [locale] (null = follow device).
String tmdbLanguageTag(Locale? locale) =>
    _tmdbLanguageTags[resolveAppLocale(locale).languageCode] ??
    _englishLanguageTag;

const _englishLanguageTag = 'en-US';

/// Rebuilt when the user changes language, so every subsequent request asks
/// TMDb for titles, overviews and genre names in the new one. Responses are
/// cached per-URL and `language` is a query parameter, so the two languages'
/// caches separate on their own rather than one poisoning the other.
final tmdbServiceProvider = Provider<TmdbService>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return TmdbService(dio, language: tmdbLanguageTag(ref.watch(localeProvider)));
});

class _TmdbCore {
  final Dio _dio;

  /// The `language` sent when a call doesn't override it. Every method takes an
  /// optional `language` for the rare case a specific request needs a
  /// different one (see the English biography fallback in [getPersonDetails]);
  /// inside those methods the parameter shadows this field, hence
  /// `language ?? this.language`.
  final String language;

  _TmdbCore(this._dio, {this.language = 'tr-TR'});

  /// The key appended to every request.
  ///
  /// Empty when the build talks to a proxy — the proxy strips whatever arrives
  /// and appends its own key, so an empty `api_key` parameter travelling over
  /// the wire is harmless and keeps this class free of proxy branching.
  String get _apiKey => ApiConstants.usesProxy ? '' : ApiConstants.tmdbApiKey;

  static final List<Map<String, dynamic>> _mockMovies = [
    {
      'id': 157336,
      'title': 'Interstellar',
      'original_title': 'Interstellar',
      'poster_path': '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      'release_date': '2014-11-05',
      'vote_average': 8.4,
      'genre_ids': [878, 18, 12],
      'overview': 'Mankind was born on Earth. It was never meant to die here.',
    },
    {
      'id': 27205,
      'title': 'Inception',
      'original_title': 'Inception',
      'poster_path': '/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
      'release_date': '2010-07-15',
      'vote_average': 8.3,
      'genre_ids': [878, 18, 28, 12, 53],
      'overview':
          'Cobb, a skilled thief who commits corporate espionage by infiltrating the subconscious of his targets.',
    },
    {
      'id': 693134,
      'title': 'Dune: Part Two',
      'original_title': 'Dune: Part Two',
      'poster_path': '/tihf8Trht9zP3scmUQfvGlAY9FU.jpg',
      'release_date': '2024-02-27',
      'vote_average': 8.3,
      'genre_ids': [878, 12, 28],
      'overview':
          'Follow the mythic journey of Paul Atreides as he unites with Chani and the Fremen.',
    },
    {
      'id': 155,
      'title': 'The Dark Knight',
      'original_title': 'The Dark Knight',
      'poster_path': '/7IPCEr7ifdH5CtU97QG7XgAAtOp.jpg',
      'release_date': '2008-07-16',
      'vote_average': 8.5,
      'genre_ids': [28, 80, 18, 53],
      'overview': 'Batman raises the stakes in his war on crime.',
    },
    {
      'id': 872585,
      'title': 'Oppenheimer',
      'original_title': 'Oppenheimer',
      'poster_path': '/ptpr0kGAckfQkJeJIt8st5dglvd.jpg',
      'release_date': '2023-07-19',
      'vote_average': 8.1,
      'genre_ids': [18, 36],
      'overview':
          'The story of J. Robert Oppenheimer and the atomic bomb project.',
    },
    {
      'id': 569094,
      'title': 'Spider-Man: Across the Spider-Verse',
      'original_title': 'Spider-Man: Across the Spider-Verse',
      'poster_path': '/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
      'release_date': '2023-05-31',
      'vote_average': 8.4,
      'genre_ids': [16, 28, 12, 878],
      'overview': 'Miles Morales catapults across the Multiverse.',
    },
  ];
}

class TmdbService extends _TmdbCore
    with
        _TmdbSearchResource,
        _TmdbDetailsResource,
        _TmdbPeopleResource,
        _TmdbSeasonResource {
  TmdbService(super.dio, {super.language});

  List<Map<String, dynamic>> get mockMovies =>
      List<Map<String, dynamic>>.from(_TmdbCore._mockMovies);
}
