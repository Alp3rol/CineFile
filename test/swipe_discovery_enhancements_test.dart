import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/core/services/app_settings_store.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'package:cinefile/features/swipe_discovery/data/swipe_preference_signal.dart';
import 'package:cinefile/features/swipe_discovery/presentation/widgets/cine_twin_match_dialog.dart';
import 'package:cinefile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'support/network_image_mock.dart';

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  test('rankRemainingItemsBySessionPreference ranks higher scored genres first', () {
    final items = [
      {
        'id': 1,
        'title': 'Comedy Movie',
        'genre_ids': [35],
      },
      {
        'id': 2,
        'title': 'Action Movie',
        'genre_ids': [28],
      },
    ];

    final sessionScores = {28: 6, 35: -2}; // Action is preferred

    final ranked = rankRemainingItemsBySessionPreference(items, sessionScores);
    expect(ranked.first['id'], equals(2)); // Action Movie pushed to top
  });

  testWidgets('CineTwinMatchDialog renders match title and CTA button', (WidgetTester tester) async {
    final sampleItem = {
      'id': 101,
      'title': 'Inception',
      'poster_path': '/sample.jpg',
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CineTwinMatchDialog.show(
                    context,
                    item: sampleItem,
                    matchedUsername: 'ahmet',
                    onAddToWatchlist: () {},
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Eşleştiniz! 🎉'), findsOneWidget);
    expect(find.text('ahmet ile ikiniz de bu yapımı izlemek istiyorsunuz.'), findsOneWidget);
    expect(find.text('İzleme Listeme Ekle'), findsOneWidget);
  });
}
