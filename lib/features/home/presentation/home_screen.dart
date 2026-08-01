import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/theme/dynamic_background_provider.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/actively_watching_row.dart';
import '../../insights/presentation/insights_provider.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../main_shell.dart';
import '../../../../core/widgets/scroll_to_top_button.dart';
import 'widgets/home_header_bar.dart';
import 'widgets/home_hero_banner.dart';
import 'widgets/home_hero_carousel.dart';
import 'widgets/home_hero_shell.dart';
import 'widgets/home_stats_dashboard.dart';
import 'widgets/home_content_lists.dart';
import '../../recommendations/presentation/widgets/home_recommendations_list.dart';

// Lets the user tap "Başka Öner" on the suggestion card to cycle to a
// different unwatched title without waiting for the next calendar day.
final _homeSuggestionSeedProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Room under the last row so the floating bottom navigation bar never
  /// covers it. Deliberately off the spacing scale: it tracks the height of
  /// another widget rather than the layout rhythm.
  static const double _bottomNavClearance = 120;

  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 200;
    if (show != _showScrollToTop) {
      setState(() {
        _showScrollToTop = show;
      });
    }
  }

  void _openDetail(int tmdbId, bool isTv) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MovieDetailScreen(tmdbId: tmdbId, isTv: isTv)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final watchRecordsAsync = ref.watch(allWatchRecordsProvider);

    // Update dynamic background based on the last 3 watched movies whenever records change
    final records = watchRecordsAsync.value ?? const <WatchRecordWithMovie>[];
    final seenKeys = <MovieKey>{};
    final last3 = <Movie>[];
    for (final r in records) {
      if (seenKeys.add((tmdbId: r.movie.tmdbId, isTv: r.movie.isTv))) {
        last3.add(r.movie);
        if (last3.length >= 3) break;
      }
    }
    // Schedule update after build to avoid calling notifier during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dynamicBackgroundProvider.notifier).updateMoviesFromList(last3);
    });

    final recentlyAddedAsync = ref.watch(recentlyAddedMoviesProvider);
    final unwatchedAsync = ref.watch(unwatchedMoviesProvider);
    final favoriteIdsAsync = ref.watch(favoriteMovieIdsProvider);
    final suggestionSeed = ref.watch(_homeSuggestionSeedProvider);
    final activeShowsAsync = ref.watch(activelyWatchingProvider);
    final activeShows = activeShowsAsync.value ?? const <ActivelyWatchingShow>[];

    // allWatchRecordsProvider is already sorted by watchDate desc; keep only
    // the latest watch per movie so a re-watched title doesn't show twice.
    final seenMovieKeys = <MovieKey>{};
    final recentlyWatched = <WatchRecordWithMovie>[];
    for (final r in watchRecordsAsync.value ?? const <WatchRecordWithMovie>[]) {
      if (seenMovieKeys.add((tmdbId: r.movie.tmdbId, isTv: r.movie.isTv))) {
        recentlyWatched.add(r);
        if (recentlyWatched.length >= 10) break;
      }
    }

    final recentlyAdded = recentlyAddedAsync.value ?? const <Movie>[];

    // Prefer favorites among the unwatched titles; fall back to any
    // unwatched title. Pick deterministically per day (so it doesn't change
    // on every rebuild) plus a user-controlled seed for "Başka Öner".
    final unwatched = unwatchedAsync.value ?? const <Movie>[];
    final favoriteIds = favoriteIdsAsync.value ?? const <MovieKey>{};
    final favoriteUnwatched = unwatched.where((m) => favoriteIds.contains((tmdbId: m.tmdbId, isTv: m.isTv))).toList();
    final suggestionCandidates = favoriteUnwatched.isNotEmpty ? favoriteUnwatched : unwatched;
    Movie? suggestion;
    if (suggestionCandidates.isNotEmpty) {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      final index = (dayOfYear + suggestionSeed) % suggestionCandidates.length;
      suggestion = suggestionCandidates[index];
    }

    // When there's nothing left unwatched to suggest, fall back to the most
    // recently watched title so the hero stays a permanent visual anchor
    // instead of disappearing once a user has watched everything they added.
    final heroMovie = suggestion ?? (recentlyWatched.isNotEmpty ? recentlyWatched.first.movie : null);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, _) {
                final insights = ref.watch(insightsProvider);
                return HomeHeaderBar(streak: insights?.currentStreak ?? 0);
              },
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: _bottomNavClearance),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xs),

                    // Cinematic hero — the screen's top visual anchor.
                    // Highest priority: any actively-watching shows, shown as
                    // a swipeable carousel. Otherwise prefers a "Bu Hafta Ne
                    // İzlesem?" suggestion, falling back to the most recently
                    // watched title so it doesn't disappear once nothing
                    // unwatched is left in the library. Hidden only when
                    // there's no data at all yet.
                    if ((activeShowsAsync.isLoading && activeShows.isEmpty) ||
                        (watchRecordsAsync.isLoading && recentlyWatched.isEmpty)) ...[
                      // Reserves exactly the hero's height so the rest of the
                      // page does not jump when the hero resolves. Colour comes
                      // from progressIndicatorTheme.
                      const SizedBox(
                        height: HomeHeroShell.height,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ] else if (activeShows.isNotEmpty) ...[
                      HomeActiveHeroCarousel(shows: activeShows, onTap: _openDetail),
                      const SizedBox(height: AppSpacing.xl),
                    ] else if (heroMovie != null) ...[
                      HomeHeroBanner(
                        movie: heroMovie,
                        isSuggestion: suggestion != null,
                        onRefresh:
                            suggestion != null ? () => ref.read(_homeSuggestionSeedProvider.notifier).state++ : null,
                        onTap: () => _openDetail(heroMovie.tmdbId, heroMovie.isTv),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // Premium Redesigned Stats Dashboard
                    Consumer(
                      builder: (context, ref, _) {
                        final insights = ref.watch(insightsProvider);
                        final weeklyGoal = ref.watch(weeklyGoalProvider);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: HomeStatsDashboard(insights: insights, weeklyGoal: weeklyGoal),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Recently Added Section
                    HomeSectionTitle(
                      title: AppLocalizations.of(context).homeRecentlyAdded,
                      onSeeAll: () => ref.read(mainShellTabIndexProvider.notifier).state = 2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                     recentlyAdded.isEmpty
                        ? HomeEmptySection(message: AppLocalizations.of(context).homeNothingAdded)
                        : HomeRecentlyAddedList(items: recentlyAdded, onOpenDetail: _openDetail),

                    const SizedBox(height: AppSpacing.xl),
                    HomeRecommendationsList(onOpenDetail: _openDetail),

                    // "Aktif İzlediklerin" quick-add row (hidden if nothing active).
                    // Intentionally shows all active shows even if one of
                    // them is already highlighted in the hero above.
                    if (activeShows.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      ActivelyWatchingRow(onOpenDetail: _openDetail),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScrollToTopButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        show: _showScrollToTop,
      ),
    );
  }
}
