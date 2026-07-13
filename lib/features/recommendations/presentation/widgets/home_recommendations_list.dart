import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../recommendations_provider.dart';

class HomeRecommendationsList extends ConsumerWidget {
  final void Function(int tmdbId, bool isTv) onOpenDetail;

  const HomeRecommendationsList({super.key, required this.onOpenDetail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsProvider);
    final textTheme = Theme.of(context).textTheme;

    return recommendationsAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.accentColor),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Sana Özel Öneriler',
                style: textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 245,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () => onOpenDetail(item.tmdbId, item.isTv),
                    child: Container(
                      width: 130,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster + Rating Badge Stack
                          Stack(
                            children: [
                              Hero(
                                tag: 'poster_${item.tmdbId}_${item.isTv}_rec',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AppNetworkImage(
                                    imageUrl: item.posterPath != null
                                        ? '${ApiConstants.imagePathW500}${item.posterPath}'
                                        : '',
                                    seed: item.title,
                                    height: 180,
                                    width: 130,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // TMDb Rating Badge (bottom-left overlay)
                              if (item.voteAverage > 0)
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0d253f).withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFF90cea1).withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFF90cea1),
                                          size: 10,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          item.voteAverage.toStringAsFixed(1),
                                          style: GoogleFonts.outfit(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          
                          // Reason Badge text
                          Text(
                            item.reason,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF90cea1),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          // Title
                          Text(
                            item.title,
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      },
    );
  }
}
