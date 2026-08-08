import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/core/services/app_settings_store.dart';
import 'package:cinefile/features/insights/presentation/widgets/insights_filter_bar.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'package:cinefile/l10n/app_localizations.dart';

import 'support/network_image_mock.dart';

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  testWidgets('InsightsFilterBar renders media type and year filter chips', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: InsightsFilterBar()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tüm Yapımlar'), findsOneWidget);
    expect(find.text('Sadece Filmler'), findsOneWidget);
    expect(find.text('Sadece Diziler'), findsOneWidget);
    expect(find.text('Tüm Yıllar'), findsOneWidget);
  });
}
