import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// "Aktif İzliyorum" TV episode tracking block (switch + stepper rows +
// manual episode-count entry) used in the add-watch-record sheet. Purely
// presentational — all state and clamp/seed logic stays in the parent, which
// precomputes the enabled/disabled stepper callbacks exactly as before the
// split.
class EpisodeTrackingSection extends StatelessWidget {
  final bool isActivelyWatching;
  final int selectedEpisode;
  final int? totalEpisodes;
  final TextEditingController episodeCountController;
  final bool finishedWholeShow;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onFinishedWholeShowChanged;
  final VoidCallback? onEpisodeCountDecrement;
  final VoidCallback? onEpisodeCountIncrement;
  final ValueChanged<String> onEpisodeCountTextChanged;
  final VoidCallback? onSelectedEpisodeDecrement;
  final VoidCallback? onSelectedEpisodeIncrement;

  const EpisodeTrackingSection({
    super.key,
    required this.isActivelyWatching,
    required this.selectedEpisode,
    required this.totalEpisodes,
    required this.episodeCountController,
    required this.finishedWholeShow,
    required this.onActiveChanged,
    required this.onFinishedWholeShowChanged,
    required this.onEpisodeCountDecrement,
    required this.onEpisodeCountIncrement,
    required this.onEpisodeCountTextChanged,
    required this.onSelectedEpisodeDecrement,
    required this.onSelectedEpisodeIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktif İzliyorum',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            Switch(
              value: isActivelyWatching,
              activeThumbColor: AppTheme.accentColor,
              onChanged: onActiveChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isActivelyWatching)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bölüm $selectedEpisode${totalEpisodes != null ? ' / $totalEpisodes' : ''}',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Row(
                children: [
                  _StepperButton(icon: Icons.remove_rounded, onTap: onSelectedEpisodeDecrement),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$selectedEpisode',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  _StepperButton(icon: Icons.add_rounded, onTap: onSelectedEpisodeIncrement),
                ],
              ),
            ],
          )
        else ...[
          // Whether TMDb gave us a total episode count decides if "finished
          // the whole show" is even offerable — without a total there's
          // nothing to mark "finished" against, so fall straight back to the
          // manual episode-count stepper.
          if (totalEpisodes != null)
            Row(
              children: [
                Expanded(
                  child: _ChoiceChip(
                    label: 'Tüm sezonu bitirdim',
                    selected: finishedWholeShow,
                    onTap: () => onFinishedWholeShowChanged(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ChoiceChip(
                    label: 'Belirli sayıda bölüm',
                    selected: !finishedWholeShow,
                    onTap: () => onFinishedWholeShowChanged(false),
                  ),
                ),
              ],
            ),
          if (totalEpisodes == null || !finishedWholeShow) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kaç bölüm izledin?',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                Row(
                  children: [
                    _StepperButton(icon: Icons.remove_rounded, onTap: onEpisodeCountDecrement),
                    SizedBox(
                      width: 56,
                      child: TextField(
                        key: const Key('episodeCountField'),
                        controller: episodeCountController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                        ),
                        onChanged: onEpisodeCountTextChanged,
                      ),
                    ),
                    _StepperButton(icon: Icons.add_rounded, onTap: onEpisodeCountIncrement),
                  ],
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.accentColor : Colors.grey.shade800, width: 1),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppTheme.accentColor : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isEnabled ? AppTheme.accentColor : Colors.grey.shade800, width: 1),
        ),
        child: Icon(icon, size: 16, color: isEnabled ? AppTheme.accentColor : Colors.grey.shade700),
      ),
    );
  }
}
