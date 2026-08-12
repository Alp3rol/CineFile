import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/network/tmdb_service.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/letterboxd_csv_parser.dart';
import '../domain/tmdb_import_matcher.dart';

class LetterboxdImportScreen extends ConsumerStatefulWidget {
  const LetterboxdImportScreen({super.key});

  @override
  ConsumerState<LetterboxdImportScreen> createState() =>
      _LetterboxdImportScreenState();
}

class _LetterboxdImportScreenState
    extends ConsumerState<LetterboxdImportScreen> {
  static const _parser = LetterboxdCsvParser();
  LetterboxdCsvPreview? _preview;
  final Map<int, ImportRowMatch> _matches = {};
  String? _fileName;
  String? _error;
  bool _loading = false;
  bool _matching = false;

  Future<void> _chooseFile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (result == null) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        throw const LetterboxdCsvException('Could not read the selected file.');
      }
      final preview = _parser.parseBytes(bytes);
      if (!mounted) return;
      setState(() {
        _fileName = file.name;
        _preview = preview;
        _matches.clear();
      });
    } on LetterboxdCsvException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The selected CSV could not be read.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _matchRows() async {
    final rows = _preview?.rows.where((row) => row.isValid).toList();
    if (rows == null || rows.isEmpty) return;
    setState(() {
      _matching = true;
      _matches.clear();
    });
    final service = ref.read(tmdbServiceProvider);
    final matcher = TmdbImportMatcher((query) => service.searchMovies(query));
    for (var start = 0; start < rows.length; start += 4) {
      final chunk = rows.skip(start).take(4);
      final results = await Future.wait(
        chunk.map(
          (row) async => MapEntry(row.rowNumber, await matcher.match(row)),
        ),
      );
      if (!mounted) return;
      setState(() => _matches.addEntries(results));
    }
    if (mounted) setState(() => _matching = false);
  }

  Future<void> _chooseCandidate(int rowNumber, ImportRowMatch match) async {
    final l10n = AppLocalizations.of(context);
    final candidate = await showModalBottomSheet<ImportMatchCandidate>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.letterboxdChooseMatch,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...match.candidates.map(
              (item) => ListTile(
                title: Text(item.title),
                subtitle: Text(
                  '${item.year ?? '—'} • ${item.isTv ? 'TV' : 'Film'}',
                ),
                trailing: Text('${(item.score * 100).round()}%'),
                onTap: () => Navigator.pop(context, item),
              ),
            ),
          ],
        ),
      ),
    );
    if (candidate != null && mounted) {
      setState(() => _matches[rowNumber] = match.confirm(candidate));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = _preview;
    final matched = _matches.values
        .where((item) => item.status == ImportMatchStatus.matched)
        .length;
    final review = _matches.values
        .where((item) => item.status == ImportMatchStatus.needsReview)
        .length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.letterboxdImportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n.letterboxdImportDescription,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.letterboxdChooseCsv,
            icon: Icons.file_open_rounded,
            isFullWidth: true,
            onPressed: _loading || _matching ? null : _chooseFile,
          ),
          if (_loading) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(color: AppColors.accent),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppErrorState(title: l10n.letterboxdInvalidCsv, subtitle: _error),
          ],
          if (preview != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              _fileName ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppBadge(label: l10n.letterboxdTotalRows(preview.rows.length)),
                AppBadge(label: l10n.letterboxdValidRows(preview.validCount)),
                AppBadge(
                  label: l10n.letterboxdInvalidRows(preview.invalidCount),
                ),
                if (_matches.isNotEmpty) ...[
                  AppBadge(
                    label: l10n.letterboxdMatchedRows(matched),
                    tone: AppBadgeTone.success,
                  ),
                  AppBadge(
                    label: l10n.letterboxdReviewRows(review),
                    tone: AppBadgeTone.warning,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.letterboxdPreviewOnly,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: _matching
                  ? l10n.letterboxdMatching(_matches.length, preview.validCount)
                  : l10n.letterboxdMatchTmdb,
              icon: Icons.auto_awesome_rounded,
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
              isLoading: _matching,
              onPressed: preview.validCount == 0 || _matching
                  ? null
                  : _matchRows,
            ),
            const SizedBox(height: AppSpacing.md),
            ...preview.rows
                .take(20)
                .map(
                  (row) => _PreviewTile(
                    row: row,
                    match: _matches[row.rowNumber],
                    onReview: (match) => _chooseCandidate(row.rowNumber, match),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.row,
    required this.match,
    required this.onReview,
  });
  final LetterboxdPreviewRow row;
  final ImportRowMatch? match;
  final ValueChanged<ImportRowMatch> onReview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = row.watchedDate == null
        ? '—'
        : DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(row.watchedDate!);
    final selected = match?.selected;
    final matchLabel = switch (match?.status) {
      ImportMatchStatus.matched =>
        selected == null
            ? l10n.letterboxdMatchedRows(1)
            : '${selected.title} (${selected.year ?? '—'})',
      ImportMatchStatus.needsReview => l10n.letterboxdNeedsReview,
      ImportMatchStatus.notFound => l10n.letterboxdNoMatch,
      ImportMatchStatus.failed => l10n.letterboxdMatchFailed,
      null => null,
    };
    return Card(
      child: ListTile(
        leading: Icon(
          row.isValid ? Icons.check_circle_outline : Icons.error_outline,
          color: row.isValid ? AppColors.accent : AppColors.error,
        ),
        title: Text(row.name.isEmpty ? '—' : row.name),
        subtitle: Text(
          row.isValid
              ? '${row.year ?? '—'} • $date${row.rewatch ? ' • Rewatch' : ''}'
                    '${matchLabel == null ? '' : '\n$matchLabel'}'
              : 'Row ${row.rowNumber}: ${row.issues.join(', ')}',
        ),
        isThreeLine: matchLabel != null,
        trailing: match?.status == ImportMatchStatus.needsReview
            ? IconButton(
                tooltip: l10n.letterboxdChooseMatch,
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => onReview(match!),
              )
            : row.rating == null
            ? null
            : Text('${row.rating}/5'),
      ),
    );
  }
}
