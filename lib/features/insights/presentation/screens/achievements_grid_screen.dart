import '../widgets/achievement_surface.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/achievement_models.dart';
import '../insights_provider.dart';
import '../widgets/badge_detail_dialog.dart';

class AchievementsGridScreen extends ConsumerStatefulWidget {
  const AchievementsGridScreen({super.key});

  static void navigate(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => const AchievementsGridScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  ConsumerState<AchievementsGridScreen> createState() => _AchievementsGridScreenState();
}

class _AchievementsGridScreenState extends ConsumerState<AchievementsGridScreen> {
  AchievementCategory? selectedCategory;
  bool showUnlockedOnly = false;

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).achievementsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: insights == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    AppLocalizations.of(context).achievementsNeedRecords,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              )
            : _buildContent(context, insights),
      ),
    );
  }

  Widget _buildContent(BuildContext context, InsightsData insights) {
    final allBadges = insights.achievementBadges;
    final unlockedCount = allBadges.where((b) => b.isUnlocked).length;
    final totalCount = allBadges.length;
    final ratio = totalCount == 0 ? 0.0 : (unlockedCount / totalCount);
    final percentage = (ratio * 100).toInt();

    // Determine Rank / Title based on unlocked count
    String rankTitle = AppLocalizations.of(context).profileRankNovice;
    String rankSub = AppLocalizations.of(context).achievementsRankNoviceSubtitle;
    if (unlockedCount >= 15) {
      rankTitle = AppLocalizations.of(context).profileRankGuru;
      rankSub = AppLocalizations.of(context).achievementsRankGuruSubtitle;
    } else if (unlockedCount >= 8) {
      rankTitle = AppLocalizations.of(context).profileRankConnoisseur;
      rankSub = AppLocalizations.of(context).achievementsRankConnoisseurSubtitle;
    } else if (unlockedCount >= 3) {
      rankTitle = AppLocalizations.of(context).achievementsRankTicketBuddy;
      rankSub = AppLocalizations.of(context).achievementsRankTicketBuddySubtitle;
    }

    // Filter Badges
    List<AchievementBadge> filtered = allBadges;
    if (selectedCategory != null) {
      filtered = filtered.where((b) => b.category == selectedCategory).toList();
    }
    if (showUnlockedOnly) {
      filtered = filtered.where((b) => b.isUnlocked).toList();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏆 ULTRA-PREMIUM HERO SHOWCASE BANNER
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: achievementPanelGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 25,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Glowing Background Accent Circle
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Glowing Level Trophy Shield
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: achievementHighlightGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentWarmStart.withValues(alpha: AppOpacity.medium),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🏆', style: TextStyle(fontSize: 30)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 0.8),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context).achievementsCurrentRank,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent, letterSpacing: 1.2),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '%$percentage',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: AppColors.accent),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rankTitle,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                Text(
                                  rankSub,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar & Count Ratio
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context).achievementsProgress,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                              Text(
                                '$unlockedCount / $totalCount Rozet Serisi',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🏷️ CATEGORY FILTER CHIPS LIST
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(AppLocalizations.of(context).achievementsAllCount(totalCount), style: const TextStyle(fontSize: 11.5)),
                    selected: selectedCategory == null,
                    onSelected: (_) => setState(() => selectedCategory = null),
                    selectedColor: AppColors.accent,
                    checkmarkColor: AppColors.onAccentAlt,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    labelStyle: TextStyle(
                      color: selectedCategory == null ? AppColors.onAccentAlt : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                  ),
                ),
                ...AchievementCategory.values.map((cat) {
                  final catCount = allBadges.where((b) => b.category == cat).length;
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(cat.icon, size: 14, color: isSelected ? AppColors.onAccentAlt : AppColors.accent),
                      label: Text(AppLocalizations.of(context).achievementsCategoryCount(cat.label(AppLocalizations.of(context)), catCount), style: const TextStyle(fontSize: 11.5)),
                      selected: isSelected,
                      onSelected: (sel) => setState(() => selectedCategory = sel ? cat : null),
                      selectedColor: AppColors.accent,
                      checkmarkColor: AppColors.onAccentAlt,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.onAccentAlt : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // TOGGLE & COUNT BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).achievementsShowing(filtered.length),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).achievementsUnlocked,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 4),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: showUnlockedOnly,
                      onChanged: (v) => setState(() => showUnlockedOnly = v),
                      activeThumbColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 💎 PREMIUM BADGES GRID SHOWCASE
          filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      AppLocalizations.of(context).achievementsNoneForFilter,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.88, // Spacious aspect ratio so no text truncates!
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final badge = filtered[index];
                    final pct = (badge.progress * 100).toInt();
                    final tier = badge.tier;

                    return GestureDetector(
                      onTap: () => BadgeDetailDialog.show(context, badge),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: badge.isUnlocked
                                ? [
                                    tier.color.withValues(alpha: 0.25),
                                    AppColors.surfaceNavy.withValues(alpha: AppOpacity.overlay),
                                  ]
                                : [
                                    AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                                    AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                                  ],
                          ),
                          border: Border.all(
                            color: badge.isUnlocked
                                ? tier.color.withValues(alpha: 0.7)
                                : AppColors.border,
                            width: badge.isUnlocked ? 1.5 : 0.8,
                          ),
                          boxShadow: badge.isUnlocked
                              ? [
                                  BoxShadow(
                                    color: tier.color.withValues(alpha: 0.2),
                                    blurRadius: 14,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : [],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 3D Medallion Icon with Glow Effect
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: badge.isUnlocked
                                    ? tier.color.withValues(alpha: 0.2)
                                    : AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                                boxShadow: badge.isUnlocked
                                    ? [
                                        BoxShadow(
                                          color: tier.color.withValues(alpha: 0.35),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : [],
                                border: Border.all(
                                  color: badge.isUnlocked ? tier.color : AppColors.textTertiary,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  badge.icon,
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: badge.isUnlocked ? null : AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Badge Title
                            Text(
                              badge.isUnlocked ? badge.currentTierTitle : badge.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: badge.isUnlocked ? AppColors.textPrimary : AppColors.textSecondary, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Tier Tag / Stars
                            if (badge.isUnlocked)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${tier.symbol} Lev ${badge.currentTier}/${badge.maxTier}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: tier.color),
                                  ),
                                ],
                              )
                            else
                              Text(
                                AppLocalizations.of(context).badgeLockedLabel,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                              ),

                            const Spacer(),

                            // Description
                            Text(
                              badge.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: badge.isUnlocked ? AppColors.textSecondary : AppColors.textTertiary, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Progress Indicator
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: badge.progress,
                                      backgroundColor: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        badge.isUnlocked ? tier.color : AppColors.textTertiary,
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '%$pct',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: badge.isUnlocked ? tier.color : AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
