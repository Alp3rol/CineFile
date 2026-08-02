import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/tmdb_service.dart';
import '../../../actor_profile/presentation/actor_profile_screen.dart';

class MovieDetailCastList extends ConsumerWidget {
  final List<dynamic>? cast;
  final Map<String, dynamic> movieData;

  const MovieDetailCastList({
    super.key,
    required this.cast,
    required this.movieData,
  });

  Future<void> _resolveAndNavigate(BuildContext context, WidgetRef ref, String name) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).castSearching(name)),
          duration: const Duration(seconds: 2),
        ),
      );
      final tmdbService = ref.read(tmdbServiceProvider);
      final resolvedId = await tmdbService.searchPersonId(name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (resolvedId != null) {
          unawaited(Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActorProfileScreen(
                actorId: resolvedId,
                parentMovieData: movieData,
              ),
            ),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).castNotFound(name))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonErrorWithDetail('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cast = this.cast;
    if (cast == null || cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          AppLocalizations.of(context).detailCast,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length > 8 ? 8 : cast.length,
            itemBuilder: (context, idx) {
              final actor = cast[idx];
              final actorId = (actor['id'] as num?)?.toInt();
              final actorName = (actor['name'] ?? '').toString();
              return AppPressable(
                borderRadius: AppRadius.sm,
                semanticLabel: actorName,
                onTap: () async {
                  if (actorId != null) {
                    unawaited(Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActorProfileScreen(
                          actorId: actorId,
                          parentMovieData: movieData,
                        ),
                      ),
                    ));
                  } else {
                    await _resolveAndNavigate(context, ref, actorName);
                  }
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  child: Column(
                    children: [
                      // AppAvatar rather than CircleAvatar + NetworkImage: it
                      // goes through the app's cached, downsampled image path,
                      // which matters in a horizontally scrolling row, and it
                      // falls back to initials instead of a generic person
                      // glyph when a cast member has no photo.
                      AppAvatar(
                        imageUrl: actor['profile_path'] != null
                            ? '${ApiConstants.imagePathW500}${actor['profile_path']}'
                            : null,
                        name: actorName,
                        size: AppSize.avatarLg,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        actorName,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
