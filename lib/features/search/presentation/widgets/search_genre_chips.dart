import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/genre_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class SearchGenreChips extends StatelessWidget {
  /// TMDb genre ids to offer, in display order. Names come from
  /// [genreName] so the chips follow the user's language.
  final List<int> genreIds;
  final int? selectedGenreId;
  final ValueChanged<int?> onGenreSelected;

  const SearchGenreChips({
    super.key,
    required this.genreIds,
    required this.selectedGenreId,
    required this.onGenreSelected,
  });

  Widget _genreChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected ? Colors.amberAccent : Colors.white12,
            width: isSelected ? 1.2 : 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _genreChip(
              label: AppLocalizations.of(context).discoverGenreAll,
              isSelected: selectedGenreId == null,
              onTap: () => onGenreSelected(null),
            ),
          ),
          ...genreIds.map((id) {
            final isSelected = selectedGenreId == id;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _genreChip(
                label: genreName(AppLocalizations.of(context), id),
                isSelected: isSelected,
                onTap: () => onGenreSelected(isSelected ? null : id),
              ),
            );
          }),
        ],
      ),
    );
  }
}
