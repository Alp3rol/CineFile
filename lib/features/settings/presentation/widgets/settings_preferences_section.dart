import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/watch_regions.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../onboarding/presentation/onboarding_screen.dart';
import '../privacy_center_screen.dart';
import '../settings_provider.dart';
import 'settings_section.dart';

// "Tercihler" card: release-reminders and dynamic-background toggles.
class SettingsPreferencesSection extends ConsumerWidget {
  const SettingsPreferencesSection({super.key});

  // Colour and thickness come from dividerTheme; only the inset is stated,
  // and height stays 1 so the divider adds no vertical space of its own.
  Widget _divider() {
    return const Divider(
      height: 1,
      indent: AppSpacing.lg,
      endIndent: AppSpacing.lg,
    );
  }

  Widget _rowLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _toggleRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSize.iconMd, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _rowLabel(context, label)),
          // Thumb and track colours come from switchTheme.
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _navRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return AppPressable(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSize.iconMd, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _rowLabel(context, label)),
          Text(
            trailingText,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.chevron_right_rounded,
            size: AppSize.iconSm,
            color: AppColors.textSecondary,
          ),
        ],
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

  /// Row in one of the two pickers below. Chrome comes from dialogTheme.
  static Widget _pickerOption({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.textPrimary),
      ),
      trailing: selected
          ? const Icon(
              Icons.check_rounded,
              size: AppSize.iconMd,
              color: AppColors.accent,
            )
          : null,
    );
  }

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(localeProvider);

    // "System" is the null locale, and `showDialog` also completes with null
    // when the user dismisses it — so results are popped wrapped in a
    // single-element list. An unwrapped null then unambiguously means
    // "dismissed, change nothing".
    final options = <Locale?>[null, ...supportedLanguageCodes.map(Locale.new)];

    final selection = await AppDialog.show<List<Locale?>>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settingsLanguageTitle),
        children: [
          for (final option in options)
            _pickerOption(
              context: dialogContext,
              label: _languageLabel(l10n, option),
              selected: option?.languageCode == current?.languageCode,
              onTap: () => Navigator.of(dialogContext).pop([option]),
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

    final selection = await AppDialog.show<List<String?>>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settingsWatchRegionTitle),
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
                return _pickerOption(
                  context: dialogContext,
                  label: option == null
                      ? l10n.settingsWatchRegionAutoWith(watchRegionLabel(effective))
                      : watchRegionLabel(option),
                  selected: option == current,
                  onTap: () => Navigator.of(dialogContext).pop([option]),
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

    return SettingsSection(
      title: l10n.settingsPreferences,
      // The rows pad themselves so they can run edge to edge under the
      // dividers; the card only adds a little breathing room top and bottom.
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          _toggleRow(
            context,
            icon: Icons.notifications_active_outlined,
            label: l10n.settingsReleaseReminders,
            value: ref.watch(releaseRemindersEnabledProvider),
            onChanged: (v) async {
              if (v) {
                final messenger = ScaffoldMessenger.of(context);
                // Resolved alongside the messenger, before the await, for
                // the same reason: neither may be read from context once
                // the permission dialog has returned.
                final deniedMessage = l10n.settingsNotificationPermissionDenied;
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
            context,
            icon: Icons.forum_outlined,
            label: l10n.settingsSocialNotifications,
            value: ref.watch(socialNotificationsEnabledProvider),
            onChanged: (v) => ref.read(socialNotificationsEnabledProvider.notifier).setEnabled(v),
          ),
          _divider(),
          _toggleRow(
            context,
            icon: Icons.live_tv_outlined,
            label: l10n.settingsEpisodeNotifications,
            value: ref.watch(episodeNotificationsEnabledProvider),
            onChanged: (v) => ref.read(episodeNotificationsEnabledProvider.notifier).setEnabled(v),
          ),
          _divider(),
          _toggleRow(
            context,
            icon: Icons.auto_awesome_outlined,
            label: l10n.settingsRecommendationNotifications,
            value: ref.watch(recommendationNotificationsEnabledProvider),
            onChanged: (v) => ref.read(recommendationNotificationsEnabledProvider.notifier).setEnabled(v),
          ),
          _divider(),
          _toggleRow(
            context,
            icon: Icons.palette_outlined,
            label: l10n.settingsDynamicBackground,
            value: ref.watch(dynamicBackgroundEnabledProvider),
            onChanged: (v) => ref.read(dynamicBackgroundEnabledProvider.notifier).setEnabled(v),
          ),
          _divider(),
          _navRow(
            context,
            icon: Icons.language_rounded,
            label: l10n.settingsLanguageLabel,
            trailingText: _languageLabel(l10n, ref.watch(localeProvider)),
            onTap: () => _showLanguagePicker(context, ref),
          ),
          _divider(),
          _navRow(
            context,
            icon: Icons.public_rounded,
            label: l10n.settingsWatchRegionLabel,
            trailingText: _regionLabel(
              l10n,
              ref.watch(watchRegionProvider),
              ref.watch(effectiveWatchRegionProvider),
            ),
            onTap: () => _showRegionPicker(context, ref),
          ),
          _divider(),
          _navRow(
            context,
            icon: Icons.auto_awesome_rounded,
            label: l10n.settingsRerunOnboarding,
            trailingText: '',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(isModal: true),
                ),
              );
            },
          ),
          _divider(),
          _navRow(
            context,
            icon: Icons.security_rounded,
            label: l10n.privacyCenterTitle,
            trailingText: '',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PrivacyCenterScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
