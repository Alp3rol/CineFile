// Covers the TMDb request language following the user's chosen language.
//
// Every TmdbService method used to hardcode `language = 'tr-TR'`, so switching
// the UI to English still returned Turkish titles, overviews and genre names.
// The language now comes from the service instance, which the provider rebuilds
// whenever localeProvider changes.
import 'dart:ui' show Locale;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/constants/api_constants.dart';
import 'package:cinefile/core/network/tmdb_service.dart';

/// Records the query parameters of every request instead of hitting TMDb.
class _RecordingInterceptor extends Interceptor {
  final List<Map<String, dynamic>> requests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add({'path': options.path, ...options.queryParameters});
    handler.resolve(Response(
      requestOptions: options,
      statusCode: 200,
      data: {'results': <dynamic>[], 'id': 1, 'biography': 'A biography.'},
    ));
  }
}

void main() {
  late Dio dio;
  late _RecordingInterceptor recorder;

  setUp(() {
    // A non-empty key: with an empty one the service short-circuits to its
    // offline demo data and never issues a request.
    ApiConstants.tmdbApiKey = 'test-key';
    recorder = _RecordingInterceptor();
    dio = Dio()..interceptors.add(recorder);
  });

  tearDown(() => ApiConstants.tmdbApiKey = '');

  test('sends the service language on search, discovery and detail calls', () async {
    final service = TmdbService(dio, language: 'en-US');

    await service.searchMovies('dune');
    await service.getPopularMovies();
    await service.getTrendingMoviesThisWeek();
    await service.getTopRatedTvShows();

    expect(recorder.requests, hasLength(4));
    for (final request in recorder.requests) {
      expect(request['language'], 'en-US', reason: 'for ${request['path']}');
    }
  });

  test('a per-call language overrides the service default', () async {
    final service = TmdbService(dio, language: 'tr-TR');

    await service.searchMovies('dune', language: 'en-US');

    expect(recorder.requests.single['language'], 'en-US');
  });

  test('maps the app locale to a TMDb language tag', () {
    expect(tmdbLanguageTag(const Locale('tr')), 'tr-TR');
    expect(tmdbLanguageTag(const Locale('en')), 'en-US');
    // null = follow the device; the test binding reports en-US.
    expect(tmdbLanguageTag(null), 'en-US');
  });

  test('does not re-request an English biography when already asking in English', () async {
    final service = TmdbService(dio, language: 'en-US');

    await service.getPersonDetails(1);

    // One request, not two: the fallback used to be keyed on 'tr-TR' being
    // requested, and now triggers for any non-English language with an empty
    // biography — English itself must never loop back on itself.
    expect(recorder.requests, hasLength(1));
  });
}
