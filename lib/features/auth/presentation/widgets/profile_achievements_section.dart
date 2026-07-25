import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../insights/presentation/insights_provider.dart';
import '../../../insights/presentation/screens/achievements_grid_screen.dart';
import '../../../insights/presentation/widgets/badge_detail_dialog.dart';

class ProfileAchievementsSection extends ConsumerWidget {
  const ProfileAchievementsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);

    if (insights == null) {
      return const SizedBox.shrink();
    }

    final allBadges = insights.achievementBadges;
    final unlockedBadges = allBadges.where((b) => b.isUnlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: AppTheme.accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Kazanılan Rozetler',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => AchievementsGridScreen.navigate(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Tümünü Gör (${unlockedBadges.length}/${allBadges.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.accentColor),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (unlockedBadges.isEmpty)
          GestureDetector(
            onTap: () => AchievementsGridScreen.navigate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10, width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_outlined, color: Colors.white38, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Henüz kazanılmış bir rozet yok. Film izledikçe kilitler açılacaktır! Tümünü incelemek için tıklayın.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 125, // Spacious height so nothing ever truncates!
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: unlockedBadges.length,
              itemBuilder: (context, index) {
                final badge = unlockedBadges[index];
                final tier = badge.tier;

                return Container(
                  width: 104,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => BadgeDetailDialog.show(context, badge),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tier.color.withValues(alpha: 0.2),
                            const Color(0xFF1E1E2E).withValues(alpha: 0.8),
                          ],
                        ),
                        border: Border.all(
                          color: tier.color.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tier.color.withValues(alpha: 0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 3D Medallion Circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tier.color.withValues(alpha: 0.2),
                              border: Border.all(color: tier.color, width: 1.8),
                              boxShadow: [
                                BoxShadow(
                                  color: tier.color.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                badge.icon,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Title
                          Text(
                            badge.currentTierTitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Tier Tag
                          Text(
                            '${tier.symbol} Lev ${badge.currentTier}/${badge.maxTier}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: tier.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
