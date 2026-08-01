import 'package:flutter/material.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';

// Shared glass-styled two-choice dialog used by the episode guide's
// progress-confirmation and journal-prompt prompts. Returns true if the
// primary [confirmLabel] button was tapped, false if the [cancelLabel] button
// was tapped or the dialog was dismissed.
//
// The glass shell is deliberate — these prompts sit over the episode guide
// and read as part of it rather than as a system dialog. The buttons are not:
// the confirm action used to be a third distinct gradient (accent to amber),
// alongside the home hero's accent gradient and the detail screen's warm one.
// Three treatments for one control is what this migration exists to remove, so
// the actions are now the same ghost/primary pair every other dialog uses.
Future<bool> showGlassChoiceDialog(
  BuildContext context, {
  required Widget header,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
}) async {
  final result = await AppDialog.show<bool>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.transparent,
        child: GlassContainer(
          borderRadius: AppRadius.xl,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: cancelLabel,
                      variant: AppButtonVariant.ghost,
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      onPressed: () => Navigator.pop(dialogContext, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
