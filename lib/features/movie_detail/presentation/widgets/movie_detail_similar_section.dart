import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/constants/api_constants.dart';
import '../movie_detail_screen.dart';

class MovieDetailSimilarSection extends StatelessWidget {
  final Map<String, dynamic> movieData;
  final bool isTv;

  const MovieDetailSimilarSection({
    super.key,
    required this.movieData,
    required this.isTv,
  });

  List<Map<String, dynamic>> _extractSimilarList() {
    final seenIds = <int>{};
    final items = <Map<String, dynamic>>[];

    void addFrom(dynamic source) {
      if (source is Map && source['results'] is List) {
        for (final item in source['results']) {
          if (item is Map) {
            final id = item['id'] as int?;
            if (id != null && !seenIds.contains(id)) {
              seenIds.add(id);
              items.add(Map<String, dynamic>.from(item));
            }
          }
        }
      }
    }

    addFrom(movieData['recommendations']);
    addFrom(movieData['similar']);

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final similarItems = _extractSimilarList();

    if (similarItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.movieDetailSimilarTitles,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 195,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            itemCount: similarItems.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = similarItems[index];
              final id = item['id'] as int;
              final title = (item['title'] ?? item['name'] ?? '') as String;
              final posterPath = item['poster_path'] as String?;
              final voteAverage = (item['vote_average'] as num?)?.toDouble();
              final itemIsTv = item['media_type'] == 'tv' || isTv;

              return SizedBox(
                width: 110,
                child: AppPressable(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(
                          tmdbId: id,
                          isTv: itemIsTv,
                        ),
                      ),
                    );
                  },
                  borderRadius: AppRadius.md,
                  semanticLabel: title,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster with Rating Badge
                      Stack(
                        children: [
                          Container(
                            height: 150,
                            width: 110,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.border.withValues(
                                  alpha: AppOpacity.soft,
                                ),
                                width: 0.5,
                              ),
                              image: posterPath != null && posterPath.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        '${ApiConstants.imagePathW500}$posterPath',
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: posterPath == null || posterPath.isEmpty
                                ? const Center(
                                    child: Icon(
                                      Icons.movie_outlined,
                                      color: AppColors.textSecondary,
                                      size: 32,
                                    ),
                                  )
                                : null,
                          ),
                          if (voteAverage != null && voteAverage > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withValues(
                                    alpha: 0.85,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 11,
                                      color: AppColors.rating,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      voteAverage.toStringAsFixed(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                      ),
                    ],
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
