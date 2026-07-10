// Verifies JournalScreen and its month-grouped card list (journal_record_list.dart)
// render and interact correctly after replacing the former sortable table +
// drag-to-reorder list with the simplified premium-design card list.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/journal/presentation/journal_screen.dart';

WatchRecordWithMovie _record(int id, {String watchPlace = 'Sinema', DateTime? watchDate}) {
  final movie = Movie(
    tmdbId: id,
    title: 'Movie $id',
    isTv: false,
    genres: 'Dram',
    director: 'Christopher Nolan',
    runtime: 120,
    createdAt: DateTime.now(),
  );
  final record = WatchRecord(
    id: id,
    movieId: id,
    isTv: false,
    watchDate: watchDate ?? DateTime(2026, 3, id),
    watchPlace: watchPlace,
    rating: 8,
    watchNumber: 1,
    createdAt: DateTime.now(),
    episodeCount: 1,
  );
  return WatchRecordWithMovie(record, movie);
}

void main() {
  testWidgets('JournalScreen renders records grouped by month, supports search and filter, opens preview dialog',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final records = [
      _record(1, watchDate: DateTime(2026, 3, 5)),
      _record(2, watchPlace: 'Netflix', watchDate: DateTime(2026, 2, 20)),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allWatchRecordsProvider.overrideWith((ref) => Stream.value(records)),
          favoriteMovieIdsProvider.overrideWith((ref) => Stream.value(<MovieKey>{})),
          customListsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(home: JournalScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('Movie 2'), findsOneWidget);
    // Month group headers (newest month first).
    expect(find.text('MART 2026'), findsOneWidget);
    expect(find.text('ŞUBAT 2026'), findsOneWidget);

    // Search filters the list: tap the search toggle icon first, then type.
    await tester.tap(find.byIcon(Icons.search_rounded).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Movie 2');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Movie 1'), findsNothing);
    expect(find.text('Movie 2'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    // Long-press opens the ranking preview dialog.
    await tester.longPress(find.text('Movie 1'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Favori Sıram: '), findsOneWidget);
    Navigator.of(tester.element(find.text('Kapat'))).pop();
    await tester.pumpAndSettle();

    // Switch to the table view: column headers appear (drag handle removed in v1.0.4).
    await tester.tap(find.byIcon(Icons.table_rows_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Film Adı'), findsOneWidget);
    expect(find.text('Puanım'), findsOneWidget);
    expect(find.text('MART 2026'), findsNothing);

    // Switch back to the card view.
    await tester.tap(find.byIcon(Icons.view_agenda_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('MART 2026'), findsOneWidget);
    expect(find.text('Film Adı'), findsNothing);
  });
}
