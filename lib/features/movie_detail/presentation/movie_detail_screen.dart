import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/dynamic_background_wrapper.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/dynamic_background_provider.dart';
import '../../main_shell.dart';
import 'movie_detail_provider.dart';
import 'add_watch_record_sheet.dart';
import '../../journal/presentation/widgets/add_to_list_sheet.dart';

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

  // Toggle Favorite Status
  Future<void> _toggleFavorite(WidgetRef ref, Map<String, dynamic> movieData) async {
    if (kIsWeb) {
      final notifier = ref.read(webMovieSettingsProvider.notifier);
      final currentMap = ref.read(webMovieSettingsProvider);
      final key = (tmdbId: tmdbId, isTv: isTv);
      final currentSetting = currentMap[key];
      final isFavorite = currentSetting?.isFavorite ?? false;

      final updatedMap = Map<MovieKey, UserMovieSetting>.from(currentMap);
      updatedMap[key] = UserMovieSetting(
        tmdbId: tmdbId,
        isTv: isTv,
        isFavorite: !isFavorite,
        isReWatchList: currentSetting?.isReWatchList ?? false,
        personalRanking: currentSetting?.personalRanking,
        updatedAt: DateTime.now(),
        isActivelyWatching: currentSetting?.isActivelyWatching ?? false,
        lastWatchedEpisode: currentSetting?.lastWatchedEpisode,
      );
      notifier.state = updatedMap;
      return;
    }

    final db = ref.read(databaseProvider);
    final settings = ref.read(movieSettingsProvider((tmdbId: tmdbId, isTv: isTv))).value;
    final isFavorite = settings?.isFavorite ?? false;

    // Combine crew & cast details
    final crew = movieData['credits']?['crew'] as List<dynamic>?;
    final directorName = crew?.where((e) => e['job'] == 'Director').firstOrNull?['name'] as String?;
    
    final cast = movieData['credits']?['cast'] as List<dynamic>?;
    final actorsString = cast?.take(5).map((e) => e['name']).join(', ');

    final genresData = movieData['genres'] as List<dynamic>?;
    final genresString = genresData?.map((e) => e['name']).join(', ');

    final releaseDateStr = movieData['release_date'] as String? ?? '';
    final releaseYear = DateTime.tryParse(releaseDateStr)?.year;

    try {
      // 1. Ensure movie exists. createdAt is intentionally left absent so it
      // keeps its original insert value instead of being bumped to "now" on
      // every favorite toggle (that would corrupt "recently added" ordering).
      await db.into(db.movies).insertOnConflictUpdate(
            MoviesCompanion.insert(
              tmdbId: tmdbId,
              title: movieData['title'] as String,
              originalTitle: Value(movieData['original_title'] as String?),
              posterPath: Value(movieData['poster_path'] as String?),
              backdropPath: Value(movieData['backdrop_path'] as String?),
              releaseYear: Value(releaseYear),
              runtime: Value(movieData['runtime'] as int?),
              genres: Value(genresString),
              director: Value(directorName),
              actors: Value(actorsString),
              overview: Value(movieData['overview'] as String?),
              isTv: Value(isTv),
            ),
          );

      // 2. Insert or update user setting
      await db.into(db.userMovieSettings).insertOnConflictUpdate(
            UserMovieSetting(
              tmdbId: tmdbId,
              isTv: isTv,
              isFavorite: !isFavorite,
              isReWatchList: settings?.isReWatchList ?? false,
              personalNotes: settings?.personalNotes,
              personalTags: settings?.personalTags,
              personalRanking: settings?.personalRanking,
              updatedAt: DateTime.now(),
              isActivelyWatching: settings?.isActivelyWatching ?? false,
              lastWatchedEpisode: settings?.lastWatchedEpisode,
            ),
          );
    } catch (_) {}
  }

  // Show dialog to update personal ranking
  void _showRankDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> movieData, UserMovieSetting? settings) {
    final controller = TextEditingController(text: settings?.personalRanking?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            'Favori Sırası Belirle',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bu film için favori sıralama numarasını girin (Örn: 1, 2, 5). Boş bırakırsanız sıralamadan çıkarılır.',
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Sıra Numarası',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (val) async {
                  final newRank = val.trim().isEmpty ? null : int.tryParse(val.trim());
                  await _updateRank(ref, movieData, settings, newRank);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
              onPressed: () async {
                final input = controller.text.trim();
                final int? newRank = input.isEmpty ? null : int.tryParse(input);
                
                await _updateRank(ref, movieData, settings, newRank);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Kaydet', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateRank(WidgetRef ref, Map<String, dynamic> movieData, UserMovieSetting? settings, int? rank) async {
    final crew = movieData['credits']?['crew'] as List<dynamic>?;
    final directorName = crew?.where((e) => e['job'] == 'Director').firstOrNull?['name'] as String?;
    
    final cast = movieData['credits']?['cast'] as List<dynamic>?;
    final actorsString = cast?.take(5).map((e) => e['name']).join(', ');

    final genresData = movieData['genres'] as List<dynamic>?;
    final genresString = genresData?.map((e) => e['name']).join(', ');

    final releaseDateStr = movieData['release_date'] as String? ?? '';
    final releaseYear = DateTime.tryParse(releaseDateStr)?.year;

    if (kIsWeb) {
      final notifier = ref.read(webMovieSettingsProvider.notifier);
      final currentMap = ref.read(webMovieSettingsProvider);
      final updatedMap = Map<MovieKey, UserMovieSetting>.from(currentMap);
      updatedMap[(tmdbId: tmdbId, isTv: isTv)] = UserMovieSetting(
        tmdbId: tmdbId,
        isTv: isTv,
        isFavorite: settings?.isFavorite ?? false,
        isReWatchList: settings?.isReWatchList ?? false,
        personalNotes: settings?.personalNotes,
        personalTags: settings?.personalTags,
        personalRanking: rank,
        updatedAt: DateTime.now(),
        isActivelyWatching: settings?.isActivelyWatching ?? false,
        lastWatchedEpisode: settings?.lastWatchedEpisode,
      );
      notifier.state = updatedMap;
      return;
    }

    final db = ref.read(databaseProvider);
    try {
      // createdAt intentionally absent, see _toggleFavorite for why.
      await db.into(db.movies).insertOnConflictUpdate(
            MoviesCompanion.insert(
              tmdbId: tmdbId,
              title: movieData['title'] as String,
              originalTitle: Value(movieData['original_title'] as String?),
              posterPath: Value(movieData['poster_path'] as String?),
              backdropPath: Value(movieData['backdrop_path'] as String?),
              releaseYear: Value(releaseYear),
              runtime: Value(movieData['runtime'] as int?),
              genres: Value(genresString),
              director: Value(directorName),
              actors: Value(actorsString),
              overview: Value(movieData['overview'] as String?),
              isTv: Value(isTv),
            ),
          );

      await db.into(db.userMovieSettings).insertOnConflictUpdate(
            UserMovieSetting(
              tmdbId: tmdbId,
              isTv: isTv,
              isFavorite: settings?.isFavorite ?? false,
              isReWatchList: settings?.isReWatchList ?? false,
              personalNotes: settings?.personalNotes,
              personalTags: settings?.personalTags,
              personalRanking: rank,
              updatedAt: DateTime.now(),
              isActivelyWatching: settings?.isActivelyWatching ?? false,
              lastWatchedEpisode: settings?.lastWatchedEpisode,
            ),
          );
    } catch (_) {}
  }

  // Delete Watch Record
  Future<void> _deleteRecord(BuildContext context, WidgetRef ref, int recordId) async {
    if (kIsWeb) {
      final notifier = ref.read(webWatchRecordsProvider.notifier);
      final currentList = ref.read(webWatchRecordsProvider);
      notifier.state = currentList.where((r) => r.id != recordId).toList();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İzleme kaydı silindi.'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
      return;
    }

    final db = ref.read(databaseProvider);
    try {
      await (db.delete(db.watchRecords)..where((t) => t.id.equals(recordId))).go();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İzleme kaydı silindi.'),
            duration: const Duration(milliseconds: 1500),
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
          data: (movieData) => movieData == null ? null : _buildStickyCta(context, movieData),
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

          final isFavorite = settingsAsync.value?.isFavorite ?? false;
          // watchRecordsForMovieProvider already orders by watchDate desc.
          final latestRecord = watchRecordsAsync.value?.firstOrNull;

          return Stack(
            children: [
              // 1. Blurred Backdrop Image
              Positioned.fill(
                child: backdropPath != null
                    ? AppNetworkImage(
                        imageUrl: '${ApiConstants.imagePathOriginal}$backdropPath',
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(),
              ),
              
              // 2. Black Fading Mask
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.85),
                        AppTheme.backgroundColor.withOpacity(0.45),
                      ],
                      stops: const [0.0, 0.4, 0.75],
                    ),
                  ),
                ),
              ),

              // 3. Main Scrollable Content
              Positioned.fill(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Floating Header Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(8),
                                borderRadius: 12,
                                opacity: 0.7,
                                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                            Row(
                              children: [
                                // Favorite toggle button
                                GestureDetector(
                                  onTap: () => _toggleFavorite(ref, movieData),
                                  child: GlassContainer(
                                    padding: const EdgeInsets.all(8),
                                    borderRadius: 12,
                                    opacity: 0.7,
                                    child: Icon(
                                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isFavorite ? Colors.red : Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                
                                // Rank button
                                GestureDetector(
                                  onTap: () => _showRankDialog(context, ref, movieData, settingsAsync.value),
                                  child: GlassContainer(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    borderRadius: 12,
                                    opacity: 0.7,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.format_list_numbered_rounded, color: AppTheme.accentColor, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          settingsAsync.value?.personalRanking != null
                                              ? '#${settingsAsync.value!.personalRanking}'
                                              : 'Sıra Belirle',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
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
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Poster, Title & Metadata row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero animation for poster
                            Hero(
                              tag: 'poster_${tmdbId}_$isTv',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AppNetworkImage(
                                  imageUrl: posterPath != null
                                      ? '${ApiConstants.imagePathW500}$posterPath'
                                      : '',
                                  seed: title,
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Movie Metadata
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (tagline.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '"$tagline"',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    [
                                      if (year.isNotEmpty) year,
                                      if (runtime > 0) '$runtime dk',
                                      if (genresString.isNotEmpty) genresString,
                                    ].join(' • '),
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                  if (isTv) _buildWatchStatusBadge(settingsAsync.value, movieData['number_of_episodes'] as int?),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 3-up info cards: my rating / director / watch place
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.star_rounded,
                                iconColor: AppTheme.ratingColor,
                                value: latestRecord != null ? latestRecord.rating.toStringAsFixed(1) : '—',
                                label: 'Puanım',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.movie_creation_outlined,
                                iconColor: Colors.white,
                                value: director,
                                label: 'Yönetmen',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInfoCard(
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
                            _buildQuickAction(
                              icon: Icons.add_rounded,
                              label: 'Günlüğe Ekle',
                              isPrimary: true,
                              onTap: () => _openAddWatchRecordSheet(context, movieData),
                            ),
                            _buildQuickAction(
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
                            _buildQuickAction(
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

                        // Actors List Section
                        if (cast != null && cast.isNotEmpty) ...[
                          Text(
                            'Oyuncular',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: cast.length > 8 ? 8 : cast.length,
                              itemBuilder: (context, idx) {
                                final actor = cast[idx];
                                return Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      // Avatar Circle
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: AppTheme.surfaceColor,
                                        backgroundImage: actor['profile_path'] != null
                                            ? NetworkImage('${ApiConstants.imagePathW500}${actor['profile_path']}')
                                            : null,
                                        child: actor['profile_path'] == null
                                            ? const Icon(Icons.person_rounded, color: Colors.grey)
                                            : null,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        actor['name'] as String,
                                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Timeline of Watch Records (Zaman Tüneli)
                        Text(
                          'İzleme Geçmişim',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        watchRecordsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('İzleme geçmişi hatası: $err'),
                          data: (records) {
                            if (records.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.history_rounded, color: AppTheme.textSecondary.withOpacity(0.4), size: 40),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Bu filmi henüz izlemediniz.',
                                        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: records.length,
                              itemBuilder: (context, idx) {
                                final record = records[idx];
                                return _buildTimelineItem(context, ref, record, idx == records.length - 1);
                              },
                            );
                          },
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
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _buildStickyCta(BuildContext context, Map<String, dynamic> movieData) {
    return Container(
      color: AppTheme.backgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openAddWatchRecordSheet(context, movieData),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_task_rounded, color: Colors.white),
              label: Text(
                'Yeni İzleme Kaydı Ekle',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
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

  // One of the 3 "Puanım / Yönetmen / Ortam" summary cards under the poster.
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      borderRadius: 14,
      opacity: 0.5,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // One of the 3 quick action buttons (Günlüğe Ekle / Listeye Ekle / Paylaş).
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isPrimary ? AppTheme.accentColor : AppTheme.surfaceColor.withOpacity(0.6),
              shape: BoxShape.circle,
              border: isPrimary ? null : Border.all(color: AppTheme.borderColor),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // Beautiful Timeline Item
  Widget _buildTimelineItem(BuildContext context, WidgetRef ref, WatchRecord record, bool isLast) {
    final dateStr = DateFormat('dd.MM.yyyy • HH:mm').format(record.watchDate);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator Left Pillar
        Column(
          children: [
            // Circular badge watch order number (e.g. 1, 2)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${record.watchNumber}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Vertical connecting line
            if (!isLast)
              Container(
                width: 2,
                height: 100, // Fixed height connecting timeline items
                color: AppTheme.accentColor.withOpacity(0.5),
              ),
          ],
        ),
        const SizedBox(width: 14),

        // Record content card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: 16,
              opacity: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      // Star Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${record.rating}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '/10',
                            style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Place, companion, mood info
                  Row(
                    children: [
                      Text(
                        'Mod: ${record.mood ?? "🍿"}',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
                      ),
                      const Spacer(),
                      
                      // Place / Companion
                      if (record.watchPlace != null) ...[
                        Icon(Icons.location_on_outlined, color: AppTheme.textSecondary, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          record.watchPlace!,
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                      if (record.watchCompanion != null) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.people_alt_outlined, color: AppTheme.textSecondary, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          record.watchCompanion!,
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ],
                  ),
                  
                  // Notes (if any) & delete button
                  if (record.notes != null) ...[
                    const SizedBox(height: 8),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 4),
                    Text(
                      record.notes!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      onPressed: () {
                        // Confirm deletion dialog
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            backgroundColor: AppTheme.surfaceColor,
                            title: Text('Kaydı Sil?', style: GoogleFonts.outfit(color: Colors.white)),
                            content: Text(
                              'Bu izleme kaydını günlüğünüzden kalıcı olarak silmek istediğinize emin misiniz?',
                              style: GoogleFonts.inter(color: AppTheme.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: Text('Vazgeç', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogCtx);
                                  _deleteRecord(context, ref, record.id);
                                },
                                child: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Read-only "Aktif İzliyorum" / "Tamamlandı" indicator for TV shows.
  // Actual state is only changed via the Add Watch Record flow.
  Widget _buildWatchStatusBadge(UserMovieSetting? setting, int? totalEpisodes) {
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
