import 'package:cinefile/features/insights/presentation/widgets/swipe_taste_profile_card.dart';
import 'package:cinefile/features/swipe_discovery/data/swipe_preference_signal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/localized_app.dart';

void main() {
  testWidgets('renders learned genres and swipe totals in insights', (
    tester,
  ) async {
    await tester.pumpWidget(
      LocalizedTestApp(
        locale: const Locale('tr'),
        home: const Scaffold(
          body: SwipeTasteProfileCard(
            profile: SwipeTasteProfile(
              genreIds: [878, 18],
              interestedCount: 7,
              passedCount: 4,
              genreRejectionCount: 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Kaydırmalardan Öğrenilen Zevkin'), findsOneWidget);
    expect(find.text('Bilim Kurgu'), findsOneWidget);
    expect(find.text('Dram'), findsOneWidget);
    expect(find.text('7 beğeni • 4 geçiş'), findsOneWidget);
    expect(
      find.text('1 tür geri bildirimi önerilerini hassaslaştırdı'),
      findsOneWidget,
    );
  });
}
