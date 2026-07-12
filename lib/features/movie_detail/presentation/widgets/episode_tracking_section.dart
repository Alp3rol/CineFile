import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// "Aktif İzliyorum" TV episode tracking block (switch + stepper rows) used
// in the add-watch-record sheet. Purely presentational — all state and
// clamp/seed logic stays in the parent, which precomputes the enabled/
// disabled stepper callbacks exactly as before the split.
class EpisodeTrackingSection extends StatelessWidget {
  final bool isActivelyWatching;
  final int selectedEpisode;
  final int? totalEpisodes;
  final int episodeCount;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback? onEpisodeCountDecrement;
  final VoidCallback? onEpisodeCountIncrement;
  final VoidCallback? onSelectedEpisodeDecrement;
  final VoidCallback? onSelectedEpisodeIncrement;

  const EpisodeTrackingSection({
    super.key,
    required this.isActivelyWatching,
    required this.selectedEpisode,
    required this.totalEpisodes,
    required this.episodeCount,
    required this.onActiveChanged,
    required this.onEpisodeCountDecrement,
    required this.onEpisodeCountIncrement,
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
        else
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
                    width: 36,
                    child: Text(
                      '$episodeCount',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  _StepperButton(icon: Icons.add_rounded, onTap: onEpisodeCountIncrement),
                ],
              ),
            ],
          ),
      ],
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
