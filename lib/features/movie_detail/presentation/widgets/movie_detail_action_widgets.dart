import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';

/// The gradient carried by the detail screen's diary actions.
///
/// Deliberately not the brand accent: logging a title is tied to the rating
/// vocabulary rather than to the brand red. See [AppColors.accentWarmStart].
const _warmGradient = LinearGradient(
  colors: [AppColors.accentWarmStart, AppColors.accentWarmEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class MovieInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const MovieInfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.allLg,
        color: AppColors.surfaceIndigo.withValues(alpha: AppOpacity.strong),
        // The border and halo take the card's own icon colour, so a row of
        // these reads as a set of differently-keyed cards rather than three
        // identical boxes.
        border: Border.all(
          color: iconColor.withValues(alpha: AppOpacity.medium),
          width: AppSize.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: AppOpacity.subtle),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: AppSize.iconMd),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}

class MovieQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const MovieQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  static const double _diameter = 56;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      borderRadius: AppRadius.pill,
      semanticLabel: label,
      child: Column(
        children: [
          Container(
            width: _diameter,
            height: _diameter,
            decoration: BoxDecoration(
              gradient: isPrimary ? _warmGradient : null,
              color: isPrimary
                  ? null
                  : AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPrimary
                    ? AppColors.accentWarmStart
                    : AppColors.textPrimary
                        .withValues(alpha: AppOpacity.muted),
                width: isPrimary ? 1.5 : AppSize.hairline,
              ),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        // Was the brand red under a gold button, which read as
                        // a mistake rather than a halo. It now matches what it
                        // is glowing beneath.
                        color: AppColors.accentWarmEnd
                            .withValues(alpha: AppOpacity.medium),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isPrimary ? AppColors.onAccentWarm : AppColors.textPrimary,
              size: AppSize.iconLg,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                  color: isPrimary
                      ? AppColors.accentWarmStart
                      : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class MovieDetailStickyCta extends StatelessWidget {
  final VoidCallback onTap;

  const MovieDetailStickyCta({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: AppPressable(
        onTap: onTap,
        borderRadius: AppRadius.lg,
        semanticLabel: AppLocalizations.of(context).detailAddToMyDiary,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.allLg,
            gradient: _warmGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentWarmEnd
                    .withValues(alpha: AppOpacity.medium),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.onAccentWarm,
                size: AppSize.iconLg,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppLocalizations.of(context).detailAddToMyDiary,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onAccentWarm,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
