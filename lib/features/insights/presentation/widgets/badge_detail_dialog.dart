import 'achievement_surface.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../domain/achievement_models.dart';

class BadgeDetailDialog extends StatelessWidget {
  final AchievementBadge badge;

  const BadgeDetailDialog({super.key, required this.badge});

  static void show(BuildContext context, AchievementBadge badge) {
    showDialog(
      context: context,
      builder: (_) => BadgeDetailDialog(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = (badge.progress * 100).toInt();
    final tier = badge.tier;
    final isMaxTier = badge.isUnlocked && badge.currentTier >= badge.maxTier;

    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: achievementPanelGradient,
          border: Border.all(
            color: badge.isUnlocked ? tier.color.withValues(alpha: 0.8) : AppColors.textPrimary.withValues(alpha: AppOpacity.soft),
            width: badge.isUnlocked ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: badge.isUnlocked ? tier.color.withValues(alpha: 0.3) : AppColors.shadow.withValues(alpha: AppOpacity.medium),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D Medallion Icon with Glow Effect
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.isUnlocked
                    ? tier.color.withValues(alpha: 0.2)
                    : AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                boxShadow: badge.isUnlocked
                    ? [
                        BoxShadow(
                          color: tier.color.withValues(alpha: 0.45),
                          blurRadius: 25,
                          spreadRadius: 3,
                        )
                      ]
                    : [],
                border: Border.all(
                  color: badge.isUnlocked ? tier.color : AppColors.textTertiary,
                  width: 3.0,
                ),
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 46,
                    color: badge.isUnlocked ? null : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tier Stars Row
            if (badge.isUnlocked) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  badge.maxTier,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      Icons.star_rounded,
                      size: 22,
                      color: index < badge.currentTier ? tier.color : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Badge Category & Tier Tag
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badge.category.icon, size: 13, color: AppColors.accent),
                      const SizedBox(width: 5),
                      Text(
                        badge.category.label(AppLocalizations.of(context)),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
                if (badge.isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: tier.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tier.color, width: 1.0),
                    ),
                    child: Text(
                      AppLocalizations.of(context).badgeTierLevel(tier.symbol, tier.label(AppLocalizations.of(context)), badge.currentTier, badge.maxTier),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: tier.color),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Current Tier Title
            Text(
              badge.isUnlocked ? badge.currentTierTitle : badge.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 22),

            // Progress Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.6),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isMaxTier
                            ? AppLocalizations.of(context).badgeMaxLevel
                            : badge.isUnlocked
                                ? AppLocalizations.of(context).badgeNextLevelProgress
                                : AppLocalizations.of(context).badgeUnlockProgress,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: isMaxTier ? tier.color : AppColors.textSecondary),
                      ),
                      Text(
                        isMaxTier
                            ? AppLocalizations.of(context).badgeCurrentCount(badge.currentValue)
                            : '${badge.currentValue} / ${badge.nextTargetValue} (%$pct)',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: isMaxTier ? tier.color : AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: badge.progress,
                      minHeight: 7,
                      backgroundColor: AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        badge.isUnlocked ? tier.color : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  if (!isMaxTier && badge.nextTierTitle != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context).badgeNextTier(badge.nextTargetValue - badge.currentValue, badge.nextTierTitle!),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.accent),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  final titleText = badge.isUnlocked ? badge.currentTierTitle : badge.title;
                  showPremiumToast(
                    context,
                    AppLocalizations.of(context).badgeCopied(titleText),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: badge.isUnlocked ? tier.color : AppColors.border,
                  foregroundColor: badge.isUnlocked ? AppColors.onAccentAlt : AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: badge.isUnlocked ? 4 : 0,
                ),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(
                  AppLocalizations.of(context).badgeShare,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
