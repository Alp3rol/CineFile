import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../insights_provider.dart';

class InsightsFilterBar extends ConsumerWidget {
  const InsightsFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedYear = ref.watch(insightsYearFilterProvider);
    final selectedType = ref.watch(insightsMediaTypeFilterProvider);

    final currentYear = DateTime.now().year;
    final years = [null, for (int y = currentYear; y >= currentYear - 3; y--) y];

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Media Type Filter Chips
                AppChip(
                  label: l10n.insightsFilterAllTypes,
                  selected: selectedType == null,
                  onTap: () => ref.read(insightsMediaTypeFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: AppSpacing.xs),
                AppChip(
                  label: l10n.insightsFilterMoviesOnly,
                  selected: selectedType == 'movie',
                  onTap: () => ref.read(insightsMediaTypeFilterProvider.notifier).state = 'movie',
                ),
                const SizedBox(width: AppSpacing.xs),
                AppChip(
                  label: l10n.insightsFilterTvOnly,
                  selected: selectedType == 'tv',
                  onTap: () => ref.read(insightsMediaTypeFilterProvider.notifier).state = 'tv',
                ),
                const SizedBox(width: AppSpacing.md),
                Container(width: 1, height: 20, color: Colors.white24),
                const SizedBox(width: AppSpacing.md),

                // Year Filter Chips
                for (final year in years) ...[
                  AppChip(
                    label: year == null ? l10n.insightsFilterAllYears : '$year',
                    selected: selectedYear == year,
                    onTap: () => ref.read(insightsYearFilterProvider.notifier).state = year,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
