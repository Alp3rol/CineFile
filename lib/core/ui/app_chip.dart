import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_pressable.dart';

/// A filter or tag pill.
///
/// Journal and Search both hand-roll these with `GestureDetector` +
/// `BoxDecoration`, at different radii and with different selected-state
/// treatments. Built on [AppPressable] rather than Material's [FilterChip]
/// because the app's chips are display-dense and the Material chip's minimum
/// tap target forces a taller row than the designs use.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.onTap,
    this.selected = false,
    this.icon,
    this.count,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final IconData? icon;

  /// Optional trailing number, e.g. how many entries match this filter.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        selected ? AppColors.accent : AppColors.textSecondary;

    return AppPressable(
      onTap: onTap,
      borderRadius: AppRadius.pill,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        curve: AppDuration.curve,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: AppOpacity.soft)
              : AppColors.surface,
          borderRadius: AppRadius.allPill,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: AppSize.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSize.iconSm, color: foreground),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$count',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground.withValues(alpha: AppOpacity.strong),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
