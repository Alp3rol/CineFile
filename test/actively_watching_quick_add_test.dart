// Verifies the "Aktif İzliyorum" quick-add flow: activelyWatchingProvider
// surfaces shows with UserMovieSettings.isActivelyWatching, the
// ActivelyWatchingRow renders them with a quick-add "+" button, and
// confirming the quick episode dialog advances lastWatchedEpisode (and
// removes the show from the active list once the last episode is reached).
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/core/widgets/actively_watching_row.dart';

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

  Future<void> seedActivelyWatchingShow({required int tmdbId, required int totalEpisodes, required int lastWatchedEpisode}) async {
    await db.into(db.movies).insert(
          MoviesCompanion.insert(
            tmdbId: tmdbId,
            title: 'Aktif Dizi',
            isTv: const Value(true),
            totalEpisodes: Value(totalEpisodes),
          ),
        );
    await db.into(db.userMovieSettings).insert(
          UserMovieSettingsCompanion.insert(
            tmdbId: tmdbId,
            isTv: const Value(true),
            isActivelyWatching: const Value(true),
            lastWatchedEpisode: Value(lastWatchedEpisode),
          ),
        );
  }

  test('activelyWatchingProvider only returns shows marked isActivelyWatching', () async {
    await seedActivelyWatchingShow(tmdbId: 1, totalEpisodes: 10, lastWatchedEpisode: 3);
    // A finished show (isActivelyWatching false) must not show up.
    await db.into(db.movies).insert(
          MoviesCompanion.insert(tmdbId: 2, title: 'Bitmiş Dizi', isTv: const Value(true), totalEpisodes: const Value(5)),
        );
    await db.into(db.userMovieSettings).insert(
          UserMovieSettingsCompanion.insert(
              tmdbId: 2, isTv: const Value(true), isActivelyWatching: const Value(false), lastWatchedEpisode: const Value(5)),
        );

    final list = await container.read(activelyWatchingProvider.future);
    expect(list.length, 1);
    expect(list.single.movie.tmdbId, 1);
    expect(list.single.setting.lastWatchedEpisode, 3);
  });

  testWidgets('quick-add dialog logs the next episode and auto-completes on the last one', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // total=2, already at episode 1 — one quick-add should finish the show.
    await seedActivelyWatchingShow(tmdbId: 5, totalEpisodes: 2, lastWatchedEpisode: 1);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: ActivelyWatchingRow()))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bölüm 2 / 2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Bölüm 2 / 2 izlendi olarak kaydedilecek.'), findsOneWidget);

    await tester.tap(find.text('Bölümü Ekle'));
    await tester.pumpAndSettle();

    final setting = await (db.select(db.userMovieSettings)..where((t) => t.tmdbId.equals(5))).getSingle();
    expect(setting.lastWatchedEpisode, 2);
    expect(setting.isActivelyWatching, isFalse);

    final records = await db.select(db.watchRecords).get();
    expect(records.single.episodeCount, 1);

    // The show is done, so the row (and dialog trigger) is gone now.
    expect(find.text('Aktif Dizi'), findsNothing);
  });
}
