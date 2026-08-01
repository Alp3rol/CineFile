import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/movie_repository.dart';

// Dialog to set/clear a movie's personal favorite ranking. Takes tmdbId/isTv
// explicitly rather than reaching into MovieDetailScreen's State, so it can
// be reused/tested independently of that widget.
void showRankDialog(
  BuildContext context,
  WidgetRef ref, {
  required int tmdbId,
  required bool isTv,
  required Map<String, dynamic> movieData,
  required UserMovieSetting? settings,
}) {
  final controller =
      TextEditingController(text: settings?.personalRanking?.toString() ?? '');

  AppDialog.show<void>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);
      final theme = Theme.of(dialogContext);

      Future<bool> save(String raw) async {
        final trimmed = raw.trim();
        final rank = trimmed.isEmpty ? null : int.tryParse(trimmed);
        try {
          await _updateRank(
            ref,
            tmdbId: tmdbId,
            isTv: isTv,
            movieData: movieData,
            settings: settings,
            rank: rank,
          );
          return true;
        } catch (e) {
          if (dialogContext.mounted) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(content: Text(l10n.rankSaveFailed)),
            );
          }
          return false;
        }
      }

      return AlertDialog(
        title: Text(l10n.rankDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rankDialogExplain,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.rankDialogField),
              onChanged: save,
            ),
          ],
        ),
        actions: [
          AppButton(
            label: l10n.commonCancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppButton(
            label: l10n.commonSave,
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              if (await save(controller.text)) {
                navigator.pop();
              }
            },
          ),
        ],
      );
    },
    // Disposed once, after the dialog has closed, whichever way it closed.
    // Both action handlers used to dispose it themselves *as well as* this
    // callback firing, so cancelling or saving disposed the controller twice —
    // which trips ChangeNotifier's debug assertion.
  ).whenComplete(controller.dispose);
}

Future<void> _updateRank(
  WidgetRef ref, {
  required int tmdbId,
  required bool isTv,
  required Map<String, dynamic> movieData,
  required UserMovieSetting? settings,
  required int? rank,
}) {
  return ref.read(movieRepositoryProvider).updatePersonalRankingLocal(
        tmdbId: tmdbId,
        isTv: isTv,
        movieData: movieData,
        settings: settings,
        rank: rank,
      );
}
