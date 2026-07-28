import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/genre_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../l10n/app_localizations.dart';

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
          _buildFilterChip(AppLocalizations.of(context).journalFilterAll, 'all', Icons.format_list_bulleted_rounded),
          const SizedBox(width: 6),
          _buildFilterChip(AppLocalizations.of(context).journalFilterFavorites, 'favorites', Icons.favorite_rounded),
          const SizedBox(width: 6),
          _buildFilterChip(AppLocalizations.of(context).journalFilterCinema, 'cinema', Icons.local_movies_rounded),
          const SizedBox(width: 6),
          _buildFilterChip(AppLocalizations.of(context).journalFilterWithNotes, 'notes', Icons.rate_review_rounded),
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
  /// Most-watched genre id, or null when nothing in the current filter has
  /// genre data. Resolved to a name here rather than upstream so it follows
  /// the user's language.
  final int? favoriteGenreId;
  final int totalHours;
  final int totalMinutes;

  const JournalMiniInsightsBar({
    super.key,
    required this.thisMonthCount,
    required this.avgRating,
    required this.favoriteGenreId,
    required this.totalHours,
    required this.totalMinutes,
  });

  // Matches HomeStatsDashboard's mini-stat treatment (icon + label/value
  // column, alternating accentColor/ratingColor, shared textTheme) so the
  // Journal's top panel reads as the same design system as Home instead of
  // four disconnected floating cards with ad-hoc colors/font sizes.
  Widget _buildStat(BuildContext context, String label, String value, IconData icon, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 30,
        width: 1,
        color: AppTheme.borderColor,
        margin: const EdgeInsets.symmetric(horizontal: 10),
      );

  @override
  Widget build(BuildContext context) {
    final days = totalHours ~/ 24;
    final hours = totalHours % 24;
    final durationParts = <String>[];
    if (days > 0) durationParts.add(AppLocalizations.of(context).durationDays(days));
    if (hours > 0 || days == 0) durationParts.add(AppLocalizations.of(context).durationHours(hours));
    if (totalMinutes > 0) durationParts.add(AppLocalizations.of(context).durationMinutes(totalMinutes));
    final durationStr = durationParts.join('');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildStat(context, AppLocalizations.of(context).journalStatThisMonth, AppLocalizations.of(context).journalMoviesCount(thisMonthCount), Icons.calendar_month_rounded, AppTheme.accentColor),
                _divider(),
                _buildStat(context, AppLocalizations.of(context).journalStatAvgRating, '${avgRating.toStringAsFixed(1)} ★', Icons.star_rounded, AppTheme.ratingColor),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppTheme.borderColor, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStat(
                  context,
                  AppLocalizations.of(context).journalStatFavoriteGenre,
                  favoriteGenreId == null
                      ? AppLocalizations.of(context).journalStatUndetermined
                      : genreName(AppLocalizations.of(context), favoriteGenreId!),
                  Icons.movie_filter_rounded,
                  AppTheme.accentColor,
                ),
                _divider(),
                _buildStat(context, AppLocalizations.of(context).journalStatTotalTime, durationStr, Icons.hourglass_bottom_rounded, AppTheme.ratingColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
