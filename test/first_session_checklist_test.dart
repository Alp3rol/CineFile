import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/core/services/app_settings_store.dart';
import 'package:cinefile/features/home/presentation/widgets/first_session_checklist_card.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'package:cinefile/l10n/app_localizations.dart';

import 'support/network_image_mock.dart';

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  testWidgets('FirstSessionChecklistCard renders steps and calculates progress', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
          onboardingCompletedProvider.overrideWith(
            (ref) => OnboardingCompletedNotifier(AppSettingsStore())..setCompleted(true),
          ),
          firstSessionChecklistDismissedProvider.overrideWith(
            (ref) => FirstSessionChecklistDismissedNotifier(AppSettingsStore())..setDismissed(false),
          ),
          allWatchRecordsProvider.overrideWith((ref) => Stream.value([])),
          favoriteMovieIdsProvider.overrideWith((ref) => Stream.value({})),
          customListsProvider.overrideWith((ref) => Stream.value([])),
          followedUserIdsProvider.overrideWith((ref) => Stream.value({})),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: FirstSessionChecklistCard(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hoş Geldin! Başlangıç Rehberi'), findsOneWidget);
    expect(find.text('1/4 Tamamlandı'), findsOneWidget);
    expect(find.text('İzleme bölgeni ve dilini belirle'), findsOneWidget);
    expect(find.text('İlk film veya dizi kaydını ekle'), findsOneWidget);
  });

  testWidgets('FirstSessionChecklistCard hides when dismissed', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firstSessionChecklistDismissedProvider.overrideWith(
            (ref) => FirstSessionChecklistDismissedNotifier(AppSettingsStore())..setDismissed(true),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FirstSessionChecklistCard(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hoş Geldin! Başlangıç Rehberi'), findsNothing);
  });
}
