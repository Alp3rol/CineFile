import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../settings_provider.dart';

// Export/import backup flows for SettingsScreen's "Veri Yönetimi &
// Yedekleme" card — pulled out because both are self-contained (context +
// ref in, dialog side effects out) rather than State methods.

/// Monospaced, scrollable panel for raw JSON — used for the exported payload
/// preview. Sunken rather than raised: it is a well you read out of, not a
/// surface that sits on top.
class _JsonPanel extends StatelessWidget {
  const _JsonPanel({required this.json});

  final String json;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      width: double.maxFinite,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: AppRadius.allSm,
        border: Border.all(color: AppColors.border, width: AppSize.hairline),
      ),
      child: SingleChildScrollView(
        child: Text(
          json,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}

Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  try {
    final dataMap = await BackupService.exportData(ref);
    final jsonString = const JsonEncoder.withIndent('  ').convert(dataMap);

    // Copy to Clipboard
    await Clipboard.setData(ClipboardData(text: jsonString));

    if (context.mounted) {
      // Show backup display modal
      unawaited(
        AppDialog.show<void>(
          context: context,
          builder: (dialogContext) {
            final l10n = AppLocalizations.of(dialogContext);
            final theme = Theme.of(dialogContext);

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: AppSize.iconLg,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(l10n.backupCopiedTitle)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.backupCopiedMessage,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _JsonPanel(json: jsonString),
                ],
              ),
              actions: [
                AppButton(
                  label: l10n.commonClose,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            );
          },
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).backupExportError(e.toString()),
          ),
        ),
      );
    }
  }
}

void showImportDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();

  AppDialog.show<void>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);
      final theme = Theme.of(dialogContext);

      return AlertDialog(
        title: Text(l10n.backupRestoreTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.backupRestoreWarning,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              maxLines: 6,
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: 'monospace',
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(hintText: l10n.backupRestoreHint),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: l10n.commonCancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppButton(
            label: l10n.backupRestoreConfirm,
            onPressed: () async {
              final input = controller.text.trim();
              if (input.isEmpty) return;

              final messenger = ScaffoldMessenger.of(dialogContext);
              final navigator = Navigator.of(dialogContext);

              try {
                final jsonMap = BackupService.decodeImportPayload(input);
                await BackupService.importData(ref, jsonMap);

                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.backupRestoreSuccess)),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.backupRestoreInvalid(e.toString())),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
    // Disposed once the dialog has actually closed, whichever way it closed.
    // Previously this ran only on the Cancel path, so a successful import — or
    // a tap on the barrier — leaked the controller.
  ).whenComplete(controller.dispose);
}
