import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/core/network/tmdb_service.dart';
import 'package:cinefile/core/services/app_settings_store.dart';
import 'package:cinefile/core/widgets/poster_grid.dart';
import 'package:cinefile/features/main_shell.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'package:cinefile/l10n/app_localizations.dart';

import 'support/network_image_mock.dart';

class FakeTmdbService extends TmdbService {
  FakeTmdbService() : super(Dio());

  @override
  Future<List<Map<String, dynamic>>> getTrendingMoviesThisWeek({String? language}) async => [];

  @override
  Future<List<Map<String, dynamic>>> searchMovies(String query, {int page = 1, String? language}) async => [];
}

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  final sampleMovie = {
    'id': 157336,
    'title': 'Interstellar',
    'media_type': 'movie',
    'poster_path': '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
    'release_date': '2014-11-05',
  };

  testWidgets('PosterGrid items include accessibility button and label semantics', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PosterGrid(items: [sampleMovie]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp(r'Interstellar')), findsOneWidget);
  });

  testWidgets('MainShell bottom nav items contain button and label semantics', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tmdbServiceProvider.overrideWithValue(FakeTmdbService()),
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
          onboardingCompletedProvider.overrideWith(
            (ref) => OnboardingCompletedNotifier(AppSettingsStore())..setCompleted(true),
          ),
          firstSessionChecklistDismissedProvider.overrideWith(
            (ref) => FirstSessionChecklistDismissedNotifier(AppSettingsStore())..setDismissed(true),
          ),
          allWatchRecordsProvider.overrideWith((ref) => Stream.value([])),
          recentlyAddedMoviesProvider.overrideWith((ref) => Stream.value([])),
          unwatchedMoviesProvider.overrideWith((ref) => Stream.value([])),
          favoriteMovieIdsProvider.overrideWith((ref) => Stream.value({})),
          activelyWatchingProvider.overrideWith((ref) => Stream.value([])),
          allMovieSettingsProvider.overrideWith((ref) => Stream.value({})),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Ana Sayfa'), findsOneWidget);
    expect(find.bySemanticsLabel('Keşfet'), findsOneWidget);
    expect(find.bySemanticsLabel('Günlük'), findsOneWidget);
    expect(find.bySemanticsLabel('Topluluk'), findsOneWidget);
  });
}
