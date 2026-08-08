import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/features/journal/presentation/widgets/journal_empty_state.dart';
import 'package:cinefile/features/journal/presentation/widgets/custom_list_empty_state.dart';
import 'package:cinefile/l10n/app_localizations.dart';

import 'support/network_image_mock.dart';

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  testWidgets('JournalEmptyState renders CTA button for adding first record', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: JournalEmptyState(
              activeFilter: 'all',
              searchQuery: '',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('İlk Kaydını Ekle'), findsOneWidget);
  });

  testWidgets('JournalEmptyState renders CTA button for clearing filters', (WidgetTester tester) async {
    bool cleared = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: JournalEmptyState(
              activeFilter: 'favorites',
              searchQuery: 'Inception',
              onClearFilters: () => cleared = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Filtreleri Temizle'), findsOneWidget);

    await tester.tap(find.text('Filtreleri Temizle'));
    await tester.pump();

    expect(cleared, isTrue);
  });

  testWidgets('CustomListEmptyState renders CTA button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomListEmptyState(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Film/Dizi Ekle'), findsOneWidget);
  });
}
