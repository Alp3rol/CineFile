import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_button.dart';

class AppErrorState extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final bool isOffline;

  const AppErrorState({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    this.onRetry,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final displayIcon = icon ??
        (isOffline
            ? Icons.wifi_off_rounded
            : Icons.error_outline_rounded);
    final displayTitle = title ??
        (isOffline ? l10n.errorOfflineTitle : l10n.errorGenericTitle);
    final displaySubtitle = subtitle ??
        (isOffline ? l10n.errorOfflineSubtitle : null);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              displayIcon,
              size: 56,
              color: isOffline ? AppColors.accent : Colors.redAccent,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              displayTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (displaySubtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                displaySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.errorRetryCTA,
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
