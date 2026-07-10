import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';

// Read-only "Aktif İzliyorum" / "Tamamlandı" indicator for TV shows.
// Actual state is only changed via the Add Watch Record flow.
class MovieWatchStatusBadge extends StatelessWidget {
  final UserMovieSetting? setting;
  final int? totalEpisodes;

  const MovieWatchStatusBadge({super.key, required this.setting, required this.totalEpisodes});

  @override
  Widget build(BuildContext context) {
    final setting = this.setting;
    final totalEpisodes = this.totalEpisodes;
    if (setting == null) return const SizedBox.shrink();

    String? label;
    IconData icon = Icons.play_circle_fill_rounded;
    Color color = AppTheme.accentColor;

    if (setting.isActivelyWatching) {
      final last = setting.lastWatchedEpisode ?? 0;
      label = totalEpisodes != null ? 'İzleniyor ($last/$totalEpisodes)' : 'İzleniyor (Bölüm $last)';
    } else if (totalEpisodes != null && setting.lastWatchedEpisode != null && setting.lastWatchedEpisode! >= totalEpisodes) {
      label = 'Tamamlandı';
      icon = Icons.check_circle_rounded;
      color = Colors.greenAccent;
    }

    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
