import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import 'duplicate_cleanup_screen.dart';
import 'settings_backup_dialogs.dart';
import 'settings_section.dart';

// "Veri Yönetimi & Yedekleme" card: export/import JSON backup, plus a link
// to the duplicate-watch-record cleanup screen.
class SettingsBackupSection extends ConsumerWidget {
  const SettingsBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SettingsSection(
      title: l10n.settingsDataSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCardIntro(
            title: l10n.settingsBackupTitle,
            description: l10n.settingsBackupDescription,
          ),
          const SizedBox(height: AppSpacing.lg),
          // All three actions here are the same kind of thing — a data
          // operation you start from this card — so they now share one
          // treatment. Import used to be drawn in the accent colour and the
          // other two in neutral, which read as a hierarchy that does not
          // exist; if anything import is the destructive one, since it
          // overwrites what you already have.
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l10n.settingsExport,
                  icon: Icons.download_rounded,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  onPressed: () => exportBackup(context, ref),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: l10n.settingsRestore,
                  icon: Icons.upload_rounded,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  onPressed: () => showImportDialog(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.settingsCleanDuplicates,
            icon: Icons.cleaning_services_outlined,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
            isFullWidth: true,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DuplicateCleanupScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
