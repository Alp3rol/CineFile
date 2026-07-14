import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/settings_provider.dart';

// Card view / table view switcher shown in JournalScreen's top banner.
class JournalViewModeToggle extends ConsumerWidget {
  final bool isTableView;
  const JournalViewModeToggle({super.key, required this.isTableView});

  Widget _buildOption(WidgetRef ref, {required bool selected, required IconData icon, required bool value}) {
    return GestureDetector(
      onTap: () => ref.read(journalViewModeProvider.notifier).setTableView(value),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: selected ? Colors.white : AppTheme.textSecondary),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          _buildOption(ref, selected: !isTableView, icon: Icons.view_agenda_rounded, value: false),
          _buildOption(ref, selected: isTableView, icon: Icons.table_rows_rounded, value: true),
        ],
      ),
    );
  }
}
