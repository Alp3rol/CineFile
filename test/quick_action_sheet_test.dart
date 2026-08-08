import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/core/services/app_settings_store.dart';
import 'package:cinefile/core/widgets/movie_quick_action_sheet.dart';
import 'package:cinefile/core/widgets/poster_grid.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'package:cinefile/l10n/app_localizations.dart';

import 'support/network_image_mock.dart';

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  final sampleMovie = {
    'id': 157336,
    'title': 'Interstellar',
    'media_type': 'movie',
    'poster_path': '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
    'release_date': '2014-11-05',
  };

  testWidgets('MovieQuickActionSheet renders title and quick actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
          movieSettingsSnapshotProvider((tmdbId: 157336, isTv: false)).overrideWithValue(const AsyncValue.data(null)),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MovieQuickActionSheet(movieData: sampleMovie),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Interstellar'), findsOneWidget);
    expect(find.text('İzleme Kaydı Ekle'), findsOneWidget);
    expect(find.text('Favorilere Ekle'), findsOneWidget);
    expect(find.text('Detayları Gör'), findsOneWidget);
  });

  testWidgets('PosterGrid long press opens MovieQuickActionSheet', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
          movieSettingsSnapshotProvider((tmdbId: 157336, isTv: false)).overrideWithValue(const AsyncValue.data(null)),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PosterGrid(items: [sampleMovie]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Long press on Interstellar poster
    await tester.longPress(find.text('Interstellar'));
    await tester.pumpAndSettle();

    expect(find.byType(MovieQuickActionSheet), findsOneWidget);
    expect(find.text('İzleme Kaydı Ekle'), findsOneWidget);
  });
}
