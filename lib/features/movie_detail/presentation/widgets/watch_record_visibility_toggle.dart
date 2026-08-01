import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import 'watch_form_label.dart';

// Controls ONLY the "Son İzlediklerim" section on the user's own profile
// screen. Deliberately unrelated to the Community feed: feed posts are
// created explicitly via the compose bar's "Film Paylaş"/"Günlüğünü Paylaş"
// flows (see share_compose_sheet.dart), which snapshot their own data and
// never read this flag.
class WatchRecordVisibilityToggle extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const WatchRecordVisibilityToggle({
    super.key,
    required this.isPublic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppCard(
      tone: AppCardTone.translucent,
      borderRadius: AppRadius.md,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.public_rounded,
                      color: AppColors.accent,
                      size: AppSize.iconMd,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: WatchFormLabel(l10n.addRecordVisibilityLabel),
                    ),
                  ],
                ),
              ),
              // Colours come from switchTheme.
              Switch(value: isPublic, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.addRecordVisibilityHint,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
