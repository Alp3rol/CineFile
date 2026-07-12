// Verifies MovieDetailScreen renders after being restructured for the
// premium redesign (3-up info cards, quick actions row, sticky bottom CTA)
// without runtime errors, with and without an existing watch record.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/movie_detail/presentation/movie_detail_provider.dart';
import 'package:filmdizi/features/movie_detail/presentation/movie_detail_screen.dart';

const _movieData = {
  'id': 1,
  'title': 'Test Movie',
  'original_title': 'Test Movie',
  'poster_path': null,
  'backdrop_path': null,
  'release_date': '2024-01-01',
  'runtime': 120,
  'overview': 'A test overview.',
  'genres': [
    {'name': 'Dram'}
  ],
  'credits': {
    'cast': [],
    'crew': [
      {'name': 'Test Director', 'job': 'Director'}
    ],
  },
};

Widget _wrap({required List<WatchRecordWithMovie> watchRecords}) {
  return ProviderScope(
    overrides: [
      movieDetailProvider((tmdbId: 1, isTv: false)).overrideWith((ref) async => _movieData),
      watchRecordsForMovieProvider((tmdbId: 1, isTv: false))
          .overrideWith((ref) => Stream.value(watchRecords.map((w) => w.record).toList())),
      favoriteMovieIdsProvider.overrideWith((ref) => Stream.value(<MovieKey>{})),
      // Reads from Firestore (via authStateProvider) in the real app —
      // overridden directly so this render test doesn't need a Firebase
      // test harness.
      movieSettingsProvider((tmdbId: 1, isTv: false)).overrideWith((ref) => Stream.value(null)),
    ],
    child: const MaterialApp(home: MovieDetailScreen(tmdbId: 1)),
  );
}

void main() {
  testWidgets('renders 3-up info cards, quick actions and sticky CTA with no watch record', (tester) async {
    await tester.pumpWidget(_wrap(watchRecords: const []));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Test Movie'), findsOneWidget);
    expect(find.text('Puanım'), findsOneWidget);
    expect(find.text('Yönetmen'), findsOneWidget);
    expect(find.text('Ortam'), findsOneWidget);
    expect(find.text('Günlüğe Ekle'), findsOneWidget);
    expect(find.text('Listeye Ekle'), findsOneWidget);
    expect(find.text('Paylaş'), findsOneWidget);
    expect(find.text('Yeni İzleme Kaydı Ekle'), findsOneWidget);
  });

  testWidgets('shows latest watch rating and place when a record exists', (tester) async {
    final record = WatchRecord(
      id: 1,
      movieId: 1,
      isTv: false,
      watchDate: DateTime(2026, 1, 1),
      watchPlace: 'Sinemada',
      rating: 9,
      watchNumber: 1,
      createdAt: DateTime.now(),
      episodeCount: 1,
    );
    await tester.pumpWidget(_wrap(watchRecords: [
      WatchRecordWithMovie(record, Movie(tmdbId: 1, title: 'Test Movie', isTv: false, createdAt: DateTime.now())),
    ]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('9.0'), findsWidgets);
    expect(find.text('Sinemada'), findsWidgets);
  });
}
