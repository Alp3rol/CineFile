import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/achievement_models.dart';
import '../insights_provider.dart';
import 'badge_detail_dialog.dart';

class LeadersCard extends StatelessWidget {
  final InsightsData data;
  const LeadersCard({super.key, required this.data});

  Widget _buildLeaderList(BuildContext context, String title, IconData headerIcon, List<MapEntry<String, int>> items) {
    final topItems = items.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(headerIcon, size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
              AppLocalizations.of(context).insightsNoRecords,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ...List.generate(topItems.length, (index) {
            final item = topItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '#${index + 1}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.key,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${item.value} Kez',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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
            child: _buildLeaderList(context, AppLocalizations.of(context).insightsTopDirectors, Icons.movie_creation_rounded, data.topDirectors),
          ),
        ),
        const SizedBox(width: 12),
        // Top Actors
        Expanded(
          child: GlassContainer(
            borderRadius: 20,
            opacity: 0.6,
            padding: const EdgeInsets.all(14),
            child: _buildLeaderList(context, AppLocalizations.of(context).insightsTopActors, Icons.people_rounded, data.topActors),
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
                AppLocalizations.of(context).insightsBadgesTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  AppLocalizations.of(context).insightsBadgesEarned(unlockedCount, allBadges.length),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
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
                  label: Text(AppLocalizations.of(context).achievementsAllCount(allBadges.length), style: const TextStyle(fontSize: 11)),
                  selected: selectedCategory == null,
                  onSelected: (sel) => setState(() => selectedCategory = null),
                  selectedColor: AppColors.accent,
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
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    avatar: Icon(cat.icon, size: 14, color: isSelected ? AppColors.onAccentAlt : AppColors.accent),
                    label: Text('${cat.label} ($catCount)', style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (sel) => setState(() => selectedCategory = sel ? cat : null),
                    selectedColor: AppColors.accent,
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
                  color: badge.isUnlocked ? AppColors.accent.withValues(alpha: 0.6) : AppColors.border,
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
                                ? AppColors.accent.withValues(alpha: 0.15)
                                : AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            badge.icon,
                            style: TextStyle(fontSize: 18, color: badge.isUnlocked ? null : AppColors.textTertiary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            badge.title,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: badge.isUnlocked ? AppColors.textPrimary : AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        badge.description,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: badge.isUnlocked ? AppColors.textSecondary : AppColors.textTertiary, height: 1.3),
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
                              backgroundColor: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                badge.isUnlocked ? AppColors.accent : AppColors.textTertiary,
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(badge.progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: badge.isUnlocked ? AppColors.accent : AppColors.textTertiary),
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
                AppLocalizations.of(context).insightsTopTagsTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                AppLocalizations.of(context).insightsDistinctTags(data.topTags.length),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
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
                  color: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${entry.value})',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
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
