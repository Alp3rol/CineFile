import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/l10n/date_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/widgets/premium_date_picker.dart';
import '../../../../core/widgets/premium_toast.dart';

Widget _buildPreviewDetailRow(IconData icon, String label, String value, {VoidCallback? onEdit}) {
  return Row(
    children: [
      Icon(icon, size: 14, color: AppTheme.textSecondary),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: Text(
          value,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (onEdit != null)
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Icon(Icons.edit_rounded, size: 14, color: AppTheme.accentColor),
          ),
        ),
    ],
  );
}

// Quick info long-press modal preview with Ranking editing
void showWatchRecordPreviewDialog(
  BuildContext context,
  Movie movie,
  WatchRecord record,
  UserMovieSetting? setting, {
  required Future<void> Function(Map<MovieKey, int?> rankings) onUpdateRanking,
  required Future<void> Function() onDelete,
  required Future<void> Function(DateTime newDate) onUpdateDate,
  required Future<void> Function(int newCount) onUpdateEpisodes,
  required Future<void> Function(bool newValue) onUpdatePrivacy,
}) {
  DateTime currentDate = record.watchDate;
  int currentEpisodeCount = record.episodeCount;
  bool currentIsPublic = record.isPublic;
  final rankController = TextEditingController(text: setting?.personalRanking?.toString() ?? '');

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final dateStr = formatShortDate(context, currentDate);

      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          opacity: 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Area
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: movie.posterPath != null
                          ? '${ApiConstants.imagePathW185}${movie.posterPath}'
                          : '',
                      width: 44,
                      height: 66,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context).recordYearDirector(movie.releaseYear?.toString() ?? AppLocalizations.of(context).yearUnknown, movie.director ?? AppLocalizations.of(context).directorMissing),
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${record.rating}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context).recordMood(record.mood ?? '🍿'),
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),

              // Details Grid
              _buildPreviewDetailRow(
                Icons.calendar_today_rounded, 
                AppLocalizations.of(context).journalColumnWatchDate, 
                dateStr,
                onEdit: () async {
                  final pickedDate = await PremiumDatePicker.show(
                    context,
                    initialDate: currentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    final newDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      currentDate.hour,
                      currentDate.minute,
                    );
                    await onUpdateDate(newDateTime);
                    setState(() {
                      currentDate = newDateTime;
                    });
                  }
                },
              ),
              if (movie.isTv) ...[
                const SizedBox(height: 10),
                _buildPreviewDetailRow(
                  Icons.ondemand_video_rounded,
                  AppLocalizations.of(context).recordEpisodesWatched,
                  AppLocalizations.of(context).recordEpisodesCount(currentEpisodeCount),
                  onEdit: () async {
                    final ctrl = TextEditingController(text: currentEpisodeCount.toString());
                    final newCount = await showDialog<int>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.backgroundColor,
                        title: Text(AppLocalizations.of(context).recordEpisodeCount, style: GoogleFonts.outfit(color: Colors.white)),
                        content: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).recordEpisodeCountHint,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context).commonCancel, style: const TextStyle(color: Colors.white70)),
                          ),
                          TextButton(
                            onPressed: () {
                              final val = int.tryParse(ctrl.text);
                              if (val != null && val > 0) {
                                Navigator.pop(context, val);
                              }
                            },
                            child: Text(AppLocalizations.of(context).commonSave, style: const TextStyle(color: AppTheme.accentColor)),
                          ),
                        ],
                      ),
                    );
                    if (newCount != null) {
                      await onUpdateEpisodes(newCount);
                      setState(() {
                        currentEpisodeCount = newCount;
                      });
                    }
                  },
                ),
              ],
              if (record.watchPlace != null) ...[
                const SizedBox(height: 10),
                _buildPreviewDetailRow(Icons.location_on_outlined, AppLocalizations.of(context).recordWatchPlace, record.watchPlace!),
              ],
              if (record.watchCompanion != null) ...[
                const SizedBox(height: 10),
                _buildPreviewDetailRow(Icons.people_outline_rounded, AppLocalizations.of(context).recordCompanions, record.watchCompanion!),
              ],

              // Controls ONLY the "Son İzlediklerim" section on the user's
              // own profile — unrelated to the Community feed, which is
              // populated by explicit posts (see share_compose_sheet.dart),
              // not by this flag.
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.public_rounded, color: AppTheme.accentColor, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).addRecordVisibilityLabel,
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Switch(
                    value: currentIsPublic,
                    activeThumbColor: AppTheme.accentColor,
                    onChanged: (value) async {
                      try {
                        await onUpdatePrivacy(value);
                        setState(() {
                          currentIsPublic = value;
                        });
                      } catch (e) {
                        if (context.mounted) {
                          showPremiumToast(context, AppLocalizations.of(context).recordVisibilityFailed, isError: true);
                        }
                      }
                    },
                  ),
                ],
              ),

              // Edit Ranking Row
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.format_list_numbered_rounded, color: AppTheme.accentColor, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).recordMyRank,
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    height: 24,
                    child: TextField(
                      controller: rankController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '-',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: Colors.black38,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (val) async {
                        final newRank = val.trim().isEmpty ? null : int.tryParse(val.trim());
                        try {
                          await onUpdateRanking({(tmdbId: movie.tmdbId, isTv: movie.isTv): newRank});
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            showPremiumToast(context, AppLocalizations.of(context).journalReorderFailed, isError: true);
                          }
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  if (setting?.personalRanking != null)
                     TextButton(
                      onPressed: () async {
                        try {
                          await onUpdateRanking({(tmdbId: movie.tmdbId, isTv: movie.isTv): null});
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            showPremiumToast(context, AppLocalizations.of(context).journalReorderFailed, isError: true);
                          }
                        }
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: Text(
                        AppLocalizations.of(context).recordRemoveRank,
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.redAccent),
                      ),
                    ),
                ],
              ),

              // Notes section
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).recordMyNotes,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Text(
                    record.notes != null && record.notes!.trim().isNotEmpty
                        ? record.notes!
                        : AppLocalizations.of(context).recordNoNotes,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.backgroundColor,
                          title: Text(AppLocalizations.of(context).recordDeleteConfirmTitle, style: GoogleFonts.outfit(color: Colors.white)),
                          content: Text(AppLocalizations.of(context).recordDeleteConfirmBody, style: const TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(AppLocalizations.of(context).commonCancel, style: const TextStyle(color: Colors.white70)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(AppLocalizations.of(context).commonDelete, style: const TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await onDelete();
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            showPremiumToast(context, AppLocalizations.of(context).recordDeleteFailed, isError: true);
                          }
                        }
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context).recordDelete,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context).commonClose,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
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
    },
  );
}
