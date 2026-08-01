import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../insights_provider.dart';

class WeeklyGoalCard extends ConsumerWidget {
  final InsightsData data;
  const WeeklyGoalCard({super.key, required this.data});

  void _showEditGoalDialog(BuildContext context, WidgetRef ref, int weeklyGoal) {
    int tempGoal = weeklyGoal;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                AppLocalizations.of(context).weeklyGoalSetTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).weeklyGoalQuestion,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).weeklyGoalItemsCount(tempGoal),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.accent,
                      inactiveTrackColor: AppColors.border,
                      thumbColor: AppColors.rating,
                    ),
                    child: Slider(
                      value: tempGoal.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (val) {
                        setDialogState(() {
                          tempGoal = val.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).commonCancel, style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  onPressed: () {
                    ref.read(weeklyGoalProvider.notifier).saveGoal(tempGoal);
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context).commonSave, style: TextStyle(color: AppColors.onAccentAlt, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyGoal = ref.watch(weeklyGoalProvider);
    final count = data.thisWeekWatchCount;
    final progress = weeklyGoal > 0 ? (count / weeklyGoal).clamp(0.0, 1.0) : 1.0;

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.track_changes_rounded, color: AppColors.accent, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context).weeklyGoalTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 16),
                onPressed: () => _showEditGoalDialog(context, ref, weeklyGoal),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // One message rather than five TextSpans with the numbers
                    // bolded between them: the sentence's parts don't stay in
                    // that order across languages, so the split cannot be
                    // translated. The bold accent on the numbers is the cost.
                    Text(
                      AppLocalizations.of(context).weeklyGoalProgress(count, weeklyGoal),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress >= 1.0
                          ? AppLocalizations.of(context).weeklyGoalReached
                          : AppLocalizations.of(context).weeklyGoalRemaining(weeklyGoal - count),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: progress >= 1.0 ? AppColors.success : AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? AppColors.success : AppColors.accent,
                      ),
                      strokeWidth: 4,
                    ),
                  ),
                  Text(
                    '%${(progress * 100).toInt()}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
