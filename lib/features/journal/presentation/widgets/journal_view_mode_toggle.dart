import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../settings/presentation/settings_provider.dart';

// Card view / table view switcher shown in JournalScreen's top banner.
class JournalViewModeToggle extends ConsumerWidget {
  final bool isTableView;
  const JournalViewModeToggle({super.key, required this.isTableView});

  Widget _buildOption(
    WidgetRef ref, {
    required bool selected,
    required IconData icon,
    required bool value,
  }) {
    return AppPressable(
      onTap: () => ref.read(journalViewModeProvider.notifier).setTableView(value),
      borderRadius: AppRadius.sm,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.transparent,
          borderRadius: AppRadius.allSm,
        ),
        child: Icon(
          icon,
          size: AppSize.iconSm,
          color: selected ? AppColors.onAccent : AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        // A well the two options sit in, so the selected one reads as raised
        // out of it rather than as a floating chip.
        color: AppColors.surfaceSunken.withValues(alpha: AppOpacity.strong),
        borderRadius: AppRadius.allSm,
        border: Border.all(color: AppColors.border, width: AppSize.hairline),
      ),
      child: Row(
        children: [
          _buildOption(
            ref,
            selected: !isTableView,
            icon: Icons.view_agenda_rounded,
            value: false,
          ),
          _buildOption(
            ref,
            selected: isTableView,
            icon: Icons.table_rows_rounded,
            value: true,
          ),
        ],
      ),
    );
  }
}
