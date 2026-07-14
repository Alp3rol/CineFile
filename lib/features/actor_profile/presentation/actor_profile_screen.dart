import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/dynamic_background_wrapper.dart';
import '../../../../core/theme/dynamic_background_provider.dart';
import 'actor_profile_provider.dart';
import 'widgets/actor_profile_header.dart';
import 'widgets/actor_filmography_grid.dart';

class ActorProfileScreen extends ConsumerStatefulWidget {
  final int actorId;
  final Map<String, dynamic>? parentMovieData;

  const ActorProfileScreen({
    super.key,
    required this.actorId,
    this.parentMovieData,
  });

  @override
  ConsumerState<ActorProfileScreen> createState() => _ActorProfileScreenState();
}

class _ActorProfileScreenState extends ConsumerState<ActorProfileScreen> {
  @override
  void dispose() {
    if (widget.parentMovieData != null) {
      try {
        ref.read(dynamicBackgroundProvider.notifier).updateMoviesFromMapList([widget.parentMovieData!]);
      } catch (_) {}
    } else {
      try {
        ref.read(dynamicBackgroundProvider.notifier).clearColors();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(personDetailsProvider(widget.actorId));
    final filmographyAsync = ref.watch(actorFilmographyProvider(widget.actorId));

    // Register active color from actor's profile image to dynamic background
    final actorDetails = detailAsync.valueOrNull;
    if (actorDetails != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final profilePath = actorDetails['profile_path'] as String?;
        final name = actorDetails['name'] as String? ?? 'actor';
        ref.read(dynamicBackgroundProvider.notifier).updateMoviesFromMapList([
          {
            'poster_path': profilePath,
            'name': name,
          }
        ]);
      });
    }

    return DynamicBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: detailAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accentColor),
          ),
          error: (err, stack) => Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Oyuncu bilgileri yüklenemedi: $err',
                  style: GoogleFonts.inter(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          data: (actor) {
            if (actor == null) {
              return const Center(
                child: Text(
                  'Oyuncu bulunamadı.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'Oyuncu Profili',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    centerTitle: true,
                    floating: true,
                    snap: true,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ActorProfileHeader(actor: actor),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                ],
                body: filmographyAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentColor),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Filmografi yüklenemedi: $err',
                      style: GoogleFonts.inter(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (filmography) => ActorFilmographyGrid(filmography: filmography),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
