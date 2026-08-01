import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';

// A single episode row in the episode guide: still image, name/date/overview,
// and a tap-to-toggle watched checkmark.
class TvEpisodeListItem extends StatelessWidget {
  final Map<String, dynamic> episode;
  final int episodeNumber;
  final bool isWatched;
  // Whether this is the next unwatched episode in overall watch order —
  // shows a "Sıradaki" badge and a warm accent border instead of the
  // default unwatched styling.
  final bool isNextUp;
  final VoidCallback onToggleWatched;

  const TvEpisodeListItem({
    super.key,
    required this.episode,
    required this.episodeNumber,
    required this.isWatched,
    this.isNextUp = false,
    required this.onToggleWatched,
  });

  static const double _stillWidth = 100;
  static const double _stillHeight = 60;
  static const double _checkDiameter = 24;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    final epName = episode['name'] as String? ?? l10n.episodeNumbered(episodeNumber);
    final overview = episode['overview'] as String? ?? l10n.episodeNoOverview;
    final stillPath = episode['still_path'] as String?;
    final airDateStr = episode['air_date'] as String? ?? '';

    String formattedDate = '';
    if (airDateStr.isNotEmpty) {
      final date = DateTime.tryParse(airDateStr);
      if (date != null) {
        formattedDate = DateFormat('d MMMM y', 'tr_TR').format(date);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        borderRadius: AppRadius.lg,
        padding: const EdgeInsets.all(AppSpacing.md),
        opacity: isWatched ? AppOpacity.strong : AppOpacity.medium,
        useBlur: false, // Turn off blur for item rows to optimize list scroll performance
        border: Border.all(
          color: isWatched
              ? AppColors.accent.withValues(alpha: AppOpacity.muted)
              : (isNextUp
                  ? AppColors.rating.withValues(alpha: AppOpacity.strong)
                  : AppColors.border),
          width: isWatched || isNextUp ? 1.5 : AppSize.hairline,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode Still Image
            ClipRRect(
              borderRadius: AppRadius.allSm,
              child: AppNetworkImage(
                imageUrl: stillPath != null
                    ? '${ApiConstants.imagePathW500}$stillPath'
                    : '',
                seed: epName,
                width: _stillWidth,
                height: _stillHeight,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Title, Date, Overview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNextUp && !isWatched) ...[
                    AppBadge(
                      label: l10n.episodeUpNext,
                      tone: AppBadgeTone.rating,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Text(
                    '$episodeNumber. $epName',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(formattedDate, style: textTheme.labelSmall),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    overview,
                    style: textTheme.labelMedium?.copyWith(height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Checked circle / checkmark toggle button
            AppPressable(
              key: ValueKey('episode_check_$episodeNumber'),
              onTap: onToggleWatched,
              borderRadius: AppRadius.pill,
              semanticLabel: '$episodeNumber. $epName',
              child: Container(
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                width: _checkDiameter,
                height: _checkDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWatched
                        ? AppColors.accent
                        : AppColors.textPrimary
                            .withValues(alpha: AppOpacity.muted),
                    width: 1.5,
                  ),
                  color: isWatched
                      ? AppColors.accent.withValues(alpha: AppOpacity.soft)
                      : AppColors.transparent,
                ),
                child: isWatched
                    ? const Icon(
                        Icons.check_rounded,
                        size: AppSize.iconSm,
                        color: AppColors.accent,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
