import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
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
          content: Text('$name profili aranıyor...'),
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
            SnackBar(content: Text('$name için profil bulunamadı.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
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
        Text(
          'Oyuncular',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length > 8 ? 8 : cast.length,
            itemBuilder: (context, idx) {
              final actor = cast[idx];
              final actorId = actor['id'] as int?;
              return GestureDetector(
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
                    await _resolveAndNavigate(context, ref, actor['name'] as String);
                  }
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      // Avatar Circle
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.surfaceColor,
                        backgroundImage: actor['profile_path'] != null
                            ? NetworkImage('${ApiConstants.imagePathW500}${actor['profile_path']}')
                            : null,
                        child: actor['profile_path'] == null
                            ? const Icon(Icons.person_rounded, color: Colors.white60)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        actor['name'] as String,
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white),
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
        const SizedBox(height: 20),
      ],
    );
  }
}
