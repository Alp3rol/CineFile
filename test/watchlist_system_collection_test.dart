import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/features/journal/presentation/widgets/custom_lists_tab.dart';
import 'package:cinefile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the built-in Watchlist even without custom collections', (
    tester,
  ) async {
    final movie = Movie(
      tmdbId: 42,
      title: 'Test Filmi',
      posterPath: '/poster.jpg',
      releaseYear: 2026,
      isTv: false,
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customListsProvider.overrideWith((ref) => Stream.value([])),
          allWatchRecordsProvider.overrideWith((ref) => Stream.value([])),
          watchlistMoviesProvider.overrideWith((ref) => Stream.value([movie])),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CustomListsTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('İzleme Listem'), findsOneWidget);
    expect(find.text('1 yapım'), findsOneWidget);
    expect(find.text('Hiç Koleksiyonunuz Yok'), findsOneWidget);

    await tester.tap(find.text('İzleme Listem'));
    await tester.pumpAndSettle();

    expect(find.text('Test Filmi'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_remove_rounded), findsOneWidget);
  });
}
