import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E1B4B).withValues(alpha: 0.95),
              const Color(0xFF2E1035).withValues(alpha: 0.95),
              const Color(0xFF0F172A).withValues(alpha: 0.98),
            ],
          ),
          border: Border.all(
            color: badge.isUnlocked ? tier.color.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.18),
            width: badge.isUnlocked ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: badge.isUnlocked ? tier.color.withValues(alpha: 0.3) : Colors.black45,
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
                    : Colors.white.withValues(alpha: 0.05),
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
                  color: badge.isUnlocked ? tier.color : Colors.white24,
                  width: 3.0,
                ),
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 46,
                    color: badge.isUnlocked ? null : Colors.grey.shade600,
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
                      color: index < badge.currentTier ? tier.color : Colors.white24,
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
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badge.category.icon, size: 13, color: AppTheme.accentColor),
                      const SizedBox(width: 5),
                      Text(
                        badge.category.label(AppLocalizations.of(context)),
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
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
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: tier.color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Current Tier Title
            Text(
              badge.isUnlocked ? badge.currentTierTitle : badge.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),

            // Progress Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10, width: 0.6),
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
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isMaxTier ? tier.color : Colors.white70,
                        ),
                      ),
                      Text(
                        isMaxTier
                            ? AppLocalizations.of(context).badgeCurrentCount(badge.currentValue)
                            : '${badge.currentValue} / ${badge.nextTargetValue} (%$pct)',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isMaxTier ? tier.color : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: badge.progress,
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        badge.isUnlocked ? tier.color : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  if (!isMaxTier && badge.nextTierTitle != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context).badgeNextTier(badge.nextTargetValue - badge.currentValue, badge.nextTierTitle!),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                      ),
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
                  backgroundColor: badge.isUnlocked ? tier.color : Colors.white12,
                  foregroundColor: badge.isUnlocked ? Colors.black : Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: badge.isUnlocked ? 4 : 0,
                ),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(
                  AppLocalizations.of(context).badgeShare,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
