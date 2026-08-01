import 'package:flutter/material.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';

// Horizontal scrollable row of season-selector chips for the episode guide.
//
// Not AppChip: these carry a season poster thumbnail, which that primitive
// deliberately does not support — a chip with an image in it is a different
// object, and widening AppChip to cover one call site would blur what it is.
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

  static const double _thumbSize = 24;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        itemBuilder: (context, index) {
          final s = seasons[index];
          final sNum = (s['season_number'] as num?)?.toInt() ?? 1;
          final sName = s['name'] as String? ?? '$sNum. Sezon';
          final posterPath = s['poster_path'] as String?;
          final isSelected = selectedSeasonNumber == sNum;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppPressable(
              onTap: () => onSeasonSelected(sNum),
              borderRadius: AppRadius.md,
              semanticLabel: sName,
              child: GlassContainer(
                borderRadius: AppRadius.md,
                opacity: isSelected ? AppOpacity.heavy : AppOpacity.medium,
                color: isSelected ? AppColors.accent : null,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: isSelected ? 1.5 : AppSize.hairline,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.allXs,
                      child: AppNetworkImage(
                        imageUrl: posterPath != null
                            ? '${ApiConstants.imagePathW500}$posterPath'
                            : '',
                        seed: sName,
                        width: _thumbSize,
                        height: _thumbSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      sName,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        // On the accent fill the label has to be dark; off it,
                        // it sits on glass and stays light.
                        color: isSelected
                            ? AppColors.onAccentAlt
                            : AppColors.textPrimary,
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
