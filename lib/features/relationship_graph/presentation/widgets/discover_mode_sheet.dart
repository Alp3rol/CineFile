import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/tmdb_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';
import '../../domain/graph_models.dart';

/// Modal sheet for Discover Mode: shows a person's watched titles in the user's
/// library alongside top unwatched recommendations from TMDb.
class DiscoverModeSheet extends ConsumerStatefulWidget {
  final GraphNode personNode;
  final List<GraphNode> watchedNeighbors;

  const DiscoverModeSheet({
    super.key,
    required this.personNode,
    required this.watchedNeighbors,
  });

  static void show(
    BuildContext context, {
    required GraphNode personNode,
    required List<GraphNode> watchedNeighbors,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DiscoverModeSheet(
        personNode: personNode,
        watchedNeighbors: watchedNeighbors,
      ),
    );
  }

  @override
  ConsumerState<DiscoverModeSheet> createState() => _DiscoverModeSheetState();
}

class _DiscoverModeSheetState extends ConsumerState<DiscoverModeSheet> {
  bool _loading = true;
  List<Map<String, dynamic>> _unwatchedCredits = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    if (widget.personNode.tmdbId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final service = ref.read(tmdbServiceProvider);
      final personId = widget.personNode.tmdbId!;
      final credits = await service.getPersonCombinedCredits(personId);

      if (!mounted) return;

      final watchedTmdbIds = widget.watchedNeighbors
          .where((n) => n.tmdbId != null)
          .map((n) => n.tmdbId!)
          .toSet();

      final unwatched = <Map<String, dynamic>>[];
      for (final item in credits) {
        final tmdbId = item['id'] as int?;
        final title = (item['title'] ?? item['name'] ?? '') as String;
        final posterPath = item['poster_path'] as String?;
        final voteAverage = (item['vote_average'] as num?)?.toDouble() ?? 0.0;
        final mediaType = (item['media_type'] as String?) ?? 'movie';

        if (tmdbId != null &&
            !watchedTmdbIds.contains(tmdbId) &&
            title.isNotEmpty &&
            posterPath != null) {
          unwatched.add({
            'id': tmdbId,
            'title': title,
            'posterPath': posterPath,
            'voteAverage': voteAverage,
            'isTv': mediaType == 'tv',
          });
        }
      }

      // Sort by vote average (popularity)
      unwatched.sort((a, b) => (b['voteAverage'] as double)
          .compareTo(a['voteAverage'] as double));

      setState(() {
        _unwatchedCredits = unwatched.take(6).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Öneriler yüklenemedi.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFFC107), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.personNode.label} — Keşif Motoru',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'İzlediğin yapımlar ve kaçırmaman gereken öneriler',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Watched Section
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: AppTheme.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        'Kütüphanendeki Yapımlar (${widget.watchedNeighbors.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.watchedNeighbors.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final item = widget.watchedNeighbors[i];
                        return GestureDetector(
                          onTap: () {
                            if (item.tmdbId != null) {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailScreen(
                                    tmdbId: item.tmdbId!,
                                    isTv: item.isTv,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 48,
                                  height: 68,
                                  child: AppNetworkImage(
                                    imageUrl: item.imageUrl ?? '',
                                    seed: item.label,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Unwatched Recommendations Section
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded,
                          size: 16, color: Color(0xFFFFC107)),
                      const SizedBox(width: 6),
                      const Text(
                        '⭐ Henüz İzlemediğin Popüler Yapımları',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentColor),
                        ),
                      ),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    )
                  else if (_unwatchedCredits.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Bu oyuncunun öne çıkan diğer tüm ana projelerini zaten izlemişsin! Bravo! 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _unwatchedCredits.length,
                      itemBuilder: (context, i) {
                        final item = _unwatchedCredits[i];
                        final posterUrl =
                            'https://image.tmdb.org/t/p/w185${item['posterPath']}';
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailScreen(
                                  tmdbId: item['id'] as int,
                                  isTv: item['isTv'] as bool,
                                ),
                              ),
                            );
                          },
                          child: GlassContainer(
                            borderRadius: 10,
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: AppNetworkImage(
                                      imageUrl: posterUrl,
                                      seed: item['title'] as String,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] as String,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded,
                                              size: 11,
                                              color: Color(0xFFFFC107)),
                                          const SizedBox(width: 2),
                                          Text(
                                            (item['voteAverage'] as double)
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.textSecondary,
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
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
