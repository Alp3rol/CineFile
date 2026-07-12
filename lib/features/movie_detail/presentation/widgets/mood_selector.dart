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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: moods.map((mood) {
            final isSelected = selectedMood == mood;
            return GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.3) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.accentColor : Colors.grey.shade800,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  mood,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
