import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// Horizontal "Tümü" + genre filter chip row under the search bar.
class SearchGenreChips extends StatelessWidget {
  final Map<String, int> genres;
  final int? selectedGenreId;
  final ValueChanged<int?> onGenreSelected;

  const SearchGenreChips({
    super.key,
    required this.genres,
    required this.selectedGenreId,
    required this.onGenreSelected,
  });

  Widget _genreChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.white70,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.accentColor,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(color: isSelected ? Colors.transparent : AppTheme.borderColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          // "Tümü" (All) Chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _genreChip(
              label: 'Tümü',
              isSelected: selectedGenreId == null,
              onSelected: (selected) {
                if (selected) onGenreSelected(null);
              },
            ),
          ),

          // Genre Chips mapping
          ...genres.entries.map((entry) {
            final isSelected = selectedGenreId == entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _genreChip(
                label: entry.key,
                isSelected: isSelected,
                onSelected: (selected) {
                  onGenreSelected(selected ? entry.value : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
