import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// The meaning a badge carries, which decides its colour.
enum AppBadgeTone { neutral, accent, rating, success, warning, error }

/// A small, non-interactive status pill.
///
/// Distinct from [AppChip]: a chip is something you tap, a badge is something
/// you read. The app conflated the two, which is why some "chips" have no
/// `onTap` and some badges have press feedback that does nothing.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.icon,
  });

  final String label;
  final AppBadgeTone tone;
  final IconData? icon;

  Color get _color => switch (tone) {
        AppBadgeTone.neutral => AppColors.textSecondary,
        AppBadgeTone.accent => AppColors.accent,
        AppBadgeTone.rating => AppColors.rating,
        AppBadgeTone.success => AppColors.success,
        AppBadgeTone.warning => AppColors.warning,
        AppBadgeTone.error => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.allXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSize.iconSm, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
