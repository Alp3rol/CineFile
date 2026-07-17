// Verifies InsightsScreen and its extracted card/section widgets
// (contribution_heatmap.dart, insights_charts.dart, insights_lists.dart,
// insights_misc_cards.dart) still render together without runtime errors
// after splitting the former 1526-line god widget file.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/insights/presentation/insights_screen.dart';

WatchRecordWithMovie _record(int id, {String? director, String? genres}) {
  final movie = Movie(
    tmdbId: id,
    title: 'Movie $id',
    isTv: false,
    genres: genres ?? 'Dram',
    director: director ?? 'Christopher Nolan',
    actors: 'Actor A, Actor B',
    runtime: 120,
    createdAt: DateTime.now(),
  );
  final record = WatchRecord(
    id: id,
    movieId: id,
    isTv: false,
    watchDate: DateTime.now().subtract(Duration(days: id)),
    rating: 8,
    watchNumber: 1,
    tags: 'gece',
    createdAt: DateTime.now(),
    episodeCount: 1,
    isPublic: false,
  );
  return WatchRecordWithMovie(record, movie);
}

void main() {
  testWidgets('InsightsScreen renders all extracted sections with data', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final records = List.generate(5, (i) => _record(i + 1));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allWatchRecordsProvider.overrideWith((ref) => Stream.value(records)),
          allMovieSettingsProvider.overrideWith((ref) => Stream.value(const {})),
        ],
        child: const MaterialApp(home: Scaffold(body: InsightsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Toplam İzleme'), findsOneWidget);
    expect(find.text('🏆 Başarılar & Rozetler'), findsOneWidget);
  });

  testWidgets('InsightsScreen shows empty state with no records', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allWatchRecordsProvider.overrideWith((ref) => Stream.value(const [])),
          allMovieSettingsProvider.overrideWith((ref) => Stream.value(const {})),
        ],
        child: const MaterialApp(home: Scaffold(body: InsightsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Yetersiz Veri'), findsOneWidget);
  });
}
