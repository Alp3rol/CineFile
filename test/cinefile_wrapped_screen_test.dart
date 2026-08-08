import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/core/services/app_settings_store.dart';
import 'package:cinefile/features/insights/presentation/insights_provider.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'package:cinefile/features/wrapped/presentation/cinefile_wrapped_screen.dart';
import 'package:cinefile/l10n/app_localizations.dart';

import 'support/network_image_mock.dart';

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  testWidgets('CineFileWrappedScreen renders story slides and CTA buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
          insightsProvider.overrideWithValue(
            const InsightsData(
              totalWatchCount: 12,
              uniqueTitleCount: 10,
              totalDurationMinutes: 1440,
              averageRating: 8.5,
              topGenres: [],
              topDirectors: [],
              topActors: [],
              monthlyWatchTrend: {},
              timeOfDayTrend: {},
              dayOfWeekTrend: {},
              achievementBadges: [],
              dailyWatchCounts: {},
              dailyMovieWatchCounts: {},
              dailyTvWatchCounts: {},
              currentStreak: 5,
              longestStreak: 12,
              ratingDistribution: {},
              mostFrequentRating: 9,
              seasonalCounts: {},
              goldenWeekday: 5,
              topTags: [],
              thisWeekWatchCount: 3,
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CineFileWrappedScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('CineFile Özet'), findsOneWidget);
    expect(find.text('Sinema Yolculuğun'), findsOneWidget);
    expect(find.text('Toplam İzleme Süresi'), findsOneWidget);
  });
}
