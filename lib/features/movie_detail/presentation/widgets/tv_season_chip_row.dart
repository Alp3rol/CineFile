import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

// Horizontal scrollable row of season-selector chips for the episode guide.
class TvSeasonChipRow extends StatelessWidget {
  final List<dynamic> seasons;
  final int selectedSeasonNumber;
  final ValueChanged<int> onSeasonSelected;

  const TvSeasonChipRow({
    super.key,
    required this.seasons,
    required this.selectedSeasonNumber,
    required this.onSeasonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        itemBuilder: (context, index) {
          final s = seasons[index];
          final sNum = s['season_number'] as int? ?? 1;
          final sName = s['name'] as String? ?? '$sNum. Sezon';
          final isSelected = selectedSeasonNumber == sNum;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onSeasonSelected(sNum),
              child: GlassContainer(
                borderRadius: 12,
                opacity: isSelected ? 0.8 : 0.4,
                color: isSelected ? AppTheme.accentColor : null,
                border: Border.all(
                  color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
                  width: isSelected ? 1.5 : 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Center(
                  child: Text(
                    sName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
