import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/ui.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/presentation/widgets/user_profile_avatar_button.dart';
import 'widgets/settings_backup_section.dart';
import 'widgets/settings_preferences_section.dart';
import 'widgets/settings_tmdb_attribution.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Room under the last control so the floating bottom navigation bar never
  /// covers it. Deliberately off the spacing scale: it tracks the height of
  /// another widget rather than the layout rhythm.
  static const double _bottomNavClearance = 100;

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.profileSignOut,
      message: l10n.profileSignOutConfirm,
      confirmLabel: l10n.profileSignOut,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sticky Screen Title with Back Button & Profile Avatar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  if (canPop) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    l10n.settingsTitle,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const Spacer(),
                  const UserProfileAvatarButton(),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                // Matches the header inset above. These were 20 and 16
                // respectively, so the title and the cards beneath it did not
                // line up.
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: _bottomNavClearance,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SettingsPreferencesSection(),
                    const SizedBox(height: AppSpacing.xl),

                    const SettingsBackupSection(),
                    const SizedBox(height: AppSpacing.xl),

                    const SettingsTmdbAttribution(),
                    const SizedBox(height: AppSpacing.xxl),

                    AppButton(
                      label: l10n.profileSignOut,
                      icon: Icons.logout_rounded,
                      variant: AppButtonVariant.destructive,
                      isFullWidth: true,
                      onPressed: () => _confirmSignOut(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
