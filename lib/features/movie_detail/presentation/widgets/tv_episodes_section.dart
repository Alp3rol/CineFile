import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/episode_logging.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../tv_season_provider.dart';

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

  // Smartly calculate which season tab to pre-select based on user's current progress
  int _calculateInitialSeason() {
    final lastWatched = widget.settings?.lastWatchedEpisode ?? 0;
    final regularSeasons = widget.seasons.where((s) => (s['season_number'] as int? ?? 0) > 0).toList();
    
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
    int count = 0;
    final regularSeasons = widget.seasons.where((s) => (s['season_number'] as int? ?? 0) > 0).toList();
    for (final season in regularSeasons) {
      final sNum = season['season_number'] as int? ?? 1;
      if (sNum < seasonNumber) {
        count += season['episode_count'] as int? ?? 0;
      }
    }
    return count + episodeNumber;
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'İptal',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.accentColor,
                              Colors.amberAccent,
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Evet',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  /// Shows a one-time prompt when the user tries to mark an episode on a show
  /// that has no journal entry yet. Returns the user's choice:
  /// - true  → "Sadece Takip Et" (just track, proceed with toggle)
  /// - false → "Günlüğe Ekle" (open add-record sheet, abort toggle)
  Future<bool> _showJournalPromptDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
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
                const SizedBox(height: 14),
                Text(
                  'Günlüğe eklersen "Aktif İzliyorum" listende görünür ve istatistiklerine yansır.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Sadece Takip Et',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.accentColor,
                              Colors.amberAccent,
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Günlüğe Ekle',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? true; // default: just track
  }

  Future<void> _toggleEpisodeWatched(int targetEpisodeIndex, int episodeNumber) async {
    // One-time journal prompt for un-journaled shows
    if (!widget.hasJournalEntry && !_journalPromptDismissed) {
      final justTrack = await _showJournalPromptDialog(context);
      if (!justTrack) {
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
        shouldUpdate = await _showConfirmationDialog(
          context,
          title: 'Bölümleri İzledin mi?',
          message: 'Bu bölümü izlendi olarak işaretlemek, önceki tüm bölümleri de (${currentLastWatched + 1} - $targetEpisodeIndex) izlendi sayacaktır. Devam etmek istiyor musunuz?',
        );
      }
      
      if (shouldUpdate) {
        try {
          await writeEpisodeProgressSettings(
            ref: ref,
            movie: widget.movie,
            setting: widget.settings ?? UserMovieSetting(
              tmdbId: widget.movie.tmdbId,
              isTv: true,
              isFavorite: false,
              isReWatchList: false,
              updatedAt: DateTime.now(),
              isActivelyWatching: true,
            ),
            lastWatchedEpisode: targetEpisodeIndex,
            isActivelyWatching: targetEpisodeIndex < (widget.totalEpisodes ?? 0),
          );
          if (mounted) {
            showPremiumToast(context, '$episodeNumber. Bölüm izlendi olarak işaretlendi.');
          }
        } catch (e) {
          if (mounted) {
            showPremiumToast(context, 'Bölüm işaretlenemedi: $e', isError: true);
          }
        }
      }
    } else {
      bool shouldUpdate = true;
      if (targetEpisodeIndex < currentLastWatched) {
        if (!mounted) return;
        shouldUpdate = await _showConfirmationDialog(
          context,
          title: 'İzleme İlerlemesini Geri Al?',
          message: 'Bu bölümü izlenmedi olarak işaretlemek, sonraki tüm bölümleri de ($targetEpisodeIndex - $currentLastWatched) izlenmedi sayacaktır. Devam etmek istiyor musunuz?',
        );
      }
      
      if (shouldUpdate) {
        try {
          await writeEpisodeProgressSettings(
            ref: ref,
            movie: widget.movie,
            setting: widget.settings ?? UserMovieSetting(
              tmdbId: widget.movie.tmdbId,
              isTv: true,
              isFavorite: false,
              isReWatchList: false,
              updatedAt: DateTime.now(),
              isActivelyWatching: true,
            ),
            lastWatchedEpisode: targetEpisodeIndex - 1,
            isActivelyWatching: true,
          );
          if (mounted) {
            showPremiumToast(context, '$episodeNumber. Bölüm izlenmedi olarak işaretlendi.');
          }
        } catch (e) {
          if (mounted) {
            showPremiumToast(context, 'Bölüm işaretlenemedi: $e', isError: true);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authStateProvider);
    final regularSeasons = widget.seasons.where((s) => (s['season_number'] as int? ?? 0) > 0).toList();
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
        
        // 1. Season Chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: regularSeasons.length,
            itemBuilder: (context, index) {
              final s = regularSeasons[index];
              final sNum = s['season_number'] as int? ?? 1;
              final sName = s['name'] as String? ?? '$sNum. Sezon';
              final isSelected = _selectedSeasonNumber == sNum;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSeasonNumber = sNum;
                    });
                  },
                  child: GlassContainer(
                    borderRadius: 12,
                    opacity: isSelected ? 0.8 : 0.4,
                    color: isSelected ? AppTheme.accentColor : null,
                    border: Border.all(
                      color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Center(
                      child: Text(
                        sName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // 2. Episodes List
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

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final e = episodes[index];
                final epNum = e['episode_number'] as int? ?? (index + 1);
                final epName = e['name'] as String? ?? '$epNum. Bölüm';
                final overview = e['overview'] as String? ?? 'Bölüm özeti bulunmuyor.';
                final stillPath = e['still_path'] as String?;
                final airDateStr = e['air_date'] as String? ?? '';
                
                String formattedDate = '';
                if (airDateStr.isNotEmpty) {
                  final date = DateTime.tryParse(airDateStr);
                  if (date != null) {
                    formattedDate = DateFormat('d MMMM y', 'tr_TR').format(date);
                  }
                }

                final overallIndex = _calculateOverallEpisodeNumber(_selectedSeasonNumber, epNum);
                final isWatched = overallIndex <= lastWatched;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(12),
                    opacity: isWatched ? 0.6 : 0.4,
                    useBlur: false, // Turn off blur for item rows to optimize list scroll performance
                    border: Border.all(
                      color: isWatched ? AppTheme.accentColor.withValues(alpha: 0.3) : AppTheme.borderColor,
                      width: isWatched ? 1.5 : 1,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Episode Still Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AppNetworkImage(
                            imageUrl: stillPath != null ? '${ApiConstants.imagePathW500}$stillPath' : '',
                            seed: epName,
                            width: 100,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title, Date, Overview
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$epNum. $epName',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (formattedDate.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                overview,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white54,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Checked circle / checkmark toggle button
                        GestureDetector(
                          key: ValueKey('episode_check_$epNum'),
                          onTap: () => _toggleEpisodeWatched(overallIndex, epNum),
                          child: Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isWatched ? AppTheme.accentColor : Colors.white30,
                                width: 1.5,
                              ),
                              color: isWatched ? AppTheme.accentColor.withValues(alpha: 0.2) : Colors.transparent,
                            ),
                            child: isWatched
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: AppTheme.accentColor,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
