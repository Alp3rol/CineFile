import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/core/ui/ui.dart';
import 'package:cinefile/l10n/app_localizations.dart';

void main() {
  testWidgets('AppErrorState renders offline mode title, subtitle and retry button', (WidgetTester tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AppErrorState(
            isOffline: true,
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Çevrimdışısınız'), findsOneWidget);
    expect(find.textContaining('İzleme kayıtların cihazında güvende'), findsOneWidget);
    expect(find.text('Tekrar Deneyin'), findsOneWidget);

    await tester.tap(find.text('Tekrar Deneyin'));
    expect(retried, isTrue);
  });

  testWidgets('AppErrorState renders custom title and generic error icon when not offline', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AppErrorState(
            title: 'Sunucu Hatası',
            subtitle: 'Lütfen daha sonra tekrar deneyiniz.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sunucu Hatası'), findsOneWidget);
    expect(find.text('Lütfen daha sonra tekrar deneyiniz.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });
}
