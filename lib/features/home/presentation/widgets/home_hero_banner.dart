import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';

/// Cinematic hero card at the top of the home screen — a large backdrop with
/// a bottom gradient fade. Prefers a "Bu Hafta Ne İzlesem?" suggestion (an
/// unwatched title); when the library has nothing left unwatched, falls back
/// to the most recently watched title instead of disappearing entirely, so
/// the screen always has a visual anchor at the top for active users too.
class HomeHeroBanner extends StatelessWidget {
  final Movie movie;
  final bool isSuggestion;
  final VoidCallback? onRefresh;
  final VoidCallback onTap;

  const HomeHeroBanner({
    super.key,
    required this.movie,
    required this.isSuggestion,
    this.onRefresh,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backdropPath = movie.backdropPath;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              height: 360,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: backdropPath != null ? '${ApiConstants.imagePathW780}$backdropPath' : '',
                    seed: movie.title,
                    width: MediaQuery.of(context).size.width - 40,
                    height: 360,
                    fit: BoxFit.cover,
                  ),
                  // Multi-stop cinematic gradient for rich backdrop contrast
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.25, 0.65, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),

                  // Top Header Badge Row
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Glass Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSuggestion ? Icons.auto_awesome_rounded : Icons.history_rounded,
                                color: isSuggestion ? Colors.amberAccent : AppTheme.accentColor,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSuggestion ? AppLocalizations.of(context).homeHeroWhatToWatch : AppLocalizations.of(context).homeHeroLastWatched,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Refresh button if suggestion
                        if (isSuggestion && onRefresh != null)
                          GestureDetector(
                            onTap: onRefresh,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                              ),
                              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Bottom Content & CTA
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Meta Info Row (Year & Format Tag)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.5), width: 1),
                              ),
                              child: Text(
                                movie.isTv ? AppLocalizations.of(context).homeHeroShowBadge : AppLocalizations.of(context).homeHeroMovieBadge,
                                style: const TextStyle(
                                  color: AppTheme.accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (movie.releaseYear != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${movie.releaseYear}',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          movie.title,
                          style: textTheme.displayMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            shadows: [
                              const Shadow(color: Colors.black, blurRadius: 12),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Action Button
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentColor,
                                    AppTheme.accentColor.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentColor.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppLocalizations.of(context).homeHeroDetails,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}
