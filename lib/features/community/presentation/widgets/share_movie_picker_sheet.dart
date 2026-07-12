import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import 'share_compose_sheet.dart';

// Reused by both "Film Paylaş" (tap one record) and "Günlüğünü Paylaş"
// (checkbox multi-select) — in both modes this sheet only PICKS what to
// share; it never writes anything itself. Selecting closes this sheet and
// opens ShareComposeSheet, which asks for a mandatory caption and performs
// the actual `posts` write. This deliberately does not touch each record's
// isPublic flag — that flag now only controls "Son İzlediklerim" visibility
// on the user's own profile, fully decoupled from the community feed.
class ShareMoviePickerSheet extends ConsumerStatefulWidget {
  final bool multiSelect;
  const ShareMoviePickerSheet({super.key, this.multiSelect = false});

  static void show(BuildContext context, {bool multiSelect = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ShareMoviePickerSheet(multiSelect: multiSelect),
      ),
    );
  }

  @override
  ConsumerState<ShareMoviePickerSheet> createState() => _ShareMoviePickerSheetState();
}

class _ShareMoviePickerSheetState extends ConsumerState<ShareMoviePickerSheet> {
  // recordId -> checked, only used in multiSelect mode. Unrelated to each
  // record's isPublic — this is purely "include in THIS post or not",
  // starting from nothing checked.
  final Map<int, bool> _selection = {};

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(allWatchRecordsProvider);
    final hasSelection = _selection.values.any((checked) => checked);

    return GlassContainer(
      borderRadius: 24,
      opacity: 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.multiSelect ? 'Günlüğünü Paylaş' : 'Film Paylaş',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            widget.multiSelect
                ? 'Bu gönderide paylaşmak istediğin kayıtları işaretle.'
                : 'Toplulukla paylaşmak istediğin bir film/dizi seç.',
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),
          recordsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.accentColor))),
            error: (err, _) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.redAccent))),
            data: (records) {
              if (records.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Henüz bir izleme kaydın yok.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                );
              }

              return Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: records.length,
                  itemBuilder: (context, index) => _buildRow(context, records[index]),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (widget.multiSelect)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: hasSelection ? () => _continueWithSelection(recordsAsync.value ?? []) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.accentColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Devam Et', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, WatchRecordWithMovie r) {
    final poster = r.movie.posterPath;
    final posterWidget = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 36,
        height: 54,
        child: poster != null && poster.isNotEmpty
            ? Image.network(
                '${ApiConstants.imagePathW500}$poster',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.surfaceColor),
              )
            : Container(color: AppTheme.surfaceColor, child: const Icon(Icons.movie_rounded, color: Colors.white24, size: 16)),
      ),
    );

    final title = Text(
      r.movie.title,
      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final date = Text(
      '${r.record.watchDate.day.toString().padLeft(2, '0')}.${r.record.watchDate.month.toString().padLeft(2, '0')}.${r.record.watchDate.year}',
      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
    );

    if (widget.multiSelect) {
      return CheckboxListTile(
        activeColor: AppTheme.accentColor,
        checkColor: Colors.black,
        contentPadding: EdgeInsets.zero,
        secondary: posterWidget,
        title: title,
        subtitle: date,
        value: _selection[r.record.id] ?? false,
        onChanged: (value) {
          setState(() {
            _selection[r.record.id] = value ?? false;
          });
        },
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: posterWidget,
      title: title,
      subtitle: date,
      onTap: () => _shareSingle(context, r),
    );
  }

  void _shareSingle(BuildContext context, WatchRecordWithMovie r) {
    Navigator.pop(context);
    ShareComposeSheet.show(
      context,
      type: 'movie',
      moviePayload: {
        'movieId': r.movie.tmdbId,
        'isTv': r.movie.isTv,
        'movieTitle': r.movie.title,
        'moviePosterPath': r.movie.posterPath,
        'releaseYear': r.movie.releaseYear,
        'rating': r.record.rating,
        'mood': r.record.mood,
        'watchDate': r.record.watchDate,
      },
    );
  }

  void _continueWithSelection(List<WatchRecordWithMovie> records) {
    final entries = records
        .where((r) => _selection[r.record.id] == true)
        .map((r) => {
              'movieId': r.movie.tmdbId,
              'isTv': r.movie.isTv,
              'movieTitle': r.movie.title,
              'moviePosterPath': r.movie.posterPath,
              'rating': r.record.rating,
              'watchDate': r.record.watchDate,
            })
        .toList();

    Navigator.pop(context);
    ShareComposeSheet.show(context, type: 'diary_snapshot', entries: entries);
  }
}
