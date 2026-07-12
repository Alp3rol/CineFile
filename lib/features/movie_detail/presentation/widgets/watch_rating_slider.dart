import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// "Senin Puanın" rating slider used in the add-watch-record sheet.
class WatchRatingSlider extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const WatchRatingSlider({super.key, required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Senin Puanın:',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            Text(
              '$rating / 10',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.ratingColor,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0, // Thinner track
            activeTrackColor: AppTheme.accentColor,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
            thumbColor: AppTheme.ratingColor,
            overlayColor: AppTheme.ratingColor.withValues(alpha: 0.12),
            valueIndicatorColor: AppTheme.surfaceColor,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6.0, // Smaller thumb
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 16.0,
            ),
            tickMarkShape: SliderTickMarkShape.noTickMark, // Hide tick marks for a cleaner look
            valueIndicatorTextStyle: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          child: Slider(
            value: rating,
            min: 1.0,
            max: 10.0,
            divisions: 18, // 0.5 steps
            label: rating.toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
