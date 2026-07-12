import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

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

class BadgesSection extends StatelessWidget {
  final InsightsData data;
  const BadgesSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🏆 Başarılar & Rozetler',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                '${data.badges.where((b) => b.isUnlocked).length} / ${data.badges.length} Kazanıldı',
                style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.12,
          ),
          itemCount: data.badges.length,
          itemBuilder: (context, index) {
            final badge = data.badges[index];
            return GlassContainer(
              borderRadius: 16,
              opacity: badge.isUnlocked ? 0.65 : 0.25,
              border: Border.all(
                color: badge.isUnlocked ? AppTheme.accentColor.withValues(alpha: 0.5) : Colors.white10,
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
                          color: badge.isUnlocked ? AppTheme.accentColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
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
