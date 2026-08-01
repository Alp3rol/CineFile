import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';

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
        final sNum = (season['season_number'] as num?)?.toInt() ?? 1;
        final epCount = (season['episode_count'] as num?)?.toInt() ?? 0;
        if (lastWatched > totalCount && lastWatched <= totalCount + epCount) {
          return sNum;
        }
        totalCount += epCount;
      }
    }

    // Default to the first season in the list, or 1 if empty
    return regularSeasons.isNotEmpty ? ((regularSeasons.first['season_number'] as num?)?.toInt() ?? 1) : 1;
  }

  // Maps a season number and episode number to a single overall sequential index
  int _calculateOverallEpisodeNumber(int seasonNumber, int episodeNumber) {
    return calculateOverallEpisodeNumber(_sortedRegularSeasons, seasonNumber, episodeNumber);
  }

  Future<void> _toggleEpisodeWatched(int targetEpisodeIndex, int episodeNumber) async {
    final l10n = AppLocalizations.of(context);
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
                color: AppColors.accent.withValues(alpha: AppOpacity.soft),
              ),
              child: const Icon(Icons.bookmark_add_rounded, color: AppColors.accent, size: AppSize.iconMd),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                AppLocalizations.of(context).episodeAddShowPrompt,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        message: AppLocalizations.of(context).episodeAddShowExplain,
        cancelLabel: AppLocalizations.of(context).episodeFollowOnly,
        confirmLabel: AppLocalizations.of(context).detailAddToDiary,
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
            AppLocalizations.of(context).episodeConfirmWatchedTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          message:
              AppLocalizations.of(context).episodeBulkWatchConfirm(currentLastWatched + 1, targetEpisodeIndex),
          cancelLabel: AppLocalizations.of(context).commonCancel,
          confirmLabel: AppLocalizations.of(context).commonYes,
        );
      }

      if (shouldUpdate) {
        await _writeProgress(
          lastWatchedEpisode: targetEpisodeIndex,
          isActivelyWatching: widget.totalEpisodes == null || targetEpisodeIndex < widget.totalEpisodes!,
          successMessage: l10n.episodeMarkedWatched(episodeNumber),
        );
      }
    } else {
      bool shouldUpdate = true;
      if (targetEpisodeIndex < currentLastWatched) {
        if (!mounted) return;
        shouldUpdate = await showGlassChoiceDialog(
          context,
          header: Text(
            AppLocalizations.of(context).episodeUndoProgressTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          message:
              AppLocalizations.of(context).episodeBulkUnwatchConfirm(targetEpisodeIndex, currentLastWatched),
          cancelLabel: AppLocalizations.of(context).commonCancel,
          confirmLabel: AppLocalizations.of(context).commonYes,
        );
      }

      if (shouldUpdate) {
        await _writeProgress(
          lastWatchedEpisode: targetEpisodeIndex - 1,
          isActivelyWatching: true,
          successMessage: l10n.episodeMarkedUnwatched(episodeNumber),
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
        debugPrint('Marking the episode failed: $e');
        showPremiumToast(context, AppLocalizations.of(context).episodeMarkFailed, isError: true);
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
          AppLocalizations.of(context).episodeGuideTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),

        TvSeasonChipRow(
          seasons: regularSeasons,
          selectedSeasonNumber: _selectedSeasonNumber,
          onSeasonSelected: (sNum) => setState(() => _selectedSeasonNumber = sNum),
        ),
        const SizedBox(height: AppSpacing.lg),

        seasonAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              AppLocalizations.of(context).episodeGuideLoadFailed,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          data: (seasonData) {
            final episodes = seasonData?['episodes'] as List<dynamic>? ?? [];
            if (episodes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(
                  AppLocalizations.of(context).episodeGuideEmpty,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }

            // Last episode of the currently selected season, used by the
            // "Bu Sezonu İzledim" bulk-complete button below.
            final lastEpisodeNumber = episodes
                .map((e) => (e is Map) ? ((e['episode_number'] as num?)?.toInt() ?? 0) : 0)
                .fold(0, (max, n) => n > max ? n : max);
            final lastOverallIndex = _calculateOverallEpisodeNumber(_selectedSeasonNumber, lastEpisodeNumber);
            final seasonAlreadyComplete = lastOverallIndex <= lastWatched;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!seasonAlreadyComplete && lastEpisodeNumber > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AppButton(
                      label: AppLocalizations.of(context).episodeMarkSeasonWatched,
                      icon: Icons.done_all_rounded,
                      variant: AppButtonVariant.secondary,
                      isFullWidth: true,
                      onPressed: () => _toggleEpisodeWatched(
                        lastOverallIndex,
                        lastEpisodeNumber,
                      ),
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final e = episodes[index] as Map<String, dynamic>;
                    final epNum = (e['episode_number'] as num?)?.toInt() ?? (index + 1);
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
