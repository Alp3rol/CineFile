import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/analytics/product_analytics.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/poster_grid.dart';
import '../../../../core/network/tmdb_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../search_provider.dart';
import '../trending_provider.dart';
import '../../../swipe_discovery/presentation/swipe_discovery_screen.dart';
import '../../../recommendations/presentation/recommendations_provider.dart';
import '../../../settings/presentation/settings_provider.dart';

// Loading/error/empty-query/no-results/results-grid states for
// SearchScreen's main body, driven by SearchState plus the already
// genre-filtered results list (filtering itself stays in SearchScreen,
// which also owns the currentUser-independent dynamic-background sync).
class SearchResultsView extends ConsumerWidget {
  final SearchState state;
  final List<Map<String, dynamic>> results;
  final ScrollController scrollController;

  const SearchResultsView({
    super.key,
    required this.state,
    required this.results,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      );
    }

    final failure = state.failure;
    if (failure != null) {
      return AppErrorState(
        isOffline: failure == TmdbFailure.network,
        title: switch (failure) {
          TmdbFailure.network => l10n.searchErrorNetwork,
          TmdbFailure.invalidApiKey => l10n.searchErrorInvalidApiKey,
          TmdbFailure.unknown => l10n.searchErrorUnknown,
        },
        onRetry: () => ref.read(searchProvider.notifier).search(state.query),
      );
    }

    // Default view: If search is empty, show a discoverable trend/popular/top-rated grid
    if (state.query.trim().isEmpty) {
      final trendingAsync = ref.watch(trendingProvider);
      final category = ref.watch(discoverCategoryProvider);
      final timeWindow = ref.watch(discoverTimeWindowProvider);
      return trendingAsync.when(
        data: (items) {
          if (items.isEmpty) return _buildStaticEmptyState(l10n);

          final mediaFilter = ref.watch(discoverMediaFilterProvider);
          final filtered = switch (mediaFilter) {
            DiscoverMediaFilter.all => items,
            DiscoverMediaFilter.movie =>
              items.where((m) => m['media_type'] != 'tv').toList(),
            DiscoverMediaFilter.tv =>
              items.where((m) => m['media_type'] == 'tv').toList(),
          };

          return Column(
            children: [
              _buildSwipeDiscoveryEntry(context, ref, filtered),
              const SizedBox(height: 8),
              _buildCategoryTimeRow(l10n, ref, category, timeWindow),
              const SizedBox(height: 8),
              _buildMediaFilterRow(l10n, ref, mediaFilter),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _headingFor(l10n, category, timeWindow),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _buildFilteredEmptyState(l10n)
                    : PosterGrid(
                        items: filtered,
                        scrollController: scrollController,
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentColor),
        ),
        error: (e, st) => _buildStaticEmptyState(l10n),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.searchNoResultsTitle,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.searchNoResultsHint,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Grid presentation (Letterboxd stili 3'lü poster grid)
    return PosterGrid(
      items: results,
      scrollController: scrollController,
      onItemOpened: () => ref
          .read(productAnalyticsProvider)
          .log(ProductEvent.searchResultOpened),
    );
  }

  Widget _buildSwipeDiscoveryEntry(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> items,
  ) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Material(
        color: AppTheme.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: items.isEmpty
              ? null
              : () => _openSwipeDiscovery(context, ref, items),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.style_rounded, color: AppTheme.accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.swipeDiscoverTitle,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.swipeDiscoverEntryHint,
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSwipeDiscovery(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> fallbackItems,
  ) async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentColor),
        ),
      ),
    );

    final merged = await _loadSwipeItems(ref, fallbackItems);

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SwipeDiscoveryScreen(
          items: merged,
          onRefresh: () async {
            ref.invalidate(recommendationsProvider);
            return _loadSwipeItems(ref, fallbackItems);
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadSwipeItems(
    WidgetRef ref,
    List<Map<String, dynamic>> fallbackItems,
  ) async {
    final merged = <String, Map<String, dynamic>>{};
    try {
      final recommendations = await ref.read(recommendationsProvider.future);
      for (final item in recommendations) {
        merged['${item.tmdbId}_${item.isTv}'] = {
          'id': item.tmdbId,
          'title': item.title,
          'poster_path': item.posterPath,
          'backdrop_path': item.backdropPath,
          'vote_average': item.voteAverage,
          'media_type': item.isTv ? 'tv' : 'movie',
          'recommendation_reason': item.reason,
          'genre_ids': item.genreIds,
        };
      }
    } catch (_) {
      // The current Discover selection below remains a useful fallback when
      // personalized recommendations cannot be loaded.
    }
    for (final item in fallbackItems) {
      final isTv = item['media_type'] == 'tv';
      merged.putIfAbsent('${item['id']}_$isTv', () => item);
    }

    return merged.values.toList();
  }

  String _headingFor(
    AppLocalizations l10n,
    DiscoverCategory category,
    DiscoverTimeWindow timeWindow,
  ) {
    switch (category) {
      case DiscoverCategory.trend:
        return timeWindow == DiscoverTimeWindow.today
            ? l10n.discoverHeadingTrendToday
            : l10n.discoverHeadingTrendThisWeek;
      case DiscoverCategory.popular:
        return l10n.discoverHeadingPopular;
      case DiscoverCategory.topRated:
        return l10n.discoverHeadingTopRated;
    }
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.white70,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.accentColor,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppTheme.borderColor,
        ),
      ),
    );
  }

  Widget _chipPadded(Widget chip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: chip,
    );
  }

  Widget _buildCategoryTimeRow(
    AppLocalizations l10n,
    WidgetRef ref,
    DiscoverCategory category,
    DiscoverTimeWindow timeWindow,
  ) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chipPadded(
            _chip(
              label: l10n.discoverCategoryTrend,
              isSelected: category == DiscoverCategory.trend,
              onSelected: (selected) {
                if (selected) {
                  ref.read(discoverCategoryProvider.notifier).state =
                      DiscoverCategory.trend;
                }
              },
            ),
          ),
          if (category == DiscoverCategory.trend) ...[
            _chipPadded(
              _chip(
                label: l10n.discoverWindowThisWeek,
                isSelected: timeWindow == DiscoverTimeWindow.week,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(discoverTimeWindowProvider.notifier).state =
                        DiscoverTimeWindow.week;
                  }
                },
              ),
            ),
            _chipPadded(
              _chip(
                label: l10n.discoverWindowToday,
                isSelected: timeWindow == DiscoverTimeWindow.today,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(discoverTimeWindowProvider.notifier).state =
                        DiscoverTimeWindow.today;
                  }
                },
              ),
            ),
          ],
          _chipPadded(
            _chip(
              label: l10n.discoverCategoryPopular,
              isSelected: category == DiscoverCategory.popular,
              onSelected: (selected) {
                if (selected) {
                  ref.read(discoverCategoryProvider.notifier).state =
                      DiscoverCategory.popular;
                }
              },
            ),
          ),
          _chipPadded(
            _chip(
              label: l10n.discoverCategoryTopRated,
              isSelected: category == DiscoverCategory.topRated,
              onSelected: (selected) {
                if (selected) {
                  ref.read(discoverCategoryProvider.notifier).state =
                      DiscoverCategory.topRated;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaFilterRow(
    AppLocalizations l10n,
    WidgetRef ref,
    DiscoverMediaFilter mediaFilter,
  ) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chipPadded(
            _chip(
              label: l10n.discoverFilterAll,
              isSelected: mediaFilter == DiscoverMediaFilter.all,
              onSelected: (selected) {
                if (selected) {
                  ref.read(discoverMediaFilterProvider.notifier).state =
                      DiscoverMediaFilter.all;
                }
              },
            ),
          ),
          _chipPadded(
            _chip(
              label: l10n.discoverFilterMovies,
              isSelected: mediaFilter == DiscoverMediaFilter.movie,
              onSelected: (selected) {
                if (selected) {
                  ref.read(discoverMediaFilterProvider.notifier).state =
                      DiscoverMediaFilter.movie;
                }
              },
            ),
          ),
          _chipPadded(
            _chip(
              label: l10n.discoverFilterShows,
              isSelected: mediaFilter == DiscoverMediaFilter.tv,
              onSelected: (selected) {
                if (selected) {
                  ref.read(discoverMediaFilterProvider.notifier).state =
                      DiscoverMediaFilter.tv;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 48,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.discoverFilterEmpty,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticEmptyState(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            Icons.explore_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.searchStartTitle,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.searchStartHint,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          // TMDB Attribution
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            // The sentence used to be split into two Text widgets either side
            // of the logo. Word order around the brand name differs by
            // language, so the logo now sits above one whole sentence instead
            // of inside it.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/tmdb_logo.png',
                  height: 10,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.searchTmdbAttribution,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
