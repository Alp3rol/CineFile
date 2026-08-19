import 'package:flutter/material.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../journal_logic.dart';

class JournalSortSheet extends StatelessWidget {
  final JournalSortOption currentSort;
  final bool ascending;
  final void Function(JournalSortOption sortOption, bool ascending) onSortChanged;

  const JournalSortSheet({
    super.key,
    required this.currentSort,
    required this.ascending,
    required this.onSortChanged,
  });

  static Future<void> show({
    required BuildContext context,
    required JournalSortOption currentSort,
    required bool ascending,
    required void Function(JournalSortOption sortOption, bool ascending) onSortChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => JournalSortSheet(
        currentSort: currentSort,
        ascending: ascending,
        onSortChanged: onSortChanged,
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required JournalSortOption option,
    required String label,
    required IconData icon,
  }) {
    final isSelected = currentSort == option;
    return AppPressable(
      onTap: () {
        onSortChanged(option, ascending);
        Navigator.pop(context);
      },
      borderRadius: AppRadius.md,
      semanticLabel: label,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.accent : AppColors.textPrimary,
                    ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.sort_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.journalSortTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ],
              ),
              // Order Toggle Button
              AppPressable(
                onTap: () {
                  onSortChanged(currentSort, !ascending);
                  Navigator.pop(context);
                },
                borderRadius: AppRadius.sm,
                semanticLabel: ascending ? l10n.journalSortAscending : l10n.journalSortDescending,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ascending ? l10n.journalSortAscending : l10n.journalSortDescending,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Options
          _buildOptionTile(
            context: context,
            option: JournalSortOption.watchDate,
            label: l10n.journalSortWatchDate,
            icon: Icons.calendar_today_rounded,
          ),
          _buildOptionTile(
            context: context,
            option: JournalSortOption.rating,
            label: l10n.journalSortRating,
            icon: Icons.star_rounded,
          ),
          _buildOptionTile(
            context: context,
            option: JournalSortOption.title,
            label: l10n.journalSortTitleAlpha,
            icon: Icons.sort_by_alpha_rounded,
          ),
          _buildOptionTile(
            context: context,
            option: JournalSortOption.runtime,
            label: l10n.journalSortRuntime,
            icon: Icons.hourglass_bottom_rounded,
          ),
          _buildOptionTile(
            context: context,
            option: JournalSortOption.releaseYear,
            label: l10n.journalSortReleaseYear,
            icon: Icons.movie_creation_outlined,
          ),
        ],
      ),
    );
  }
}
