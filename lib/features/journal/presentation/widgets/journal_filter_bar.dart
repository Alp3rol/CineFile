import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

// Quick Filter Chips Bar
class JournalFiltersBar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const JournalFiltersBar({super.key, required this.activeFilter, required this.onFilterChanged});

  Widget _buildFilterChip(String label, String filterKey, IconData icon) {
    final isActive = activeFilter == filterKey;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 14,
          color: isActive ? Colors.black : AppTheme.textSecondary,
        ),
        label: Text(label),
        selected: isActive,
        onSelected: (selected) => onFilterChanged(selected ? filterKey : 'all'),
        backgroundColor: Colors.transparent,
        selectedColor: AppTheme.accentColor,
        labelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.black : Colors.white70,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isActive ? AppTheme.accentColor : AppTheme.borderColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildFilterChip('Tümü', 'all', Icons.format_list_bulleted_rounded),
          _buildFilterChip('Favoriler', 'favorites', Icons.favorite_rounded),
          _buildFilterChip('Sinemada', 'cinema', Icons.local_movies_rounded),
          _buildFilterChip('Notlu Olanlar', 'notes', Icons.rate_review_rounded),
        ],
      ),
    );
  }
}

// v0.6.1: Mini Insights Bar UI
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
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: GlassContainer(
        borderRadius: 12,
        opacity: 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildInsightCard('Bu Ay', '$thisMonthCount Film', Icons.calendar_month_rounded, Colors.orangeAccent),
          _buildInsightCard('Ort. Puan', '${avgRating.toStringAsFixed(1)} ★', Icons.star_rounded, AppTheme.ratingColor),
          _buildInsightCard('Favori Tür', favoriteGenre, Icons.movie_filter_rounded, AppTheme.accentColor),
          _buildInsightCard('Toplam Süre', '${totalHours}s ${totalMinutes}dk', Icons.hourglass_bottom_rounded, Colors.tealAccent),
        ],
      ),
    );
  }
}
