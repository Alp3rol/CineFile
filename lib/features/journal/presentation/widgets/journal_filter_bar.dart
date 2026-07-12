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
            color: isActive ? AppTheme.accentColor : Colors.white.withValues(alpha: 0.06),
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
        borderRadius: 16,
        opacity: 0.65,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = totalHours ~/ 24;
    final hours = totalHours % 24;
    final durationParts = <String>[];
    if (days > 0) durationParts.add('${days}g');
    if (hours > 0 || days == 0) durationParts.add('${hours}s');
    if (totalMinutes > 0) durationParts.add('${totalMinutes}dk');
    final durationStr = durationParts.join('');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              _buildInsightCard('Bu Ay', '$thisMonthCount Film', Icons.calendar_month_rounded, Colors.orangeAccent),
              const SizedBox(width: 8),
              _buildInsightCard('Ort. Puan', '${avgRating.toStringAsFixed(1)} ★', Icons.star_rounded, AppTheme.ratingColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInsightCard('Favori Tür', favoriteGenre, Icons.movie_filter_rounded, AppTheme.accentColor),
              const SizedBox(width: 8),
              _buildInsightCard('Toplam Süre', durationStr, Icons.hourglass_bottom_rounded, Colors.tealAccent),
            ],
          ),
        ],
      ),
    );
  }
}
