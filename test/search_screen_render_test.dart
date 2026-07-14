// Verifies the Keşfet (Discover) empty-query state shows a trend/popular/
// top-rated grid (with Kategori/Zaman/Tür filter chips) instead of the
// static placeholder, switches data source on category/time changes,
// filters client-side (no extra network calls) on media-type changes, and
// falls back gracefully to the static placeholder on load error.
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/network/tmdb_service.dart';
import 'package:filmdizi/features/search/presentation/search_provider.dart';
import 'package:filmdizi/features/search/presentation/trending_provider.dart';
import 'package:filmdizi/features/search/presentation/widgets/search_results_view.dart';

Map<String, dynamic> _movie(int id, String title) => {
      'id': id,
      'title': title,
      'poster_path': '/$id.jpg',
      'release_date': '2026-01-01',
      'media_type': 'movie',
    };

Map<String, dynamic> _tv(int id, String title) => {
      'id': id,
      'title': title,
      'poster_path': '/$id.jpg',
      'release_date': '2026-01-01',
      'media_type': 'tv',
    };

// TmdbService's network methods aren't private/final, so a fake subclass can
// override them directly instead of needing a mocking package.
class _FakeTmdbService extends TmdbService {
  _FakeTmdbService({this.tvEmpty = false}) : super(Dio());

  final bool tvEmpty;
  int trendWeekCalls = 0;
  int trendTodayCalls = 0;
  int popularCalls = 0;
  int topRatedCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> getTrendingMoviesThisWeek({String language = 'tr-TR'}) async {
    trendWeekCalls++;
    return [_movie(1, 'Trend Film Hafta')];
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingTvShowsThisWeek({String language = 'tr-TR'}) async {
    return tvEmpty ? [] : [_tv(2, 'Trend Dizi Hafta')];
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingMoviesToday({String language = 'tr-TR'}) async {
    trendTodayCalls++;
    return [_movie(3, 'Trend Film Bugün')];
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingTvShowsToday({String language = 'tr-TR'}) async {
    return tvEmpty ? [] : [_tv(4, 'Trend Dizi Bugün')];
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularMovies({int page = 1, String language = 'tr-TR'}) async {
    popularCalls++;
    return [_movie(5, 'Popüler Film')];
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularTvShows({int page = 1, String language = 'tr-TR'}) async {
    return tvEmpty ? [] : [_tv(6, 'Popüler Dizi')];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopRatedMovies({int page = 1, String language = 'tr-TR'}) async {
    topRatedCalls++;
    return [_movie(7, 'En Çok Oy Alan Film')];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopRatedTvShows({int page = 1, String language = 'tr-TR'}) async {
    return tvEmpty ? [] : [_tv(8, 'En Çok Oy Alan Dizi')];
  }
}

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(
        body: SearchResultsView(
          state: SearchState.initial(),
          results: const [],
          scrollController: ScrollController(),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows trending grid with heading when query is empty and trending data loads', (tester) async {
    final fakeItems = [
      {
        'id': 101,
        'title': 'Trend Film',
        'poster_path': '/trend.jpg',
        'release_date': '2026-01-01',
        'media_type': 'movie',
      },
    ];

    await tester.pumpWidget(_wrap([
      trendingProvider.overrideWith((ref) async => fakeItems),
    ]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Bu Hafta Trend Film/Dizileri'), findsOneWidget);
    expect(find.text('Trend Film'), findsOneWidget);
  });

  testWidgets('falls back to static empty state when trending fetch errors', (tester) async {
    await tester.pumpWidget(_wrap([
      trendingProvider.overrideWith((ref) async => throw Exception('network')),
    ]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Keşfetmeye Başlayın'), findsOneWidget);
  });

  testWidgets('switching category fetches a different data source and updates the heading', (tester) async {
    final fake = _FakeTmdbService();

    await tester.pumpWidget(_wrap([
      tmdbServiceProvider.overrideWithValue(fake),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Bu Hafta Trend Film/Dizileri'), findsOneWidget);
    expect(find.text('Trend Film Hafta'), findsOneWidget);
    expect(find.text('Bu Hafta'), findsOneWidget);
    expect(find.text('Bugün'), findsOneWidget);
    expect(fake.trendWeekCalls, 1);
    expect(fake.popularCalls, 0);

    await tester.tap(find.text('Popüler'));
    await tester.pumpAndSettle();

    expect(find.text('Popüler Film/Dizileri'), findsOneWidget);
    expect(find.text('Popüler Film'), findsOneWidget);
    expect(fake.popularCalls, 1);
    // Zaman chips only make sense for Trend; they disappear once Popüler is selected.
    expect(find.text('Bu Hafta'), findsNothing);
    expect(find.text('Bugün'), findsNothing);
  });

  testWidgets('media-type filter narrows results client-side without any new network calls', (tester) async {
    final fake = _FakeTmdbService();

    await tester.pumpWidget(_wrap([
      tmdbServiceProvider.overrideWithValue(fake),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Trend Film Hafta'), findsOneWidget);
    expect(find.text('Trend Dizi Hafta'), findsOneWidget);
    expect(fake.trendWeekCalls, 1);

    await tester.tap(find.text('Film'));
    await tester.pumpAndSettle();

    expect(find.text('Trend Film Hafta'), findsOneWidget);
    expect(find.text('Trend Dizi Hafta'), findsNothing);
    // Tür is a client-side filter — no re-fetch should happen.
    expect(fake.trendWeekCalls, 1);
  });

  testWidgets('shows an inline empty state (chips still visible) when the media filter matches nothing', (tester) async {
    final fake = _FakeTmdbService(tvEmpty: true);

    await tester.pumpWidget(_wrap([
      tmdbServiceProvider.overrideWithValue(fake),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dizi'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Bu kategoride dizi bulunamadı'), findsOneWidget);
    // Chip rows and heading stay visible even though the grid is empty.
    expect(find.text('Trend'), findsOneWidget);
    expect(find.text('Bu Hafta Trend Film/Dizileri'), findsOneWidget);
  });
}
