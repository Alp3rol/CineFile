// Verifies ContributionHeatmap's year navigation: it defaults to the
// current year, the ‹ chevron switches to a prior year with data and
// recomputes the year total, and navigation stops at the earliest year
// that actually has watch records (no scrolling into empty years).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/insights/presentation/insights_provider.dart';
import 'package:filmdizi/features/insights/presentation/widgets/contribution_heatmap.dart';

Movie _movie(int id) {
  return Movie(tmdbId: id, title: 'Movie $id', isTv: false, createdAt: DateTime.now());
}

WatchRecordWithMovie _record(int id, Movie movie, DateTime watchDate) {
  final record = WatchRecord(
    id: id,
    movieId: movie.tmdbId,
    isTv: false,
    watchDate: watchDate,
    rating: 8,
    watchNumber: 1,
    createdAt: DateTime.now(),
    episodeCount: 1,
  );
  return WatchRecordWithMovie(record, movie);
}

Widget _harness() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Consumer(
          builder: (context, ref, _) {
            final insights = ref.watch(insightsProvider);
            if (insights == null) return const SizedBox();
            return ContributionHeatmap(insights: insights);
          },
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('defaults to the current year and navigating back shows the prior year with data', (tester) async {
    final now = DateTime.now();
    final movieA = _movie(1);
    final movieB = _movie(2);

    final records = [
      _record(1, movieA, now), // this year
      _record(2, movieB, DateTime(now.year - 1, 6, 15)), // one year back
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allWatchRecordsProvider.overrideWith((ref) => Stream.value(records)),
        ],
        child: _harness(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('${now.year}'), findsOneWidget);
    expect(find.text('${now.year} içinde 1 İzleme'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('${now.year - 1}'), findsOneWidget);
    expect(find.text('${now.year - 1} içinde 1 İzleme'), findsOneWidget);

    // Already at the earliest year with data — the back chevron is disabled.
    final backButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left_rounded));
    expect(backButton.onPressed, isNull);
  });

  testWidgets('the forward chevron is disabled on the current year (no future years)', (tester) async {
    final now = DateTime.now();
    final records = [_record(1, _movie(1), now)];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allWatchRecordsProvider.overrideWith((ref) => Stream.value(records)),
        ],
        child: _harness(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final forwardButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right_rounded));
    expect(forwardButton.onPressed, isNull);
  });
}
