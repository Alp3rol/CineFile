import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import 'watch_form_label.dart';

// "İzleme Modu / Ruh Hali" emoji picker row used in the add-watch-record sheet.
class MoodSelector extends StatelessWidget {
  final List<String> moods;
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.moods,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const double _diameter = 48;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WatchFormLabel(AppLocalizations.of(context).addRecordMoodLabel),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // Default (hardEdge) clip — keeps the row confined to the
            // sheet's horizontal padding instead of the selected glow
            // shadow bleeding out to the screen/device edge.
            itemCount: moods.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = selectedMood == mood;

              return AppPressable(
                onTap: () => onMoodSelected(mood),
                borderRadius: AppRadius.pill,
                semanticLabel: mood,
                child: AnimatedContainer(
                  duration: AppDuration.fast,
                  curve: AppDuration.curve,
                  width: _diameter,
                  height: _diameter,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: AppOpacity.soft)
                        : AppColors.textPrimary
                            .withValues(alpha: AppOpacity.faint),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accent
                                  .withValues(alpha: AppOpacity.muted),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  // Emoji, so it carries its own colour — only the size is set.
                  child: Text(mood, style: const TextStyle(fontSize: 22)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
