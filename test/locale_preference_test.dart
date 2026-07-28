// Covers the language picker added with the localization infrastructure: the
// app must follow the device language by default, picking a language must
// re-render the UI in it, and dismissing the dialog must NOT be mistaken for
// picking "System" (both come back from showDialog as null, which is why the
// picker pops its result wrapped in a list).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'package:cinefile/features/settings/presentation/widgets/settings_preferences_section.dart';
import 'package:cinefile/l10n/app_localizations.dart';

void main() {
  // main.dart turns runtime font fetching on. Left on here, the rows below
  // would make a real HTTP request for Outfit/Inter and pumpAndSettle would
  // block on it until the test timed out. Other widget tests get away with it
  // only because they install FakeImageHttpOverrides for their images.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  // Mirrors main.dart's wiring so a language change flows all the way through
  // MaterialApp, rather than only being asserted on the provider.
  Widget app(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          locale: ref.watch(localeProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: SettingsPreferencesSection()),
          ),
        ),
      ),
    );
  }

  testWidgets('follows the device language by default, then switches to Turkish', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(app(container));
    await tester.pumpAndSettle();

    // The test binding reports en-US, and no language has been stored, so the
    // app should be rendering English.
    expect(container.read(localeProvider), isNull);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    // Languages are named in themselves, so "Türkçe" reads the same whichever
    // language the dialog itself is rendered in.
    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();

    expect(container.read(localeProvider), const Locale('tr'));
    // The row itself is now Turkish — proof the change reached MaterialApp and
    // not just the provider.
    expect(find.text('Dil'), findsOneWidget);
    expect(find.text('Language'), findsNothing);
  });

  testWidgets('dismissing the picker leaves the current language alone', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(app(container));
    await tester.pumpAndSettle();

    // Set the starting language through the UI rather than by awaiting
    // setLocale directly: that call ends up awaiting a real platform channel
    // (the settings file), which never completes inside testWidgets' fake
    // async zone.
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dil'));
    await tester.pumpAndSettle();

    // Tap the barrier rather than an option — this is the path that would
    // silently reset the preference to "System" if the picker returned a bare
    // nullable Locale.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(container.read(localeProvider), const Locale('tr'));
    expect(find.text('Dil'), findsOneWidget);
  });
}
