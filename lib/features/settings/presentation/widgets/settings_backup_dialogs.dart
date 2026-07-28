import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../settings_provider.dart';

// Export/import backup flows for SettingsScreen's "Veri Yönetimi &
// Yedekleme" card — pulled out because both are self-contained (context +
// ref in, dialog side effects out) rather than State methods.

Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  try {
    final dataMap = await BackupService.exportData(ref);
    final jsonString = const JsonEncoder.withIndent('  ').convert(dataMap);

    // Copy to Clipboard
    await Clipboard.setData(ClipboardData(text: jsonString));

    if (context.mounted) {
      // Show backup display modal
      unawaited(showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppTheme.backgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).backupCopiedTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).backupCopiedMessage,
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      jsonString,
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context).commonClose,
                  style: GoogleFonts.outfit(color: AppTheme.accentColor),
                ),
              ),
            ],
          );
        },
      ));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).backupExportError(e.toString()))),
      );
    }
  }
}

void showImportDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context).backupRestoreTitle,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).backupRestoreWarning,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.white),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).backupRestoreHint,
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context).commonCancel,
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final input = controller.text.trim();
              if (input.isEmpty) return;

              try {
                final jsonMap = jsonDecode(input) as Map<String, dynamic>;
                await BackupService.importData(ref, jsonMap);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).backupRestoreSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).backupRestoreInvalid(e.toString())),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppLocalizations.of(context).backupRestoreConfirm,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
