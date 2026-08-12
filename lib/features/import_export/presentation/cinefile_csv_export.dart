import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/database_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/cinefile_csv_exporter.dart';

Future<void> exportCineFileCsv(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  try {
    final entries = await ref.read(allWatchRecordsProvider.future);
    if (entries.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.cinefileCsvEmpty)));
      }
      return;
    }
    final content = const CineFileCsvExporter().export(entries);
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode('\ufeff$content')),
            mimeType: 'text/csv',
            name: 'cinefile-$stamp.csv',
          ),
        ],
        subject: l10n.cinefileCsvShareSubject,
      ),
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cinefileCsvExportFailed)));
    }
  }
}
