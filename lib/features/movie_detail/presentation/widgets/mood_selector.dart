import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İzleme Modu / Ruh Hali:',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // Default (hardEdge) clip — keeps the row confined to the
            // sheet's horizontal padding instead of the selected glow
            // shadow bleeding out to the screen/device edge.
            itemCount: moods.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = selectedMood == mood;
              return GestureDetector(
                onTap: () => onMoodSelected(mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.accentColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    mood,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
