import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';
import '../cine_twin_provider.dart';
import '../widgets/cine_twin_header.dart';
import '../widgets/cine_twin_recommendations.dart';

class CineTwinScreen extends ConsumerWidget {
  final String targetUsername;
  final List<Map<String, dynamic>> targetEntries;

  const CineTwinScreen({
    super.key,
    required this.targetUsername,
    required this.targetEntries,
  });

  static void navigate(BuildContext context, String username, List<Map<String, dynamic>> entries) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CineTwinScreen(targetUsername: username, targetEntries: entries),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserName = authState.value?.displayName ?? AppLocalizations.of(context).cineTwinYou;

    final params = CineTwinParams(targetUsername: targetUsername, targetEntries: targetEntries);
    final result = ref.watch(cineTwinProvider(params));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).cineTwinTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: result == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    AppLocalizations.of(context).cineTwinNotEnoughData,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Dual Avatar & Badge)
                    CineTwinHeader(
                      userAName: currentUserName,
                      userBName: '@$targetUsername',
                      result: result,
                    ),

                    const SizedBox(height: 20),

                    // Quick Stats Bar
                    GlassContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.movie_outlined,
                            title: '${result.sharedCount}',
                            subtitle: AppLocalizations.of(context).cineTwinSharedTitles,
                          ),
                          Container(width: 1, height: 28, color: Colors.white12),
                          _buildStatItem(
                            icon: Icons.thumbs_up_down_outlined,
                            title: '${result.ratingDisputes.length}',
                            subtitle: AppLocalizations.of(context).cineTwinRatingGap,
                          ),
                          Container(width: 1, height: 28, color: Colors.white12),
                          _buildStatItem(
                            icon: Icons.auto_awesome_rounded,
                            title: '${result.recommendations.length}',
                            subtitle: AppLocalizations.of(context).cineTwinSharedRecommendation,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Shared Favorites Section ("Ortak Sevilenler")
                    if (result.sharedFavorites.isNotEmpty) ...[
                      Text(
                        AppLocalizations.of(context).cineTwinSharedFavorites,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: result.sharedFavorites.length,
                          itemBuilder: (context, index) {
                            final fav = result.sharedFavorites[index];
                            final posterUrl = fav.posterPath != null
                                ? '${ApiConstants.imagePathW185}${fav.posterPath}'
                                : null;

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetailScreen(tmdbId: fav.tmdbId, isTv: fav.isTv),
                                  ),
                                );
                              },
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: posterUrl != null
                                      ? Image.network(
                                          posterUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.surfaceColor),
                                        )
                                      : Container(color: AppTheme.surfaceColor),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Rating Disputes Section ("Büyük Tartışmalar")
                    if (result.ratingDisputes.isNotEmpty) ...[
                      Text(
                        AppLocalizations.of(context).cineTwinBigDisputes,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      ...result.ratingDisputes.map((dispute) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GlassContainer(
                            borderRadius: 12,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    dispute.recordA.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${dispute.recordA.rating?.toStringAsFixed(1) ?? "-"} vs ${dispute.recordB.rating?.toStringAsFixed(1) ?? "-"}',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // Recommendations Section ("Birlikte Ne İzlemelisiniz?")
                    CineTwinRecommendations(recommendations: result.recommendations),

                    const SizedBox(height: 28),

                    // Share Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showPremiumToast(
                            context,
                            AppLocalizations.of(context).cineTwinCopied(result.matchPercentage),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          AppLocalizations.of(context).cineTwinShareCard,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.accentColor, size: 14),
            const SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
