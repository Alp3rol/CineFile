import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Shown when the user has fewer than two titles that share a person — there's
/// nothing to connect yet. Explains the feature rather than showing a blank
/// canvas.
class GraphEmptyState extends StatelessWidget {
  const GraphEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hub_rounded,
                size: 64, color: AppTheme.accentColor.withValues(alpha: 0.7)),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).graphEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).graphEmptyBody,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
