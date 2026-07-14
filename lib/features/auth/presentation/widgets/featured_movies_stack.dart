import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_provider.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';

class FeaturedMoviesStack extends StatefulWidget {
  final List<WatchRecordWithMovie> featuredRecords;
  const FeaturedMoviesStack({super.key, required this.featuredRecords});

  @override
  State<FeaturedMoviesStack> createState() => _FeaturedMoviesStackState();
}

class _FeaturedMoviesStackState extends State<FeaturedMoviesStack> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.featuredRecords.isEmpty) return const SizedBox.shrink();

    final records = widget.featuredRecords;
    final totalCount = records.length;

    final renderIndices = List<int>.generate(totalCount, (index) => index);

    if (_hoveredIndex != null && _hoveredIndex! < totalCount) {
      renderIndices.remove(_hoveredIndex);
      renderIndices.add(_hoveredIndex!);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        const double cardWidth = 120.0;
        const double cardHeight = 180.0;

        // Calculate overlap spacing dynamically to fit perfectly inside the parent container without overflow
        final double spacing = totalCount > 1
            ? ((availableWidth - cardWidth - 24) / (totalCount - 1)).clamp(30.0, 60.0)
            : 0.0;

        final double stackWidth = totalCount > 1
            ? cardWidth + (totalCount - 1) * spacing
            : cardWidth;

        return SizedBox(
          height: 220,
          width: stackWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: renderIndices.map((i) {
              final item = records[i];
              final posterPath = item.movie.posterPath;
              final isHovered = _hoveredIndex == i;

              return AnimatedPositioned(
                key: ValueKey('${item.movie.tmdbId}_$i'),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack, // Premium spring curve for a high-end feel
                left: i * spacing + (isHovered ? 5.0 : 0.0),
                top: isHovered ? 5.0 : 25.0,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = i),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(
                            tmdbId: item.movie.tmdbId,
                            isTv: item.movie.isTv,
                          ),
                        ),
                      );
                    },
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      scale: isHovered ? 1.15 : 1.0,
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isHovered
                                  ? AppTheme.accentColor.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.45),
                              blurRadius: isHovered ? 20 : 8,
                              offset: Offset(0, isHovered ? 10 : 4),
                            ),
                          ],
                          border: Border.all(
                            color: isHovered ? AppTheme.accentColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            posterPath != null && posterPath.isNotEmpty
                                ? 'https://image.tmdb.org/t/p/w342$posterPath'
                                : 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=342',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppTheme.surfaceColor,
                              child: const Icon(Icons.movie_rounded, color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
