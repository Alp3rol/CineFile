import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';

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
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        itemBuilder: (context, index) {
          final s = seasons[index];
          final sNum = s['season_number'] as int? ?? 1;
          final sName = s['name'] as String? ?? '$sNum. Sezon';
          final posterPath = s['poster_path'] as String?;
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AppNetworkImage(
                        imageUrl: posterPath != null ? '${ApiConstants.imagePathW500}$posterPath' : '',
                        seed: sName,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
