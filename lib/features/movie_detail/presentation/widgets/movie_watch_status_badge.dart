import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/database/app_database.dart';

// Read-only "Aktif İzliyorum" / "Tamamlandı" indicator for TV shows.
// Actual state is only changed via the Add Watch Record flow.
class MovieWatchStatusBadge extends StatelessWidget {
  final UserMovieSetting? setting;
  final int? totalEpisodes;

  const MovieWatchStatusBadge({
    super.key,
    required this.setting,
    required this.totalEpisodes,
  });

  @override
  Widget build(BuildContext context) {
    final setting = this.setting;
    final totalEpisodes = this.totalEpisodes;
    if (setting == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);

    String? label;
    IconData icon = Icons.play_circle_fill_rounded;
    Color color = AppColors.accent;

    if (setting.isActivelyWatching) {
      final last = setting.lastWatchedEpisode ?? 0;
      label = totalEpisodes != null
          ? l10n.watchStatusWatchingOf(last, totalEpisodes)
          : l10n.watchStatusWatchingEpisode(last);
    } else if (totalEpisodes != null &&
        setting.lastWatchedEpisode != null &&
        setting.lastWatchedEpisode! >= totalEpisodes) {
      label = l10n.watchStatusCompleted;
      icon = Icons.check_circle_rounded;
      color = AppColors.success;
    }

    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSize.iconSm, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
