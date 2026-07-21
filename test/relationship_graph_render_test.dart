// Verifies RelationshipGraphScreen renders its canvas/overlays with real data
// and shows the empty state when nothing connects — without runtime errors.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/relationship_graph/presentation/relationship_graph_screen.dart';

WatchRecordWithMovie _rec(int id, String title, {String? actors}) {
  final movie = Movie(
    tmdbId: id,
    title: title,
    isTv: false,
    actors: actors,
    runtime: 100,
    createdAt: DateTime(2024, 1, 1),
  );
  final record = WatchRecord(
    id: id,
    movieId: id,
    isTv: false,
    watchDate: DateTime(2024, 1, id),
    rating: 8,
    watchNumber: 1,
    createdAt: DateTime(2024, 1, 1),
    episodeCount: 1,
    isPublic: false,
  );
  return WatchRecordWithMovie(record, movie);
}

Widget _app(List<WatchRecordWithMovie> records) {
  return ProviderScope(
    overrides: [
      allWatchRecordsProvider.overrideWith((ref) => Stream.value(records)),
      allMovieSettingsProvider.overrideWith((ref) => Stream.value(const {})),
    ],
    child: const MaterialApp(home: RelationshipGraphScreen()),
  );
}

void main() {
  testWidgets('renders connected graph with title nodes', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app([
      _rec(1, 'Son Yaz', actors: 'Ali Atay, Alperen Duymaz'),
      _rec(2, 'Doğanın Kanunu', actors: 'Ali Atay, Hakan Yılmaz'),
      _rec(3, 'Yahşi Cazibe', actors: 'Hakan Yılmaz'),
    ]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Toolbar + at least one title node label present.
    expect(find.text('İlişki Ağı'), findsOneWidget);
    expect(find.text('Son Yaz'), findsWidgets);
  });

  testWidgets('shows empty state when nothing connects', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app([
      _rec(1, 'A', actors: 'Only Me'),
      _rec(2, 'B', actors: 'Someone Else'),
    ]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('İlişki Ağı henüz boş'), findsOneWidget);
  });

  testWidgets('shows empty state with no records at all', (tester) async {
    await tester.pumpWidget(_app(const []));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('İlişki Ağı henüz boş'), findsOneWidget);
  });
}
