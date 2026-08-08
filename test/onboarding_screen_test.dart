import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/core/network/tmdb_service.dart';
import 'package:cinefile/core/services/app_settings_store.dart';
import 'package:cinefile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'package:cinefile/l10n/app_localizations.dart';

import 'support/network_image_mock.dart';

class FakeTmdbService extends TmdbService {
  FakeTmdbService() : super(Dio());

  @override
  Future<List<Map<String, dynamic>>> getTrendingMoviesThisWeek({String? language}) async {
    return [
      {
        'id': 101,
        'title': 'Interstellar',
        'media_type': 'movie',
        'poster_path': '/test.jpg',
        'release_date': '2014-11-05',
      }
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> searchMovies(
    String query, {
    int page = 1,
    String? language,
  }) async {
    return [
      {
        'id': 101,
        'title': 'Interstellar',
        'media_type': 'movie',
        'poster_path': '/test.jpg',
        'release_date': '2014-11-05',
      }
    ];
  }
}

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  testWidgets('OnboardingScreen renders step 1 preferences and advances steps', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
          onboardingCompletedProvider.overrideWith(
            (ref) => OnboardingCompletedNotifier(AppSettingsStore())..setCompleted(false),
          ),
          tmdbServiceProvider.overrideWithValue(FakeTmdbService()),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingScreen(isModal: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verifies step 1 title and welcome texts render
    expect(find.text('1. Tercihler'), findsOneWidget);
    expect(find.text("CineFile'a Hoş Geldin"), findsOneWidget);

    // Tap "Devam Et" to move to step 2 (Favorites)
    await tester.tap(find.text('Devam Et'));
    await tester.pumpAndSettle();

    expect(find.text('2. İlk Favoriler'), findsOneWidget);

    // Tap "Devam Et" again to move to step 3 (Walkthrough)
    await tester.tap(find.text('Devam Et'));
    await tester.pumpAndSettle();

    expect(find.text('3. Özellikler ve Gizlilik'), findsOneWidget);
    expect(find.text("CineFile'a Başla"), findsOneWidget);

    // Clean up
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
