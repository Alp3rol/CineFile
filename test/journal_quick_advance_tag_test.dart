// Verifies the compact "Bölüm X/Y +" tag added to the Journal table/card
// views (replacing the earlier full-width "Aktif İzlediklerin" row per user
// feedback): it only appears on an actively-watched show's latest record,
// and tapping "+" logs the next episode immediately with no dialog/screen.
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/journal/presentation/widgets/journal_table_list.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  testWidgets('quick-advance tag logs the next episode with a single tap, no dialog', (tester) async {
    await db.into(db.movies).insert(
          MoviesCompanion.insert(tmdbId: 700, title: 'Son Yaz', isTv: const Value(true), totalEpisodes: const Value(26)),
        );
    await db.into(db.watchRecords).insert(
          WatchRecordsCompanion.insert(
              movieId: 700, isTv: const Value(true), watchDate: DateTime(2026, 7, 9), rating: 7, watchNumber: 4, episodeCount: const Value(1)),
        );
    await db.into(db.userMovieSettings).insert(
          UserMovieSettingsCompanion.insert(
              tmdbId: 700, isTv: const Value(true), isActivelyWatching: const Value(true), lastWatchedEpisode: const Value(4)),
        );

    final items = await container.read(allWatchRecordsProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: JournalRecordsTable(
              items: items,
              onReorder: (list, oldIndex, newIndex) {},
              onUpdateRanking: (_) async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('4/26'), findsOneWidget);

    await tester.tap(find.text('4/26'));
    await tester.pumpAndSettle();

    // No dialog/screen appears — this must not have navigated anywhere.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(JournalRecordsTable), findsOneWidget);

    final setting = await (db.select(db.userMovieSettings)..where((t) => t.tmdbId.equals(700))).getSingle();
    expect(setting.lastWatchedEpisode, 5);
    expect(setting.isActivelyWatching, isTrue);

    final records = await db.select(db.watchRecords).get();
    expect(records.length, 2);
    expect(records.last.rating, 7); // carried forward from the previous record
  });
}
