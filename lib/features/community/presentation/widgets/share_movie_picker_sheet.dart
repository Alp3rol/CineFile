import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
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
      backgroundColor: AppColors.transparent,
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
          const AppSheetHandle(),
          const SizedBox(height: 16),
          Text(
            widget.multiSelect ? AppLocalizations.of(context).shareDiaryTitle : AppLocalizations.of(context).shareMovieTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(
            widget.multiSelect
                ? AppLocalizations.of(context).shareDiaryPickPrompt
                : AppLocalizations.of(context).shareMoviePickPrompt,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          recordsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.accent))),
            error: (err, _) => Center(child: Text(AppLocalizations.of(context).commonErrorWithDetail('$err'), style: const TextStyle(color: AppColors.error))),
            data: (records) {
              if (records.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    AppLocalizations.of(context).shareNoRecords,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
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
              child: AppButton(
                label: AppLocalizations.of(context).shareContinue,
                onPressed: hasSelection
                    ? () => _continueWithSelection(recordsAsync.value ?? [])
                    : null,
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
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surface),
              )
            : Container(color: AppColors.surface, child: const Icon(Icons.movie_rounded, color: AppColors.textTertiary, size: 16)),
      ),
    );

    final title = Text(
      r.movie.title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final date = Text(
      '${r.record.watchDate.day.toString().padLeft(2, '0')}.${r.record.watchDate.month.toString().padLeft(2, '0')}.${r.record.watchDate.year}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
    );

    if (widget.multiSelect) {
      return CheckboxListTile(
        activeColor: AppColors.accent,
        checkColor: AppColors.onAccentAlt,
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
