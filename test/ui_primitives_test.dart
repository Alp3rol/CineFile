// Covers the design-system primitives in lib/core/ui/.
//
// The load-bearing test here is "every button variant is the same height".
// The whole point of this layer is that controls stop drifting apart from each
// other screen by screen, and a geometry assertion is the only kind of test
// that actually catches that happening again.
//
// Note these build their own MaterialApp with AppTheme.darkTheme rather than
// using support/localized_app.dart: LocalizedTestApp does not apply the app's
// theme, and AppButton gets its geometry *from* the theme, so testing it under
// Flutter's default theme would assert nothing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/theme/app_theme.dart';
import 'package:cinefile/core/ui/ui.dart';

Widget _themed(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppButton', () {
    testWidgets('renders its label and fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_themed(
        AppButton(label: 'Kaydet', onPressed: () => taps++),
      ));

      expect(find.text('Kaydet'), findsOneWidget);
      await tester.tap(find.text('Kaydet'));
      expect(taps, 1);
    });

    testWidgets('a null onPressed disables it', (tester) async {
      await tester.pumpWidget(_themed(
        const AppButton(label: 'Kaydet', onPressed: null),
      ));

      expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
          isFalse);
    });

    testWidgets('while loading it shows a spinner and swallows taps',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_themed(
        AppButton(label: 'Kaydet', isLoading: true, onPressed: () => taps++),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Kaydet'), findsNothing);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      // The callback is suppressed by the widget itself, so call sites don't
      // each have to remember `onPressed: loading ? null : ...`.
      expect(taps, 0);
    });

    testWidgets('the spinner takes the button foreground, not the theme accent',
        (tester) async {
      await tester.pumpWidget(_themed(
        AppButton(label: 'Kaydet', isLoading: true, onPressed: () {}),
      ));

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      // Accent-on-accent would be invisible; onAccent is the correct resolve.
      expect(spinner.color, AppColors.onAccent);
      expect(spinner.color, isNot(AppColors.accent));
    });

    testWidgets('every medium variant is exactly the same height',
        (tester) async {
      const variants = AppButtonVariant.values;

      await tester.pumpWidget(_themed(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in variants)
              AppButton(
                key: ValueKey(v),
                label: v.name,
                variant: v,
                onPressed: () {},
              ),
          ],
        ),
      ));

      final heights = variants
          .map((v) => tester.getSize(find.byKey(ValueKey(v))).height)
          .toSet();

      // One distinct height across all four variants. Ghost is the one at risk
      // here — it renders as a TextButton, whose theme uses the compact
      // "inline link" geometry.
      expect(heights, hasLength(1),
          reason: 'button variants drifted apart: $heights');
      expect(heights.single, AppSize.buttonHeightMd);
    });

    testWidgets('isFullWidth stretches to the available width',
        (tester) async {
      await tester.pumpWidget(_themed(
        SizedBox(
          width: 300,
          child: AppButton(
            label: 'Kaydet',
            isFullWidth: true,
            onPressed: () {},
          ),
        ),
      ));

      expect(tester.getSize(find.byType(FilledButton)).width, 300);
    });

    testWidgets('an icon renders alongside the label', (tester) async {
      await tester.pumpWidget(_themed(
        AppButton(
          label: 'Çıkış Yap',
          icon: Icons.logout_rounded,
          variant: AppButtonVariant.destructive,
          onPressed: () {},
        ),
      ));

      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      expect(find.text('Çıkış Yap'), findsOneWidget);
    });
  });

  group('AppEmptyState', () {
    testWidgets('renders title, subtitle and a working CTA', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_themed(
        AppEmptyState(
          icon: Icons.movie_outlined,
          title: 'Henüz film yok',
          subtitle: 'İlk filmini ekle',
          ctaLabel: 'Film Ekle',
          onCta: () => taps++,
        ),
      ));

      expect(find.text('Henüz film yok'), findsOneWidget);
      expect(find.text('İlk filmini ekle'), findsOneWidget);

      await tester.tap(find.text('Film Ekle'));
      expect(taps, 1);
    });

    testWidgets('omits the CTA when no callback is given', (tester) async {
      await tester.pumpWidget(_themed(
        const AppEmptyState(
          icon: Icons.movie_outlined,
          title: 'Henüz film yok',
          ctaLabel: 'Film Ekle',
        ),
      ));

      expect(find.byType(AppButton), findsNothing);
    });
  });

  group('AppChip', () {
    testWidgets('reports selection through its label colour', (tester) async {
      await tester.pumpWidget(_themed(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppChip(key: ValueKey('on'), label: 'Seçili', selected: true),
            AppChip(key: ValueKey('off'), label: 'Değil'),
          ],
        ),
      ));

      Color? colorOf(String text) =>
          tester.widget<Text>(find.text(text)).style?.color;

      expect(colorOf('Seçili'), AppColors.accent);
      expect(colorOf('Değil'), AppColors.textSecondary);
    });

    testWidgets('a null onTap leaves no ink response behind', (tester) async {
      await tester.pumpWidget(_themed(
        const AppChip(label: 'Salt okunur'),
      ));

      // AppPressable skips the Material/InkWell layer entirely when there is
      // nothing to tap, rather than paying for a layer that can never paint.
      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('AppAvatar', () {
    testWidgets('derives initials from a full name', (tester) async {
      await tester.pumpWidget(_themed(const AppAvatar(name: 'Ada Lovelace')));
      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('uses a single initial for a mononym', (tester) async {
      await tester.pumpWidget(_themed(const AppAvatar(name: 'Cher')));
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('falls back to ? when there is no name at all',
        (tester) async {
      await tester.pumpWidget(_themed(const AppAvatar(name: '   ')));
      expect(find.text('?'), findsOneWidget);
    });
  });

  group('AppCard', () {
    testWidgets('is tappable when given a callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_themed(
        AppCard(onTap: () => taps++, child: const Text('içerik')),
      ));

      await tester.tap(find.text('içerik'));
      expect(taps, 1);
    });
  });

  group('AppDialog.confirm', () {
    testWidgets('resolves true on confirm and false on cancel',
        (tester) async {
      Future<bool?> open(WidgetTester tester, String tapLabel) async {
        late Future<bool?> result;
        await tester.pumpWidget(_themed(
          Builder(
            builder: (context) => AppButton(
              label: 'aç',
              onPressed: () {
                result = AppDialog.confirm(
                  context: context,
                  title: 'Emin misin?',
                  confirmLabel: 'Evet',
                  cancelLabel: 'Vazgeç',
                  isDestructive: true,
                );
              },
            ),
          ),
        ));

        await tester.tap(find.text('aç'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(tapLabel));
        await tester.pumpAndSettle();
        return result;
      }

      expect(await open(tester, 'Evet'), isTrue);
      expect(await open(tester, 'Vazgeç'), isFalse);
    });
  });
}
