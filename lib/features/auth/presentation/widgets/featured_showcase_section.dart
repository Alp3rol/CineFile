import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_provider.dart';
import '../../models/user_model.dart';
import 'featured_movies_stack.dart';
import 'profile_section_header.dart';

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

        // If it's not my profile and there are no featured movies, hide it completely.
        // If it's my profile, we show the box with an empty state and edit button so the owner can set it up!
        if (featuredRecords.isEmpty && !isMe) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.03),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ProfileSectionHeader(title: 'Favori Vitrinim'),
                      if (isMe)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.edit_rounded, color: AppTheme.accentColor, size: 20),
                          onPressed: onEditPressed,
                          tooltip: 'Vitrini Düzenle',
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (featuredRecords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Henüz öne çıkarılan film seçilmedi.',
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
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
