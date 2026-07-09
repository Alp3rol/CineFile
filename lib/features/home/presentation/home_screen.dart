import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/actively_watching_row.dart';
import '../../insights/presentation/insights_provider.dart';
import '../../insights/presentation/widgets/insights_charts.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../main_shell.dart';

// Lets the user tap "Başka Öner" on the suggestion card to cycle to a
// different unwatched title without waiting for the next calendar day.
final _homeSuggestionSeedProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchRecordsAsync = ref.watch(allWatchRecordsProvider);
    final recentlyAddedAsync = ref.watch(recentlyAddedMoviesProvider);
    final insights = ref.watch(insightsProvider);
    final weeklyGoal = ref.watch(weeklyGoalProvider);
    final unwatchedAsync = ref.watch(unwatchedMoviesProvider);
    final favoriteIdsAsync = ref.watch(favoriteMovieIdsProvider);
    final suggestionSeed = ref.watch(_homeSuggestionSeedProvider);

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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120), // Spacing for floating bottom bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş Geldin,',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'CineFile',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),

              // Stats Dashboard Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsDashboard(context, insights, weeklyGoal),
              ),

              // Streak Chip (only shown once a streak actually exists)
              if (insights != null && insights.currentStreak >= 1) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStreakChip(insights.currentStreak),
                ),
              ],

              // "Aktif İzlediklerin" quick-add row (hidden if nothing active)
              if ((ref.watch(activelyWatchingProvider).value ?? const []).isNotEmpty) ...[
                const SizedBox(height: 20),
                ActivelyWatchingRow(
                  onOpenDetail: (tmdbId, isTv) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MovieDetailScreen(tmdbId: tmdbId, isTv: isTv)),
                  ),
                ),
              ],

              // "Bu Hafta Ne İzlesem?" Suggestion Card (hidden if there's
              // nothing unwatched in the library to suggest)
              if (suggestion != null) ...[
                const SizedBox(height: 28),
                _buildSuggestionSectionTitle(ref),
                const SizedBox(height: 12),
                _buildSuggestionCard(context, suggestion),
              ],

              const SizedBox(height: 28),

              // Recently Watched Section
              _buildSectionTitle(context, ref, 'Son İzlediklerim'),
              const SizedBox(height: 12),
              recentlyWatched.isEmpty
                  ? _buildEmptySection('Henüz izleme kaydın yok. Keşfet\'ten film arayıp günlüğe ekleyebilirsin.')
                  : _buildRecentlyWatchedList(recentlyWatched),

              // Genre Distribution (reuses the existing Insights chart card)
              if (insights != null && insights.topGenres.isNotEmpty) ...[
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GenreChartCard(data: insights),
                ),
              ],

              const SizedBox(height: 28),

              // Recently Added Section
              _buildSectionTitle(context, ref, 'Son Eklediklerim'),
              const SizedBox(height: 12),
              recentlyAdded.isEmpty
                  ? _buildEmptySection('Henüz kütüphanene film eklemedin.')
                  : _buildRecentlyAddedList(recentlyAdded),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Stats Dashboard
  Widget _buildStatsDashboard(BuildContext context, InsightsData? insights, int weeklyGoal) {
    final totalWatchCount = insights?.totalWatchCount ?? 0;
    final averageRating = insights?.averageRating ?? 0.0;
    final thisWeekCount = insights?.thisWeekWatchCount ?? 0;
    final progress = weeklyGoal > 0 ? (thisWeekCount / weeklyGoal).clamp(0.0, 1.0) : 0.0;
    final remaining = (weeklyGoal - thisWeekCount).clamp(0, weeklyGoal);
    final goalText = totalWatchCount == 0
        ? 'Bu hafta ilk izlemeni ekle.'
        : remaining == 0
            ? 'Bu haftaki hedefine ulaştın!'
            : 'Bu hafta $remaining film/dizi daha izlemelisin.';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Switch to a vertical layout if the dashboard card's width is narrow
        final useVerticalLayout = constraints.maxWidth < 320;

        final totalStatsColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniStat('Toplam İzleme', '$totalWatchCount', Icons.movie_outlined),
            const SizedBox(height: 12),
            _buildMiniStat(
              'Ortalama Puan',
              totalWatchCount == 0 ? '-' : averageRating.toStringAsFixed(1),
              Icons.star_border_rounded,
              isRating: totalWatchCount > 0,
            ),
          ],
        );

        final weeklyGoalRow = Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  ),
                ),
                Text(
                  '$thisWeekCount/$weeklyGoal',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Haftalık Hedef',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    goalText,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (useVerticalLayout) {
          return GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Center(
                        child: _buildMiniStat('Toplam İzleme', '$totalWatchCount', Icons.movie_outlined),
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: AppTheme.borderColor,
                    ),
                    Expanded(
                      child: Center(
                        child: _buildMiniStat(
                          'Ortalama Puan',
                          totalWatchCount == 0 ? '-' : averageRating.toStringAsFixed(1),
                          Icons.star_border_rounded,
                          isRating: totalWatchCount > 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: AppTheme.borderColor, height: 1),
                const SizedBox(height: 10),
                weeklyGoalRow,
              ],
            ),
          );
        }

        // Default layout for wider screens
        return GlassContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Row(
            children: [
              // Total Stats
              Expanded(
                child: totalStatsColumn,
              ),

              // Divider Line
              Container(
                height: 70,
                width: 1,
                color: AppTheme.borderColor,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // Weekly Goal Progress
              Expanded(
                child: weeklyGoalRow,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, {bool isRating = false}) {
    return Row(
      children: [
        Icon(icon, color: isRating ? AppTheme.ratingColor : AppTheme.accentColor, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                if (isRating)
                  Text(
                    ' /10',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // 1b. Streak Chip — same visual language as insights' contribution_heatmap
  // buildStreakCard (icon + color + two-line text), reimplemented locally
  // since that function is private to its own file.
  Widget _buildStreakChip(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded, size: 22, color: Colors.orange),
          const SizedBox(width: 10),
          Text(
            '$streak günlük seri devam ediyor!',
            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 2. Section Title
  Widget _buildSectionTitle(BuildContext context, WidgetRef ref, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          TextButton(
            onPressed: () => ref.read(mainShellTabIndexProvider.notifier).state = 2, // Günlük sekmesi
            child: Text(
              'Tümünü Gör',
              style: GoogleFonts.inter(color: AppTheme.accentColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // 2b. "Bu Hafta Ne İzlesem?" section title — a refresh icon instead of
  // "Tümünü Gör" since there's no list to see, just another pick to try.
  Widget _buildSuggestionSectionTitle(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Bu Hafta Ne İzlesem?',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor, size: 20),
            onPressed: () => ref.read(_homeSuggestionSeedProvider.notifier).state++,
            tooltip: 'Başka Öner',
          ),
        ],
      ),
    );
  }

  // 2c. Suggestion Card — a single unwatched (ideally favorited) title.
  Widget _buildSuggestionCard(BuildContext context, Movie movie) {
    final tmdbId = movie.tmdbId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(tmdbId: tmdbId, isTv: movie.isTv),
            ),
          );
        },
        child: GlassContainer(
          padding: const EdgeInsets.all(14),
          borderRadius: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'poster_${tmdbId}_${movie.isTv}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppNetworkImage(
                    imageUrl: movie.posterPath != null
                        ? '${ApiConstants.imagePathW500}${movie.posterPath}'
                        : '',
                    seed: movie.title,
                    height: 120,
                    width: 84,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.releaseYear ?? "?"} • ${movie.isTv ? "Dizi" : "Film"}',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kütüphanende henüz izlemediğin bir yapım.',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // Shown when a section has no real data yet.
  Widget _buildEmptySection(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        opacity: 0.4,
        child: Row(
          children: [
            Icon(Icons.movie_filter_outlined, color: AppTheme.textSecondary.withOpacity(0.6), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Recently Watched Horizontal Scroll List
  Widget _buildRecentlyWatchedList(List<WatchRecordWithMovie> items) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final movie = item.movie;
          final record = item.record;
          final tmdbId = movie.tmdbId;
          final info = [record.watchPlace, record.watchCompanion]
              .where((s) => s != null && s.trim().isNotEmpty)
              .join(' • ');
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(tmdbId: tmdbId, isTv: movie.isTv),
                ),
              );
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster image with rating overlay
                  Stack(
                    children: [
                      Hero(
                        tag: 'poster_${tmdbId}_${movie.isTv}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AppNetworkImage(
                            imageUrl: movie.posterPath != null
                                ? '${ApiConstants.imagePathW500}${movie.posterPath}'
                                : '',
                            seed: movie.title,
                            height: 190,
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Rating Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          borderRadius: 6,
                          opacity: 0.8,
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                record.rating.toStringAsFixed(1),
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    movie.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Watch Info
                  if (info.isNotEmpty)
                    Text(
                      info,
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. Recently Added Horizontal Scroll List
  Widget _buildRecentlyAddedList(List<Movie> items) {
    return SizedBox(
      height: 235,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final movie = items[index];
          final tmdbId = movie.tmdbId;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(tmdbId: tmdbId, isTv: movie.isTv),
                ),
              );
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Hero(
                    tag: 'poster_${tmdbId}_${movie.isTv}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppNetworkImage(
                        imageUrl: movie.posterPath != null
                            ? '${ApiConstants.imagePathW500}${movie.posterPath}'
                            : '',
                        seed: movie.title,
                        height: 180,
                        width: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    movie.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Subtitle
                  Text(
                    '${movie.releaseYear ?? "?"} • ${movie.director ?? "Yönetmen Yok"}',
                    style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
