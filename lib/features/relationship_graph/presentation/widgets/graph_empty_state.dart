import 'package:flutter/material.dart';
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
              'İlişki Ağı henüz boş',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Ortak oyuncu veya yönetmeni olan en az iki yapımı günlüğüne '
              'ekleyince, aralarındaki gizli bağlantılar burada otomatik olarak '
              'belirmeye başlar.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
