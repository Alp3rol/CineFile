import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/features/settings/presentation/privacy_center_screen.dart';
import 'package:cinefile/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'PrivacyCenterScreen renders data privacy sections and export button',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PrivacyCenterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gizlilik Merkezi'), findsOneWidget);
      expect(find.text('Yerel Veriler (Cihaz İçi)'), findsOneWidget);
      expect(find.text('Bulut Senkronizasyonu'), findsOneWidget);
      expect(find.text('Topluluk ve Gizlilik Modelimiz'), findsOneWidget);
      expect(find.text('Anonim kullanım ölçümüne izin ver'), findsOneWidget);
      expect(find.text('Verilerimi JSON Olarak İndir'), findsOneWidget);
    },
  );
}
