import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';

class WatchlistDetailScreen extends ConsumerWidget {
  const WatchlistDetailScreen({super.key});

  Future<void> _remove(BuildContext context, WidgetRef ref, Movie movie) async {
    final user = ref.currentUser;
    if (user == null) return;
    await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .collection('movie_settings')
        .doc('${movie.tmdbId}_${movie.isTv}')
        .set({
          'movieId': movie.tmdbId,
          'isTv': movie.isTv,
          'isReWatchList': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).watchlistRemoved)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final moviesAsync = ref.watch(watchlistMoviesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.watchlistTitle)),
      body: moviesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (_, _) => Center(child: Text(l10n.collectionsLoadFailed)),
        data: (movies) {
          if (movies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_border_rounded,
                      color: AppColors.textTertiary,
                      size: 58,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.watchlistEmptyTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.watchlistEmptyHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: movies.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _WatchlistMovieTile(
              movie: movies[index],
              onRemove: () => _remove(context, ref, movies[index]),
            ),
          );
        },
      ),
    );
  }
}

class _WatchlistMovieTile extends StatelessWidget {
  const _WatchlistMovieTile({required this.movie, required this.onRemove});

  final Movie movie;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                MovieDetailScreen(tmdbId: movie.tmdbId, isTv: movie.isTv),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppNetworkImage(
                  imageUrl: movie.posterPath == null
                      ? ''
                      : '${ApiConstants.imagePathW185}${movie.posterPath}',
                  seed: movie.title,
                  width: 52,
                  height: 76,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        movie.isTv
                            ? l10n.discoverFilterShows
                            : l10n.discoverFilterMovies,
                        if (movie.releaseYear != null) '${movie.releaseYear}',
                      ].join(' • '),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.watchlistRemove,
                onPressed: onRemove,
                icon: const Icon(
                  Icons.bookmark_remove_rounded,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
