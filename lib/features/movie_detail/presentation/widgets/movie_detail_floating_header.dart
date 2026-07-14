import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

// The back / watchlist / favorite / rank buttons floating over the backdrop.
class MovieDetailFloatingHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onToggleWatchlist;
  final bool isReWatchList;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;
  final VoidCallback onRankTap;
  final int? personalRanking;

  const MovieDetailFloatingHeader({
    super.key,
    required this.onBack,
    required this.onToggleWatchlist,
    required this.isReWatchList,
    required this.onToggleFavorite,
    required this.isFavorite,
    required this.onRankTap,
    required this.personalRanking,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onBack,
              child: GlassContainer(
                padding: const EdgeInsets.all(8),
                borderRadius: 12,
                opacity: 0.7,
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
            Row(
              children: [
                // Watchlist toggle button
                GestureDetector(
                  onTap: onToggleWatchlist,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: 12,
                    opacity: 0.7,
                    child: Icon(
                      isReWatchList ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isReWatchList ? AppTheme.accentColor : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Favorite toggle button
                GestureDetector(
                  onTap: onToggleFavorite,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: 12,
                    opacity: 0.7,
                    child: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Rank button
                GestureDetector(
                  onTap: onRankTap,
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    borderRadius: 12,
                    opacity: 0.7,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.format_list_numbered_rounded, color: AppTheme.accentColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          personalRanking != null ? '#$personalRanking' : 'Sıra Belirle',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
