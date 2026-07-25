import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/achievement_models.dart';
import '../insights_provider.dart';
import 'badge_detail_dialog.dart';

class LeadersCard extends StatelessWidget {
  final InsightsData data;
  const LeadersCard({super.key, required this.data});

  Widget _buildLeaderList(String title, IconData headerIcon, List<MapEntry<String, int>> items) {
    final topItems = items.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(headerIcon, size: 16, color: AppTheme.accentColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (topItems.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Kayıt bulunamadı.',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
            ),
          )
        else
          ...List.generate(topItems.length, (index) {
            final item = topItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '#${index + 1}',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.key,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${item.value} Kez',
                    style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Directors
        Expanded(
          child: GlassContainer(
            borderRadius: 20,
            opacity: 0.6,
            padding: const EdgeInsets.all(14),
            child: _buildLeaderList('En Çok İzlenen Yönetmenler', Icons.movie_creation_rounded, data.topDirectors),
          ),
        ),
        const SizedBox(width: 12),
        // Top Actors
        Expanded(
          child: GlassContainer(
            borderRadius: 20,
            opacity: 0.6,
            padding: const EdgeInsets.all(14),
            child: _buildLeaderList('En Çok İzlenen Oyuncular', Icons.people_rounded, data.topActors),
          ),
        ),
      ],
    );
  }
}

class BadgesSection extends StatefulWidget {
  final InsightsData data;
  const BadgesSection({super.key, required this.data});

  @override
  State<BadgesSection> createState() => _BadgesSectionState();
}

class _BadgesSectionState extends State<BadgesSection> {
  AchievementCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final allBadges = widget.data.achievementBadges;
    final unlockedCount = allBadges.where((b) => b.isUnlocked).length;

    final filteredBadges = selectedCategory == null
        ? allBadges
        : allBadges.where((b) => b.category == selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🏆 Başarılar & Rozetler',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  '$unlockedCount / ${allBadges.length} Kazanıldı',
                  style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Filter Category Chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text('Tümü (${allBadges.length})', style: const TextStyle(fontSize: 11)),
                  selected: selectedCategory == null,
                  onSelected: (sel) => setState(() => selectedCategory = null),
                  selectedColor: AppTheme.accentColor,
                  labelStyle: TextStyle(
                    color: selectedCategory == null ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              ...AchievementCategory.values.map((cat) {
                final catCount = allBadges.where((b) => b.category == cat).length;
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    avatar: Icon(cat.icon, size: 14, color: isSelected ? Colors.black : AppTheme.accentColor),
                    label: Text('${cat.label} ($catCount)', style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (sel) => setState(() => selectedCategory = sel ? cat : null),
                    selectedColor: AppTheme.accentColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Badges Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemCount: filteredBadges.length,
          itemBuilder: (context, index) {
            final badge = filteredBadges[index];
            return GestureDetector(
              onTap: () => BadgeDetailDialog.show(context, badge),
              child: GlassContainer(
                borderRadius: 16,
                opacity: badge.isUnlocked ? 0.65 : 0.25,
                border: Border.all(
                  color: badge.isUnlocked ? AppTheme.accentColor.withValues(alpha: 0.6) : Colors.white10,
                  width: badge.isUnlocked ? 1.5 : 0.5,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: badge.isUnlocked
                                ? AppTheme.accentColor.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.04),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            badge.icon,
                            style: TextStyle(fontSize: 18, color: badge.isUnlocked ? null : Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            badge.title,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: badge.isUnlocked ? Colors.white : Colors.white54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        badge.description,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          color: badge.isUnlocked ? AppTheme.textSecondary : Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: badge.progress,
                              backgroundColor: Colors.white.withValues(alpha: 0.04),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                badge.isUnlocked ? AppTheme.accentColor : Colors.grey.shade700,
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(badge.progress * 100).toInt()}%',
                          style: GoogleFonts.outfit(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: badge.isUnlocked ? AppTheme.accentColor : Colors.grey,
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
      ],
    );
  }
}

class TagsSection extends StatelessWidget {
  final InsightsData data;
  const TagsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.topTags.isEmpty) {
      return const SizedBox.shrink();
    }
    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🏷️ En Sık Kullanılan Etiketler',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                '${data.topTags.length} Farklı Etiket',
                style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.topTags.take(12).map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${entry.value})',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
