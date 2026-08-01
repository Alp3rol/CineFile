import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/l10n/date_text.dart';
import '../../../../core/ui/ui.dart';

// "Maraton Mücadelesi" banner shown when the collection has a targetDate
// (v0.9.0). Only rendered by the caller when list.targetDate != null.
class CustomListMarathonBanner extends StatelessWidget {
  final DateTime targetDate;
  final double progress;
  final int remainingCount;

  const CustomListMarathonBanner({
    super.key,
    required this.targetDate,
    required this.progress,
    required this.remainingCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isComplete = progress == 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.allLg,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: AppOpacity.medium),
          width: 1.5,
        ),
        // A faint accent wash rather than a two-hue gradient — the second stop
        // was Colors.purple, which appears nowhere else in the app.
        color: AppColors.accent.withValues(alpha: AppOpacity.faint),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: AppOpacity.faint),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            color: AppColors.accent,
            size: AppSize.iconLg,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.marathonTitle,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatShortDate(context, targetDate),
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  targetDate.isBefore(DateTime.now())
                      ? l10n.marathonExpired
                      : l10n.marathonDaysLeft(
                          targetDate.difference(DateTime.now()).inDays + 1,
                        ),
                  style: textTheme.labelMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  isComplete
                      ? l10n.marathonCompleted
                      : l10n.marathonRemaining(remainingCount),
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isComplete
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
