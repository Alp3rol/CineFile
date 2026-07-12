// Verifies the year-picker added to PremiumDatePicker: tapping the month/
// year header reveals a year grid so jumping to an old year doesn't require
// clicking the month arrow dozens of times (the reported problem — picking
// a watch date from years ago was "nearly impossible").
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/widgets/premium_date_picker.dart';

void main() {
  testWidgets('tapping the header opens a year grid, and picking a year jumps the calendar there', (tester) async {
    DateTime? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await PremiumDatePicker.show(
                  context,
                  initialDate: DateTime(2026, 7, 12),
                  firstDate: DateTime(2015, 1, 1),
                  lastDate: DateTime(2026, 7, 12),
                );
              },
              child: const Text('Aç'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();

    // Starts on the month/year view for the initial date.
    expect(find.text('Temmuz 2026'), findsOneWidget);

    // Tapping the header reveals the year grid instead of month arrows.
    await tester.tap(find.text('Temmuz 2026'));
    await tester.pumpAndSettle();

    expect(find.text('2026'), findsWidgets);
    expect(find.text('2015'), findsOneWidget);

    // Picking a far-away year jumps the calendar there directly — no need
    // to click the month arrow ~130 times.
    await tester.tap(find.text('2015'));
    await tester.pumpAndSettle();

    expect(find.text('Temmuz 2015'), findsOneWidget);

    // Pick a day and confirm — the returned date should carry the new year.
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Onayla'));
    await tester.pumpAndSettle();

    expect(result, DateTime(2015, 7, 15));
  });
}
