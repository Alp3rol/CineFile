import 'package:flutter/material.dart';
import '../../../../core/l10n/genre_names.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../search_provider.dart';

class SearchAdvancedFilterBar extends StatelessWidget {
  final SearchState state;
  final List<int> genreIds;
  final ValueChanged<int?> onGenreSelected;
  final ValueChanged<String> onMediaTypeChanged;
  final ValueChanged<double?> onMinRatingChanged;
  final ValueChanged<String?> onDecadeChanged;

  const SearchAdvancedFilterBar({
    super.key,
    required this.state,
    required this.genreIds,
    required this.onGenreSelected,
    required this.onMediaTypeChanged,
    required this.onMinRatingChanged,
    required this.onDecadeChanged,
  });

  Widget _chip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isSelected
                ? AppColors.accent
                : AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isSelected ? AppColors.onAccent : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppColors.onAccent : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 20,
        width: 1,
        color: AppColors.border,
        margin: const EdgeInsets.symmetric(horizontal: 6),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 36,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Media Type
          _chip(
            context: context,
            label: l10n.searchFilterAll,
            isSelected: state.mediaTypeFilter == 'all',
            onTap: () => onMediaTypeChanged('all'),
          ),
          _chip(
            context: context,
            label: l10n.searchFilterMovies,
            icon: Icons.movie_outlined,
            isSelected: state.mediaTypeFilter == 'movie',
            onTap: () => onMediaTypeChanged('movie'),
          ),
          _chip(
            context: context,
            label: l10n.searchFilterTv,
            icon: Icons.tv_outlined,
            isSelected: state.mediaTypeFilter == 'tv',
            onTap: () => onMediaTypeChanged('tv'),
          ),

          _divider(),

          // 2. Min Rating
          _chip(
            context: context,
            label: l10n.searchFilterMinRating('7.0'),
            icon: Icons.star_rounded,
            isSelected: state.minRating == 7.0,
            onTap: () => onMinRatingChanged(state.minRating == 7.0 ? null : 7.0),
          ),
          _chip(
            context: context,
            label: l10n.searchFilterMinRating('8.0'),
            icon: Icons.star_rounded,
            isSelected: state.minRating == 8.0,
            onTap: () => onMinRatingChanged(state.minRating == 8.0 ? null : 8.0),
          ),

          _divider(),

          // 3. Decades
          _chip(
            context: context,
            label: l10n.searchFilterDecade2020s,
            isSelected: state.decadeFilter == '2020s',
            onTap: () => onDecadeChanged(state.decadeFilter == '2020s' ? null : '2020s'),
          ),
          _chip(
            context: context,
            label: l10n.searchFilterDecade2010s,
            isSelected: state.decadeFilter == '2010s',
            onTap: () => onDecadeChanged(state.decadeFilter == '2010s' ? null : '2010s'),
          ),
          _chip(
            context: context,
            label: l10n.searchFilterDecade2000s,
            isSelected: state.decadeFilter == '2000s',
            onTap: () => onDecadeChanged(state.decadeFilter == '2000s' ? null : '2000s'),
          ),
          _chip(
            context: context,
            label: l10n.searchFilterDecadeClassics,
            isSelected: state.decadeFilter == 'classics',
            onTap: () => onDecadeChanged(state.decadeFilter == 'classics' ? null : 'classics'),
          ),

          _divider(),

          // 4. Genres
          ...genreIds.map((id) {
            final isSelected = state.selectedGenreId == id;
            return _chip(
              context: context,
              label: genreName(l10n, id),
              isSelected: isSelected,
              onTap: () => onGenreSelected(isSelected ? null : id),
            );
          }),
        ],
      ),
    );
  }
}
