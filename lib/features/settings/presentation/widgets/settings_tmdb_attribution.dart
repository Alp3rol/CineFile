import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import 'settings_section.dart';

class SettingsTmdbAttribution extends StatelessWidget {
  const SettingsTmdbAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SettingsSection(
      title: l10n.settingsDataProvider,
      child: Column(
        children: [
          Image.asset(
            'assets/images/tmdb_logo.png',
            height: AppSize.iconMd,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.settingsTmdbAttribution,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(height: 1.4),
          ),
          // TMDb's terms ask for the attribution in English. It is shown
          // alongside the localized one, except in English where the two
          // are the same sentence.
          if (Localizations.localeOf(context).languageCode != 'en') ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This product uses the TMDB API but is not endorsed or certified by TMDB.',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
