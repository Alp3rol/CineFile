// Basic smoke test: verifies the app boots and shows its bottom navigation.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:filmdizi/main.dart';

void main() {
  testWidgets('App boots and shows bottom navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Ayarlar'), findsOneWidget);
  });
}
