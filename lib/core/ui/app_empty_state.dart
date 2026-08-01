import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_button.dart';

/// The "there is nothing here" state.
///
/// Generalises `CommunityEmptyState`, which was the best of the six
/// independent empty states in the app (the others being `JournalEmptyState`,
/// `_buildFilteredEmptyState` in the actor filmography grid, and three
/// separate `_buildEmptyState` methods in Insights, Add-to-list and Custom
/// lists). The API is deliberately identical to `CommunityEmptyState`'s so
/// those call sites migrate without rewriting their arguments.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color:
                  AppColors.textSecondary.withValues(alpha: AppOpacity.medium),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: ctaLabel!, onPressed: onCta),
            ],
          ],
        ),
      ),
    );
  }
}
