import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import 'watch_form_label.dart';

// "Senin Puanın" rating slider used in the add-watch-record sheet.
class WatchRatingSlider extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const WatchRatingSlider({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WatchFormLabel(AppLocalizations.of(context).addRecordRatingLabel),
            Text(
              '$rating / 10',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.rating,
              ),
            ),
          ],
        ),
        SliderTheme(
          // Colours all come from sliderTheme now; only the geometry of this
          // particular slider is overridden — a thinner track and a smaller
          // thumb than the default, which is a deliberate look for a rating
          // scale rather than a value that drifted.
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            tickMarkShape: SliderTickMarkShape.noTickMark,
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
