import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// The public version shown in Settings (the build number is intentionally
/// omitted). `tool/check_version_sync.dart` and CI keep this value aligned with
/// `pubspec.yaml`.
///
/// Keep in sync with `version:` in pubspec.yaml.
const String kDisplayedAppVersion = '2.0.0';

class SettingsCreditsFooter extends StatelessWidget {
  const SettingsCreditsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.movie_filter_rounded,
            size: 40,
            color: AppTheme.accentColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            'CineFile',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          Text(
            AppLocalizations.of(context).settingsVersion(kDisplayedAppVersion),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Created with ❤️ by Antigravity & USER',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
