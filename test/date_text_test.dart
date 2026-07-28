// Covers the locale-aware date helpers that replaced hardcoded
// DateFormat('d MMMM y', 'tr_TR') / DateFormat('dd.MM.yyyy') call sites.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cinefile/core/l10n/date_text.dart';
import 'support/localized_app.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  group('Turkish-aware upper case', () {
    test('uppercases a dotted i to a dotted İ in Turkish', () {
      // Dart's own casing is locale-invariant, so these month headings used
      // to render as NISAN / EKIM / HAZIRAN — visibly wrong Turkish.
      expect(upperCaseFor('Nisan', const Locale('tr')), 'NİSAN');
      expect(upperCaseFor('Ekim', const Locale('tr')), 'EKİM');
      expect(upperCaseFor('Haziran', const Locale('tr')), 'HAZİRAN');
    });

    test('uppercases a dotless ı to a plain I in Turkish', () {
      expect(upperCaseFor('Kasım', const Locale('tr')), 'KASIM');
    });

    test('leaves other languages on the default rules', () {
      expect(upperCaseFor('April', const Locale('en')), 'APRIL');
    });
  });

  testWidgets('dates follow the locale rather than a fixed pattern', (tester) async {
    late String short;
    late String long;
    late String month;

    Future<void> pumpIn(Locale locale) async {
      await tester.pumpWidget(LocalizedTestApp(
        locale: locale,
        home: Builder(builder: (context) {
          final date = DateTime(2026, 3, 12);
          short = formatShortDate(context, date);
          long = formatLongDate(context, date);
          month = formatMonthHeading(context, date);
          return const SizedBox();
        }),
      ));
      await tester.pump();
    }

    await pumpIn(const Locale('tr'));
    expect(short, '12.03.2026');
    expect(long, contains('Mart'));
    expect(month, 'MART 2026');

    await pumpIn(const Locale('en'));
    // Day-first is a convention, not a universal: English must not get it.
    expect(short, isNot('12.03.2026'));
    expect(long, contains('March'));
    expect(month, 'MARCH 2026');
  });
}
