import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_provider.dart';
import '../../models/user_model.dart';
import 'featured_movies_stack.dart';

class FeaturedShowcaseSection extends ConsumerWidget {
  final UserModel userModel;
  final bool isMe;
  final VoidCallback onEditPressed;

  const FeaturedShowcaseSection({
    super.key,
    required this.userModel,
    required this.isMe,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(watchRecordsForUserProvider(userModel.id)).when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (records) {
        final featuredRecords = records
            .where((r) => userModel.featuredMovieIds.contains('${r.movie.tmdbId}'))
            .toList();

        if (featuredRecords.isEmpty && !isMe) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
                border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.accentColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Favori Vitrinim',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (isMe)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, color: AppTheme.accentColor, size: 16),
                          ),
                          onPressed: onEditPressed,
                          tooltip: AppLocalizations.of(context).profileShowcaseEdit,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (featuredRecords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).profileShowcaseNone,
                          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: FeaturedMoviesStack(featuredRecords: featuredRecords),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
