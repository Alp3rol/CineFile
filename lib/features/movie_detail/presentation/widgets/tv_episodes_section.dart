import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/episode_logging.dart';
import '../../../../core/utils/tv_episode_math.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../tv_season_provider.dart';
import 'tv_episode_list_item.dart';
import 'tv_glass_choice_dialog.dart';
import 'tv_season_chip_row.dart';

class MovieDetailTvEpisodesSection extends ConsumerStatefulWidget {
  final Movie movie;
  final List<dynamic> seasons;
  final UserMovieSetting? settings;
  final int? totalEpisodes;
  final bool hasJournalEntry;
  final VoidCallback onRequestAddToJournal;

  const MovieDetailTvEpisodesSection({
    super.key,
    required this.movie,
    required this.seasons,
    required this.settings,
    required this.totalEpisodes,
    required this.hasJournalEntry,
    required this.onRequestAddToJournal,
  });

  @override
  ConsumerState<MovieDetailTvEpisodesSection> createState() => _MovieDetailTvEpisodesSectionState();
}

class _MovieDetailTvEpisodesSectionState extends ConsumerState<MovieDetailTvEpisodesSection> {
  late int _selectedSeasonNumber;
  bool _journalPromptDismissed = false;

  @override
  void initState() {
    super.initState();
    _selectedSeasonNumber = _calculateInitialSeason();
  }

  List<dynamic> get _sortedRegularSeasons => sortedRegularSeasons(widget.seasons);

  // Smartly calculate which season tab to pre-select based on user's current progress
  int _calculateInitialSeason() {
    final lastWatched = widget.settings?.lastWatchedEpisode ?? 0;
    final regularSeasons = _sortedRegularSeasons;

    if (lastWatched > 0 && regularSeasons.isNotEmpty) {
      int totalCount = 0;
      for (final season in regularSeasons) {
        final sNum = season['season_number'] as int? ?? 1;
        final epCount = season['episode_count'] as int? ?? 0;
        if (lastWatched > totalCount && lastWatched <= totalCount + epCount) {
          return sNum;
        }
        totalCount += epCount;
      }
    }

    // Default to the first season in the list, or 1 if empty
    return regularSeasons.isNotEmpty ? (regularSeasons.first['season_number'] as int? ?? 1) : 1;
  }

  // Maps a season number and episode number to a single overall sequential index
  int _calculateOverallEpisodeNumber(int seasonNumber, int episodeNumber) {
    return calculateOverallEpisodeNumber(_sortedRegularSeasons, seasonNumber, episodeNumber);
  }

  Future<void> _toggleEpisodeWatched(int targetEpisodeIndex, int episodeNumber) async {
    // One-time journal prompt for un-journaled shows
    if (!widget.hasJournalEntry && !_journalPromptDismissed) {
      final wantsToAddToJournal = await showGlassChoiceDialog(
        context,
        header: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.bookmark_add_rounded, color: AppTheme.accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bu diziyi günlüğüne eklemek ister misin?',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        message: 'Günlüğe eklersen "Aktif İzliyorum" listende görünür ve istatistiklerine yansır.',
        cancelLabel: 'Sadece Takip Et',
        confirmLabel: 'Günlüğe Ekle',
      );
      if (wantsToAddToJournal) {
        // User chose "Günlüğe Ekle" — open the add-record sheet and abort toggle
        widget.onRequestAddToJournal();
        return;
      }
      setState(() {
        _journalPromptDismissed = true;
      });
    }

    final currentLastWatched = widget.settings?.lastWatchedEpisode ?? 0;

    if (targetEpisodeIndex > currentLastWatched) {
      bool shouldUpdate = true;
      if (targetEpisodeIndex > currentLastWatched + 1) {
        if (!mounted) return;
        shouldUpdate = await showGlassChoiceDialog(
          context,
          header: Text(
            'Bölümleri İzledin mi?',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          message:
              'Bu bölümü izlendi olarak işaretlemek, önceki tüm bölümleri de (${currentLastWatched + 1} - $targetEpisodeIndex) izlendi sayacaktır. Devam etmek istiyor musunuz?',
          cancelLabel: 'İptal',
          confirmLabel: 'Evet',
        );
      }

      if (shouldUpdate) {
        await _writeProgress(
          lastWatchedEpisode: targetEpisodeIndex,
          isActivelyWatching: widget.totalEpisodes == null || targetEpisodeIndex < widget.totalEpisodes!,
          successMessage: '$episodeNumber. Bölüm izlendi olarak işaretlendi.',
        );
      }
    } else {
      bool shouldUpdate = true;
      if (targetEpisodeIndex < currentLastWatched) {
        if (!mounted) return;
        shouldUpdate = await showGlassChoiceDialog(
          context,
          header: Text(
            'İzleme İlerlemesini Geri Al?',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          message:
              'Bu bölümü izlenmedi olarak işaretlemek, sonraki tüm bölümleri de ($targetEpisodeIndex - $currentLastWatched) izlenmedi sayacaktır. Devam etmek istiyor musunuz?',
          cancelLabel: 'İptal',
          confirmLabel: 'Evet',
        );
      }

      if (shouldUpdate) {
        await _writeProgress(
          lastWatchedEpisode: targetEpisodeIndex - 1,
          isActivelyWatching: true,
          successMessage: '$episodeNumber. Bölüm izlenmedi olarak işaretlendi.',
        );
      }
    }
  }

  Future<void> _writeProgress({
    required int? lastWatchedEpisode,
    required bool isActivelyWatching,
    required String successMessage,
  }) async {
    try {
      await writeEpisodeProgressSettings(
        ref: ref,
        movie: widget.movie,
        setting: widget.settings ??
            UserMovieSetting(
              tmdbId: widget.movie.tmdbId,
              isTv: true,
              isFavorite: false,
              isReWatchList: false,
              updatedAt: DateTime.now(),
              isActivelyWatching: true,
            ),
        lastWatchedEpisode: lastWatchedEpisode,
        isActivelyWatching: isActivelyWatching,
      );
      if (mounted) {
        showPremiumToast(context, successMessage);
      }
    } catch (e) {
      if (mounted) {
        showPremiumToast(context, 'Bölüm işaretlenemedi: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authStateProvider);
    final regularSeasons = _sortedRegularSeasons;
    if (regularSeasons.isEmpty) return const SizedBox.shrink();

    final lastWatched = widget.settings?.lastWatchedEpisode ?? 0;
    final seasonAsync = ref.watch(tvSeasonDetailsProvider((tvId: widget.movie.tmdbId, seasonNumber: _selectedSeasonNumber)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bölüm Rehberi',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),

        TvSeasonChipRow(
          seasons: regularSeasons,
          selectedSeasonNumber: _selectedSeasonNumber,
          onSeasonSelected: (sNum) => setState(() => _selectedSeasonNumber = sNum),
        ),
        const SizedBox(height: 16),

        seasonAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Bölümler yüklenirken bir hata oluştu: $error',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          data: (seasonData) {
            final episodes = seasonData?['episodes'] as List<dynamic>? ?? [];
            if (episodes.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Bu sezona ait bölüm bulunamadı.',
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
              );
            }

            // Last episode of the currently selected season, used by the
            // "Bu Sezonu İzledim" bulk-complete button below.
            final lastEpisodeNumber = episodes
                .map((e) => (e as Map<String, dynamic>)['episode_number'] as int? ?? 0)
                .fold(0, (max, n) => n > max ? n : max);
            final lastOverallIndex = _calculateOverallEpisodeNumber(_selectedSeasonNumber, lastEpisodeNumber);
            final seasonAlreadyComplete = lastOverallIndex <= lastWatched;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!seasonAlreadyComplete && lastEpisodeNumber > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleEpisodeWatched(lastOverallIndex, lastEpisodeNumber),
                        icon: const Icon(Icons.done_all_rounded, size: 18, color: AppTheme.accentColor),
                        label: Text(
                          'Bu Sezonu İzledim',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.accentColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.accentColor, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final e = episodes[index] as Map<String, dynamic>;
                    final epNum = e['episode_number'] as int? ?? (index + 1);
                    final overallIndex = _calculateOverallEpisodeNumber(_selectedSeasonNumber, epNum);
                    final isWatched = overallIndex <= lastWatched;

                    return TvEpisodeListItem(
                      episode: e,
                      episodeNumber: epNum,
                      isWatched: isWatched,
                      isNextUp: overallIndex == lastWatched + 1,
                      onToggleWatched: () => _toggleEpisodeWatched(overallIndex, epNum),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
