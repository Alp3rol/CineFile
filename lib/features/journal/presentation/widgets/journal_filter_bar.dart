import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

// Quick Filter Chips Bar — full-width, no horizontal scroll.
// Each chip gets an equal Expanded share of the available width.
class JournalFiltersBar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const JournalFiltersBar({super.key, required this.activeFilter, required this.onFilterChanged});

  Widget _buildFilterChip(String label, String filterKey, IconData icon) {
    final isActive = activeFilter == filterKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(isActive ? 'all' : filterKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accentColor : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppTheme.accentColor : AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: isActive ? Colors.black : AppTheme.textSecondary),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.black : Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildFilterChip('Tümü', 'all', Icons.format_list_bulleted_rounded),
          const SizedBox(width: 6),
          _buildFilterChip('Favoriler', 'favorites', Icons.favorite_rounded),
          const SizedBox(width: 6),
          _buildFilterChip('Sinemada', 'cinema', Icons.local_movies_rounded),
          const SizedBox(width: 6),
          _buildFilterChip('Notlu Olanlar', 'notes', Icons.rate_review_rounded),
        ],
      ),
    );
  }
}

// v0.6.1: Mini Insights Bar UI — full-width, no horizontal scroll.
// Each card gets an equal Expanded share; IntrinsicHeight keeps rows aligned.
class JournalMiniInsightsBar extends StatelessWidget {
  final int thisMonthCount;
  final double avgRating;
  final String favoriteGenre;
  final int totalHours;
  final int totalMinutes;

  const JournalMiniInsightsBar({
    super.key,
    required this.thisMonthCount,
    required this.avgRating,
    required this.favoriteGenre,
    required this.totalHours,
    required this.totalMinutes,
  });

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassContainer(
        borderRadius: 12,
        opacity: 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInsightCard('Bu Ay', '$thisMonthCount Film', Icons.calendar_month_rounded, Colors.orangeAccent),
            const SizedBox(width: 8),
            _buildInsightCard('Ort. Puan', '${avgRating.toStringAsFixed(1)} ★', Icons.star_rounded, AppTheme.ratingColor),
            const SizedBox(width: 8),
            _buildInsightCard('Favori Tür', favoriteGenre, Icons.movie_filter_rounded, AppTheme.accentColor),
            const SizedBox(width: 8),
            _buildInsightCard('Toplam Süre', '${totalHours}s ${totalMinutes}dk', Icons.hourglass_bottom_rounded, Colors.tealAccent),
          ],
        ),
      ),
    );
  }
}
