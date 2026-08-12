import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/letterboxd_csv_parser.dart';

class LetterboxdImportScreen extends StatefulWidget {
  const LetterboxdImportScreen({super.key});

  @override
  State<LetterboxdImportScreen> createState() => _LetterboxdImportScreenState();
}

class _LetterboxdImportScreenState extends State<LetterboxdImportScreen> {
  static const _parser = LetterboxdCsvParser();
  LetterboxdCsvPreview? _preview;
  String? _fileName;
  String? _error;
  bool _loading = false;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = _preview;
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
            onPressed: _loading ? null : _chooseFile,
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
            ...preview.rows.take(20).map((row) => _PreviewTile(row: row)),
          ],
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.row});
  final LetterboxdPreviewRow row;

  @override
  Widget build(BuildContext context) {
    final date = row.watchedDate == null
        ? '—'
        : DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(row.watchedDate!);
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
              : 'Row ${row.rowNumber}: ${row.issues.join(', ')}',
        ),
        trailing: row.rating == null ? null : Text('${row.rating}/5'),
      ),
    );
  }
}
