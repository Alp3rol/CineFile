import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/widgets/spoiler_blur_widget.dart';

void main() {
  testWidgets('SpoilerBlurWidget toggles blur state on tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpoilerBlurWidget(
            child: Text('Secret Spoiler Text'),
          ),
        ),
      ),
    );

    // Initial state is blurred
    expect(find.byKey(const ValueKey('spoiler_blurred')), findsOneWidget);
    expect(find.text('Spoiler — Dokun ve Gör'), findsOneWidget);

    // Tap to unblur
    await tester.tap(find.byType(SpoilerBlurWidget));
    await tester.pumpAndSettle();

    // Unblurred state showing secret text
    expect(find.byKey(const ValueKey('spoiler_unblurred')), findsOneWidget);
    expect(find.text('Secret Spoiler Text'), findsOneWidget);
  });
}
