import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/watch_regions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../settings_provider.dart';
import 'settings_section_header.dart';

// "Tercihler" card: release-reminders and dynamic-background toggles.
class SettingsPreferencesSection extends ConsumerWidget {
  const SettingsPreferencesSection({super.key});

  Widget _divider() {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.borderColor);
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _navRow({
    required IconData icon,
    required String label,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              ),
            ),
            Text(
              trailingText,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  /// Each language is named in itself ("Türkçe", not "Turkish") so a user who
  /// opened the app in a language they can't read can still find their own.
  /// Only "System" is translated, since it describes a behaviour rather than a
  /// language.
  static String _languageLabel(AppLocalizations l10n, Locale? locale) {
    switch (locale?.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return l10n.settingsLanguageSystem;
    }
  }

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(localeProvider);

    // "System" is the null locale, and `showDialog` also completes with null
    // when the user dismisses it — so results are popped wrapped in a
    // single-element list. An unwrapped null then unambiguously means
    // "dismissed, change nothing".
    final options = <Locale?>[null, ...supportedLanguageCodes.map(Locale.new)];

    final selection = await showDialog<List<Locale?>>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          l10n.settingsLanguageTitle,
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        children: [
          for (final option in options)
            ListTile(
              onTap: () => Navigator.of(context).pop([option]),
              title: Text(
                _languageLabel(l10n, option),
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              ),
              trailing: option?.languageCode == current?.languageCode
                  ? const Icon(Icons.check_rounded, size: 20, color: AppTheme.accentColor)
                  : null,
            ),
        ],
      ),
    );

    if (selection == null) return;
    await ref.read(localeProvider.notifier).setLocale(selection.single);
  }

  /// Label for the streaming-region row: the chosen country, or the one
  /// "Automatic" actually resolved to. Naming the resolved country is what
  /// keeps "Automatic" from being a mystery when the catalogue looks wrong.
  String _regionLabel(AppLocalizations l10n, String? override, String effective) {
    if (override != null) return watchRegionLabel(override);
    return l10n.settingsWatchRegionAutoWith(watchRegionLabel(effective));
  }

  Future<void> _showRegionPicker(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(watchRegionProvider);
    final effective = ref.read(effectiveWatchRegionProvider);

    // Same single-element-list wrapper as the language picker, for the same
    // reason: null is both "Automatic" and "dismissed".
    final options = <String?>[null, ...watchRegionOptions()];

    final selection = await showDialog<List<String?>>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          l10n.settingsWatchRegionTitle,
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        children: [
          // Bounded and scrollable — this list is ~35 rows where the language
          // one is 3, and an unbounded SimpleDialog overflows.
          SizedBox(
            width: double.maxFinite,
            height: 380,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return ListTile(
                  onTap: () => Navigator.of(context).pop([option]),
                  title: Text(
                    option == null
                        ? l10n.settingsWatchRegionAutoWith(watchRegionLabel(effective))
                        : watchRegionLabel(option),
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                  ),
                  trailing: option == current
                      ? const Icon(Icons.check_rounded, size: 20, color: AppTheme.accentColor)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );

    if (selection == null) return;
    await ref.read(watchRegionProvider.notifier).setRegion(selection.single);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: AppLocalizations.of(context).settingsPreferences),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 4),
          borderRadius: 16,
          opacity: 0.6,
          child: Column(
            children: [
              _toggleRow(
                icon: Icons.notifications_active_outlined,
                label: AppLocalizations.of(context).settingsReleaseReminders,
                value: ref.watch(releaseRemindersEnabledProvider),
                onChanged: (v) async {
                  if (v) {
                    final messenger = ScaffoldMessenger.of(context);
                    // Resolved alongside the messenger, before the await, for
                    // the same reason: neither may be read from context once
                    // the permission dialog has returned.
                    final deniedMessage =
                        AppLocalizations.of(context).settingsNotificationPermissionDenied;
                    final granted = await ref.read(notificationServiceProvider).requestPermissions();
                    if (granted) {
                      await ref.read(releaseRemindersEnabledProvider.notifier).savePreference(true);
                      await ref.read(notificationServiceProvider).syncNotifications();
                    } else {
                      messenger.showSnackBar(
                        SnackBar(content: Text(deniedMessage)),
                      );
                    }
                  } else {
                    await ref.read(releaseRemindersEnabledProvider.notifier).savePreference(false);
                    await ref.read(notificationServiceProvider).syncNotifications();
                  }
                },
              ),
              _divider(),
              _toggleRow(
                icon: Icons.palette_outlined,
                label: AppLocalizations.of(context).settingsDynamicBackground,
                value: ref.watch(dynamicBackgroundEnabledProvider),
                onChanged: (v) => ref.read(dynamicBackgroundEnabledProvider.notifier).setEnabled(v),
              ),
              _divider(),
              _navRow(
                icon: Icons.language_rounded,
                label: l10n.settingsLanguageLabel,
                trailingText: _languageLabel(l10n, ref.watch(localeProvider)),
                onTap: () => _showLanguagePicker(context, ref),
              ),
              _divider(),
              _navRow(
                icon: Icons.public_rounded,
                label: l10n.settingsWatchRegionLabel,
                trailingText: _regionLabel(
                  l10n,
                  ref.watch(watchRegionProvider),
                  ref.watch(effectiveWatchRegionProvider),
                ),
                onTap: () => _showRegionPicker(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
