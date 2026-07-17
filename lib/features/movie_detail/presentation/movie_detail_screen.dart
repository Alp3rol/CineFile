import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/dynamic_background_wrapper.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/dynamic_background_provider.dart';
import '../../main_shell.dart';
import 'movie_detail_provider.dart';
import 'add_watch_record_sheet.dart';
import 'widgets/movie_detail_action_widgets.dart';
import 'widgets/movie_detail_backdrop.dart';
import 'widgets/movie_detail_cast_list.dart';
import 'widgets/movie_detail_floating_header.dart';
import 'widgets/movie_detail_header_row.dart';
import 'widgets/movie_detail_timeline_section.dart';
import 'widgets/tv_episodes_section.dart';
import 'widgets/rank_dialog.dart';
import '../../journal/presentation/widgets/add_to_list_sheet.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../../core/services/notification_service.dart';
import 'package:drift/drift.dart' show Value;
import '../../settings/presentation/settings_provider.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final int tmdbId;
  final bool isTv;

  const MovieDetailScreen({super.key, required this.tmdbId, this.isTv = false});

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  int get tmdbId => widget.tmdbId;
  bool get isTv => widget.isTv;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;
    final offset = _scrollController.offset;
    // backdropOpacity/backdropTop (derived from _scrollOffset below) are
    // saturated outside the [0, 200] range — opacity is already 0 past 200px
    // and already 1 at/below 0px, so once both the old and new offset land
    // in the same saturated zone, nothing visible actually changes. Skipping
    // the rebuild there avoids re-laying-out the backdrop stack on every
    // scroll pixel once the user has scrolled past the hero.
    final wasSaturatedLow = _scrollOffset <= 0;
    final wasSaturatedHigh = _scrollOffset >= 200;
    final isSaturatedLow = offset <= 0;
    final isSaturatedHigh = offset >= 200;
    if ((wasSaturatedLow && isSaturatedLow) || (wasSaturatedHigh && isSaturatedHigh)) {
      _scrollOffset = offset;
      return;
    }
    setState(() {
      _scrollOffset = offset;
    });
  }

  // Toggle Favorite Status
  Future<void> _toggleFavorite(WidgetRef ref, Map<String, dynamic> movieData) async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    if (user == null) return;

    final settings = ref.read(movieSettingsProvider((tmdbId: tmdbId, isTv: isTv))).value;
    final isFavorite = settings?.isFavorite ?? false;

    try {
      final settingsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .doc('${tmdbId}_$isTv');

      await settingsRef.set({
        'movieId': tmdbId,
        'isTv': isTv,
        'isFavorite': !isFavorite,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Favori durumu güncellenemedi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favori durumu güncellenemedi. Lütfen tekrar deneyin.')),
        );
      }
    }
  }

  Future<void> _toggleWatchlist(WidgetRef ref, Map<String, dynamic> movieData) async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    if (user == null) return;

    final settings = ref.read(movieSettingsProvider((tmdbId: tmdbId, isTv: isTv))).value;
    final isReWatchList = settings?.isReWatchList ?? false;

    final releaseDateStr = (isTv
        ? movieData['first_air_date']
        : movieData['release_date']) as String? ?? '';

    try {
      final settingsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .doc('${tmdbId}_$isTv');

      await settingsRef.set({
        'movieId': tmdbId,
        'isTv': isTv,
        'isReWatchList': !isReWatchList,
        'releaseDate': releaseDateStr,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Ensure local movies table entry exists
      final db = ref.read(databaseProvider);
      final releaseYear = int.tryParse(releaseDateStr.split('-').first) ?? 0;
      final genres = movieData['genres'] as List<dynamic>?;
      final genresString = genres?.map((e) => e['name']).join(', ') ?? '';

      final crew = movieData['credits']?['crew'] as List<dynamic>?;
      final directorName = crew?.where((e) => e['job'] == 'Director').firstOrNull?['name'] as String? ?? 'Bilinmiyor';

      final cast = movieData['credits']?['cast'] as List<dynamic>?;
      final actorsString = cast?.take(5).map((e) => e['name']).join(', ') ?? '';

      await db.into(db.movies).insertOnConflictUpdate(
        MoviesCompanion.insert(
          tmdbId: tmdbId,
          title: (isTv ? (movieData['name'] ?? movieData['original_name']) : (movieData['title'] ?? movieData['original_title'])) as String? ?? 'Bilinmeyen Yapım',
          originalTitle: Value(movieData['original_title'] as String? ?? movieData['original_name'] as String?),
          posterPath: Value(movieData['poster_path'] as String?),
          backdropPath: Value(movieData['backdrop_path'] as String?),
          releaseYear: Value(releaseYear),
          runtime: Value(movieData['runtime'] as int? ?? 0),
          genres: Value(genresString),
          director: Value(directorName),
          actors: Value(actorsString),
          overview: Value(movieData['overview'] as String?),
          isTv: Value(isTv),
        ),
      );

      // Trigger local notifications schedule/cancel
      final remindersEnabled = ref.read(releaseRemindersEnabledProvider);
      if (remindersEnabled && releaseDateStr.isNotEmpty) {
        final parsedDate = DateTime.tryParse(releaseDateStr);
        if (parsedDate != null) {
          if (!isReWatchList) {
            if (parsedDate.isAfter(DateTime.now())) {
              await ref.read(notificationServiceProvider).scheduleReleaseReminder(
                id: tmdbId,
                title: (isTv ? (movieData['name'] ?? movieData['original_name']) : (movieData['title'] ?? movieData['original_title'])) as String? ?? 'Bilinmeyen Yapım',
                releaseDate: parsedDate,
                isTv: isTv,
              );
            }
          } else {
            await ref.read(notificationServiceProvider).cancelReleaseReminder(tmdbId, isTv);
          }
        }
      }
    } catch (e) {
      debugPrint('İzleme listesi güncellenemedi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İzleme listesi güncellenemedi. Lütfen tekrar deneyin.')),
        );
      }
    }
  }

  // Delete Watch Record
  Future<void> _deleteRecord(BuildContext context, WidgetRef ref, int recordId) async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('logs')
          .where('userId', isEqualTo: user.uid)
          .where('movieId', isEqualTo: tmdbId)
          .where('isTv', isEqualTo: isTv)
          .get();

      for (final doc in snapshot.docs) {
        if (doc.id.hashCode == recordId) {
          await doc.reference.delete();
          break;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İzleme kaydı silindi.'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Restore parent screen colors on pop.
    // Wrapped in try/catch because ref may be invalid during widget teardown in tests.
    try {
      final activeTab = ref.read(mainShellTabIndexProvider);
      if (activeTab == 0) {
        final records = ref.read(allWatchRecordsProvider).value ?? const [];
        final seenKeys = <MovieKey>{};
        final last3 = <Movie>[];
        for (final r in records) {
          if (seenKeys.add((tmdbId: r.movie.tmdbId, isTv: r.movie.isTv))) {
            last3.add(r.movie);
            if (last3.length >= 3) break;
          }
        }
        ref.read(dynamicBackgroundProvider.notifier).updateMoviesFromList(last3);
      } else {
        ref.read(dynamicBackgroundProvider.notifier).clearColors();
      }
    } catch (_) {
      // ref is no longer valid during widget teardown — safe to ignore
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(movieDetailProvider((tmdbId: tmdbId, isTv: isTv)));
    final watchRecordsAsync = ref.watch(watchRecordsForMovieProvider((tmdbId: tmdbId, isTv: isTv)));
    final settingsAsync = ref.watch(movieSettingsProvider((tmdbId: tmdbId, isTv: isTv)));

    // Update background color based on movie detail data (after build)
    final movieDataValue = detailAsync.value;
    if (movieDataValue != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(dynamicBackgroundProvider.notifier).updateMoviesFromMapList([movieDataValue]);
      });
    }

    return DynamicBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: detailAsync.maybeWhen(
          data: (movieData) => movieData == null
              ? null
              : MovieDetailStickyCta(onTap: () => _openAddWatchRecordSheet(context, movieData)),
          orElse: () => null,
        ),
        body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
        error: (error, stack) => Center(child: Text('Hata: $error', style: const TextStyle(color: Colors.white))),
        data: (movieData) {
          if (movieData == null) {
            return const Center(child: Text('Film detayları bulunamadı.', style: TextStyle(color: Colors.white)));
          }

          final backdropPath = movieData['backdrop_path'] as String?;
          final posterPath = movieData['poster_path'] as String?;
          final title = movieData['title'] as String;
          final tagline = movieData['tagline'] as String? ?? '';
          final overview = movieData['overview'] as String? ?? 'Özet bulunmuyor.';

          final releaseDateStr = movieData['release_date'] as String? ?? '';
          final year = releaseDateStr.split('-').first;
          final runtime = movieData['runtime'] as int? ?? 0;

          final genres = movieData['genres'] as List<dynamic>?;
          final genresString = genres?.map((e) => e['name']).join(', ') ?? '';

          final crew = movieData['credits']?['crew'] as List<dynamic>?;
          final director = crew?.where((e) => e['job'] == 'Director').firstOrNull?['name'] as String? ?? 'Bilinmiyor';

          final cast = movieData['credits']?['cast'] as List<dynamic>?;

          final voteAverage = movieData['vote_average'] as num?;
          final voteCount = movieData['vote_count'] as int?;

          final isFavorite = settingsAsync.value?.isFavorite ?? false;
          final isReWatchList = settingsAsync.value?.isReWatchList ?? false;
          // watchRecordsForMovieProvider already orders by watchDate desc.
          final latestRecord = watchRecordsAsync.value?.firstOrNull;

          final double backdropOpacity = (1.0 - (_scrollOffset / 200.0)).clamp(0.0, 1.0);
          final double backdropTop = _scrollOffset < 0 ? 0.0 : -_scrollOffset;

          return Stack(
            children: [
              // 1. Blurred Backdrop + Fading Mask — see MovieDetailBackdrop's
              // doc comment for why this stays a single always-present
              // Positioned entry regardless of backdropPath/opacity.
              Positioned(
                top: backdropTop,
                left: 0,
                right: 0,
                height: 480,
                child: MovieDetailBackdrop(
                  backdropPath: backdropPath,
                  opacity: backdropOpacity,
                  width: MediaQuery.of(context).size.width,
                ),
              ),

              // 2. Main Scrollable Content
              Positioned.fill(
                child: SafeArea(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 72, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MovieDetailHeaderRow(
                          tmdbId: tmdbId,
                          isTv: isTv,
                          posterPath: posterPath,
                          title: title,
                          tagline: tagline,
                          year: year,
                          runtime: runtime,
                          genresString: genresString,
                          voteAverage: voteAverage,
                          voteCount: voteCount,
                          settings: settingsAsync.value,
                          totalEpisodes: movieData['number_of_episodes'] as int?,
                        ),
                        const SizedBox(height: 20),

                        // 3-up info cards: my rating / director / watch place
                        Row(
                          children: [
                            Expanded(
                              child: MovieInfoCard(
                                icon: Icons.star_rounded,
                                iconColor: AppTheme.ratingColor,
                                value: latestRecord != null ? latestRecord.rating.toStringAsFixed(1) : '—',
                                label: 'Puanım',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MovieInfoCard(
                                icon: Icons.movie_creation_outlined,
                                iconColor: Colors.white,
                                value: director,
                                label: 'Yönetmen',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MovieInfoCard(
                                icon: Icons.location_on_outlined,
                                iconColor: Colors.white,
                                value: latestRecord?.watchPlace ?? '—',
                                label: 'Ortam',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Quick actions row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MovieQuickActionButton(
                              icon: Icons.add_rounded,
                              label: 'Günlüğe Ekle',
                              isPrimary: true,
                              onTap: () => _openAddWatchRecordSheet(context, movieData),
                            ),
                            MovieQuickActionButton(
                              icon: Icons.bookmark_add_outlined,
                              label: 'Listeye Ekle',
                              onTap: () {
                                final movie = Movie(
                                  tmdbId: tmdbId,
                                  title: title,
                                  originalTitle: movieData['original_title'] as String?,
                                  posterPath: posterPath,
                                  backdropPath: backdropPath,
                                  releaseYear: int.tryParse(year),
                                  runtime: runtime,
                                  genres: genresString,
                                  director: director,
                                  actors: cast?.take(5).map((e) => e['name']).join(', '),
                                  overview: overview,
                                  isTv: isTv,
                                  createdAt: DateTime.now(),
                                );
                                AddToListSheet.show(context, movie);
                              },
                            ),
                            MovieQuickActionButton(
                              icon: Icons.share_rounded,
                              label: 'Paylaş',
                              onTap: () => _shareMovie(title, tmdbId),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Overview (Konu) Section
                        Text(
                          'Özet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          overview,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        MovieDetailCastList(cast: cast, movieData: movieData),

                        if (isTv) ...[
                          const SizedBox(height: 28),
                          MovieDetailTvEpisodesSection(
                            movie: Movie(
                              tmdbId: tmdbId,
                              title: title,
                              originalTitle: movieData['original_title'] as String? ?? movieData['original_name'] as String?,
                              posterPath: posterPath,
                              backdropPath: backdropPath,
                              releaseYear: int.tryParse(year),
                              runtime: runtime,
                              genres: genresString,
                              director: director,
                              actors: cast?.take(5).map((e) => e['name']).join(', '),
                              overview: overview,
                              isTv: isTv,
                              createdAt: DateTime.now(),
                            ),
                            seasons: movieData['seasons'] as List<dynamic>? ?? const [],
                            settings: settingsAsync.value,
                            totalEpisodes: movieData['number_of_episodes'] as int?,
                          ),
                        ],

                        MovieDetailTimelineSection(
                          watchRecordsAsync: watchRecordsAsync,
                          onDelete: (recordId) => _deleteRecord(context, ref, recordId),
                        ),

                        // TMDB Atıf
                        const SizedBox(height: 20),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Veriler ',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Image.asset(
                                'assets/images/tmdb_logo.png',
                                height: 10,
                                fit: BoxFit.contain,
                              ),
                              Text(
                                ' tarafından sağlanmaktadır.',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Sticky Floating Header Buttons
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: MovieDetailFloatingHeader(
                  onBack: () => Navigator.pop(context),
                  onToggleWatchlist: () => _toggleWatchlist(ref, movieData),
                  isReWatchList: isReWatchList,
                  onToggleFavorite: () => _toggleFavorite(ref, movieData),
                  isFavorite: isFavorite,
                  onRankTap: () => showRankDialog(context, ref, tmdbId: tmdbId, isTv: isTv, movieData: movieData, settings: settingsAsync.value),
                  personalRanking: settingsAsync.value?.personalRanking,
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  void _openAddWatchRecordSheet(BuildContext context, Map<String, dynamic> movieData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWatchRecordSheet(movieData: movieData),
    );
  }

  Future<void> _shareMovie(String title, int tmdbId) async {
    await SharePlus.instance.share(
      ShareParams(text: '$title — CineFile\nhttps://www.themoviedb.org/movie/$tmdbId'),
    );
  }
}
