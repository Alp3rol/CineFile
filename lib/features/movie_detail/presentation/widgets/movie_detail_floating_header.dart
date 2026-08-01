import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';

// The back / watchlist / favorite / rank buttons floating over the backdrop.
class MovieDetailFloatingHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onToggleWatchlist;
  final bool isReWatchList;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;
  final VoidCallback onRankTap;
  final int? personalRanking;

  const MovieDetailFloatingHeader({
    super.key,
    required this.onBack,
    required this.onToggleWatchlist,
    required this.isReWatchList,
    required this.onToggleFavorite,
    required this.isFavorite,
    required this.onRankTap,
    required this.personalRanking,
  });

  /// Glass button over the backdrop. All four controls here were the same
  /// GlassContainer-in-a-GestureDetector written out four times, at the same
  /// radius and opacity — and none of them gave any press feedback.
  Widget _glassButton({
    required VoidCallback onTap,
    required String semanticLabel,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.sm),
  }) {
    return AppPressable(
      onTap: onTap,
      borderRadius: AppRadius.md,
      semanticLabel: semanticLabel,
      child: GlassContainer(
        padding: padding,
        borderRadius: AppRadius.md,
        opacity: AppOpacity.strong,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _glassButton(
              onTap: onBack,
              semanticLabel: l10n.commonCancel,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: AppSize.iconMd,
              ),
            ),
            Row(
              children: [
                _glassButton(
                  onTap: onToggleWatchlist,
                  semanticLabel: l10n.detailAddToMyDiary,
                  child: Icon(
                    isReWatchList
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isReWatchList
                        ? AppColors.accent
                        : AppColors.textPrimary,
                    size: AppSize.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _glassButton(
                  onTap: onToggleFavorite,
                  semanticLabel: l10n.detailSetRank,
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    // Was Colors.red — a fourth red, next to the brand accent,
                    // the error colour and the accent's subtle variant.
                    color: isFavorite
                        ? AppColors.accent
                        : AppColors.textPrimary,
                    size: AppSize.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _glassButton(
                  onTap: onRankTap,
                  semanticLabel: l10n.detailSetRank,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.format_list_numbered_rounded,
                        color: AppColors.accent,
                        size: AppSize.iconSm,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        personalRanking != null
                            ? '#$personalRanking'
                            : l10n.detailSetRank,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
