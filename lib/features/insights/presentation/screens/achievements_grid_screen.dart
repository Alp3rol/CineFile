import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Rozet & Başarım Koleksiyonu',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: insights == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Rozetlerin yüklenmesi için günlüğünüze en az 1 izleme kaydı eklemelisiniz.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
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
    String rankTitle = 'Çaylak Sinefil 🍿';
    String rankSub = 'Sinema yolculuğuna yeni başladın';
    if (unlockedCount >= 15) {
      rankTitle = 'Sinema Gurusu 👑';
      rankSub = 'Gerçek bir kültür abidesi';
    } else if (unlockedCount >= 8) {
      rankTitle = 'Kültür Üstadı 🏛️';
      rankSub = 'Sinematik hafızası yüksek';
    } else if (unlockedCount >= 3) {
      rankTitle = 'Sinema Bilet Ortağı 🎬';
      rankSub = 'Düzenli izleyici';
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1B4B).withValues(alpha: 0.85),
                  const Color(0xFF31103F).withValues(alpha: 0.85),
                  const Color(0xFF0F172A).withValues(alpha: 0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  blurRadius: 25,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.4),
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
                      color: AppTheme.accentColor.withValues(alpha: 0.12),
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
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
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
                                        color: AppTheme.accentColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.5), width: 0.8),
                                      ),
                                      child: Text(
                                        'MEVCUT UNVAN',
                                        style: GoogleFonts.outfit(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accentColor,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '%$percentage',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rankTitle,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  rankSub,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
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
                                'Koleksiyon İlerlemesi',
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '$unlockedCount / $totalCount Rozet Serisi',
                                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
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
                    label: Text('Tümü ($totalCount)', style: const TextStyle(fontSize: 11.5)),
                    selected: selectedCategory == null,
                    onSelected: (_) => setState(() => selectedCategory = null),
                    selectedColor: AppTheme.accentColor,
                    checkmarkColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    labelStyle: TextStyle(
                      color: selectedCategory == null ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                ...AchievementCategory.values.map((cat) {
                  final catCount = allBadges.where((b) => b.category == cat).length;
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(cat.icon, size: 14, color: isSelected ? Colors.black : AppTheme.accentColor),
                      label: Text('${cat.label} ($catCount)', style: const TextStyle(fontSize: 11.5)),
                      selected: isSelected,
                      onSelected: (sel) => setState(() => selectedCategory = sel ? cat : null),
                      selectedColor: AppTheme.accentColor,
                      checkmarkColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
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
                '${filtered.length} Başarım Gösteriliyor',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  Text(
                    'Kazanılanlar',
                    style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: showUnlockedOnly,
                      onChanged: (v) => setState(() => showUnlockedOnly = v),
                      activeThumbColor: AppTheme.accentColor,
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
                      'Seçili filtreye uygun rozet bulunamadı.',
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
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
                                    const Color(0xFF1E1E2E).withValues(alpha: 0.85),
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.04),
                                    Colors.white.withValues(alpha: 0.02),
                                  ],
                          ),
                          border: Border.all(
                            color: badge.isUnlocked
                                ? tier.color.withValues(alpha: 0.7)
                                : Colors.white12,
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
                                    : Colors.white.withValues(alpha: 0.05),
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
                                  color: badge.isUnlocked ? tier.color : Colors.white24,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  badge.icon,
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: badge.isUnlocked ? null : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Badge Title
                            Text(
                              badge.isUnlocked ? badge.currentTierTitle : badge.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: badge.isUnlocked ? Colors.white : Colors.white60,
                                height: 1.2,
                              ),
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
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: tier.color,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                '🔒 Kilitli',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            const Spacer(),

                            // Description
                            Text(
                              badge.description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                color: badge.isUnlocked ? AppTheme.textSecondary : Colors.grey.shade600,
                                height: 1.2,
                              ),
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
                                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        badge.isUnlocked ? tier.color : Colors.grey.shade700,
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '%$pct',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: badge.isUnlocked ? tier.color : Colors.grey,
                                  ),
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
