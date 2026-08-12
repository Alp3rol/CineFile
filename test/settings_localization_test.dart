// Covers the settings screens rendering in both languages, and the
// context-free lookup that notification copy depends on.
//
// NotificationService itself no-ops under flutter_test (there is no OS
// notification surface), so what is asserted here is the piece that was
// actually at risk: that a language can be resolved without a BuildContext,
// which is how the service gets its copy.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinefile/core/l10n/l10n_lookup.dart';
import 'package:cinefile/features/settings/presentation/widgets/settings_backup_section.dart';
import 'package:cinefile/features/settings/presentation/widgets/settings_preferences_section.dart';
import 'package:cinefile/features/settings/presentation/widgets/settings_tmdb_attribution.dart';
import 'support/localized_app.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget settingsSections({Locale? locale}) {
    return ProviderScope(
      child: LocalizedTestApp(
        locale: locale,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SettingsPreferencesSection(),
                SettingsBackupSection(),
                SettingsTmdbAttribution(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders settings in Turkish', (tester) async {
    await tester.pumpWidget(settingsSections(locale: const Locale('tr')));
    await tester.pumpAndSettle();

    expect(find.text('Tercihler'), findsOneWidget);
    expect(find.text('Çıkış Hatırlatıcıları'), findsOneWidget);
    expect(find.text('Veri Yönetimi & Yedekleme'), findsOneWidget);
    expect(find.text('Dışa Aktar'), findsOneWidget);
    expect(find.text('Letterboxd CSV Önizleme'), findsOneWidget);
  });

  testWidgets('renders the same screens in English', (tester) async {
    await tester.pumpWidget(settingsSections(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Release Reminders'), findsOneWidget);
    expect(find.text('Data & Backup'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Letterboxd CSV Preview'), findsOneWidget);
    expect(find.text('Tercihler'), findsNothing);
  });

  testWidgets('shows the English TMDb attribution once, not twice', (
    tester,
  ) async {
    // TMDb asks for the attribution in English, so a non-English UI shows both
    // the localized and the English wording. In English they are the same
    // sentence and must not be duplicated.
    const english =
        'This product uses the TMDB API but is not endorsed or certified by TMDB.';

    await tester.pumpWidget(settingsSections(locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text(english), findsOneWidget);

    await tester.pumpWidget(settingsSections(locale: const Locale('tr')));
    await tester.pumpAndSettle();
    expect(find.text(english), findsOneWidget);
    expect(
      find.text(
        'Bu uygulama TMDB API\'sini kullanır ancak TMDB tarafından desteklenmez veya onaylanmaz.',
      ),
      findsOneWidget,
    );
  });

  test('notification copy resolves without a BuildContext', () {
    expect(
      lookupL10n(const Locale('tr')).notificationEpisodeTitle,
      'Yeni Bölüm! 🎬',
    );
    expect(
      lookupL10n(const Locale('en')).notificationEpisodeTitle,
      'New Episode! 🎬',
    );

    // The release body is two separate messages rather than one sentence with
    // a swapped-in noun, so both shapes have to survive translation.
    final en = lookupL10n(const Locale('en'));
    expect(en.notificationReleaseBodyMovie('Dune'), contains('Dune'));
    expect(en.notificationReleaseBodyShow('Severance'), contains('Severance'));
    expect(
      en.notificationReleaseBodyMovie('Dune'),
      isNot(en.notificationReleaseBodyShow('Dune')),
    );
  });
}
