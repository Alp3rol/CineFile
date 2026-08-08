import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/movie_detail/presentation/add_watch_record_sheet.dart';
import '../../features/movie_detail/presentation/movie_detail_screen.dart';
import '../../l10n/app_localizations.dart';
import '../constants/api_constants.dart';
import '../database/database_provider.dart';
import '../ui/ui.dart';

class MovieQuickActionSheet extends ConsumerWidget {
  final Map<String, dynamic> movieData;

  const MovieQuickActionSheet({super.key, required this.movieData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tmdbId = (movieData['id'] as num?)?.toInt() ?? 0;
    final isTv = movieData['media_type'] == 'tv';
    final title = (movieData['title'] ?? movieData['name'] ?? l10n.titleUnknown).toString();
    final posterPath = (movieData['poster_path'] ?? '').toString();
    final releaseDate = (movieData['release_date'] ?? movieData['first_air_date'] ?? '').toString();
    final year = releaseDate.split('-').first;

    final key = (tmdbId: tmdbId, isTv: isTv);
    final settingsAsync = ref.watch(movieSettingsSnapshotProvider(key));
    final isFav = settingsAsync.value?.isFavorite ?? false;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Movie Info Header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: posterPath.isNotEmpty
                      ? Image.network(
                          '${ApiConstants.imagePathW185}$posterPath',
                          width: 46,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 46,
                            height: 68,
                            color: AppColors.surface,
                            child: const Icon(Icons.movie_rounded, color: AppColors.textSecondary),
                          ),
                        )
                      : Container(
                          width: 46,
                          height: 68,
                          color: AppColors.surface,
                          child: const Icon(Icons.movie_rounded, color: AppColors.textSecondary),
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${year.isNotEmpty ? year : l10n.yearUnknown} ${isTv ? "• Dizi" : "• Film"}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action Items
            _buildActionTile(
              context: context,
              icon: Icons.bookmark_add_rounded,
              label: l10n.quickActionAddRecord,
              iconColor: AppColors.accent,
              onTap: () {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddWatchRecordSheet(movieData: movieData),
                );
              },
            ),
            const Divider(height: 1, color: Colors.white10),

            _buildActionTile(
              context: context,
              icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              label: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
              iconColor: isFav ? Colors.redAccent : AppColors.accent,
              onTap: () async {
                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  final settingsRef = ref
                      .read(firestoreProvider)
                      .collection('users')
                      .doc(user.uid)
                      .collection('movie_settings')
                      .doc('${tmdbId}_$isTv');

                  await settingsRef.set({
                    'movieId': tmdbId,
                    'isTv': isTv,
                    'isFavorite': !isFav,
                    'updatedAt': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                }
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            const Divider(height: 1, color: Colors.white10),

            _buildActionTile(
              context: context,
              icon: Icons.info_outline_rounded,
              label: l10n.quickActionViewDetail,
              iconColor: Colors.white,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MovieDetailScreen(tmdbId: tmdbId, isTv: isTv),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return AppPressable(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
