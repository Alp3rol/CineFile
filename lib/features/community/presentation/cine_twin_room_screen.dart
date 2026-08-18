import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ui/ui.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../../relationship_graph/presentation/cine_twin_provider.dart';
import '../../relationship_graph/presentation/screens/cine_twin_screen.dart';
import '../../relationship_graph/presentation/widgets/cine_twin_header.dart';
import '../../relationship_graph/presentation/widgets/cine_twin_recommendations.dart';

class CineTwinRoomScreen extends ConsumerStatefulWidget {
  const CineTwinRoomScreen({super.key});

  @override
  ConsumerState<CineTwinRoomScreen> createState() => _CineTwinRoomScreenState();
}

class _CineTwinRoomScreenState extends ConsumerState<CineTwinRoomScreen> {
  UserModel? _selectedFriend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.watch(authStateProvider).value;
    final followedUserIds = ref.watch(followedUserIdsProvider).value ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.communityCineTwinRoomTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: currentUser == null
            ? Center(
                child: Text(
                  l10n.authSignInRequired,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Banner Card
                  GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: AppRadius.lg,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withValues(alpha: 0.15),
                          ),
                          child: const Icon(
                            Icons.group_work_rounded,
                            color: AppColors.accent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.communityCineTwinRoomTitle,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.communityCineTwinRoomSubtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Friend Selector Header
                  Text(
                    l10n.communityCineTwinSelectFriend,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (followedUserIds.isEmpty)
                    GlassContainer(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      borderRadius: AppRadius.md,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person_search_rounded,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.communityNotFollowingTitle,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.communityNotFollowingHint,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Horizontal Avatars of Followed Users
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: followedUserIds.length,
                        itemBuilder: (context, index) {
                          final friendId = followedUserIds.elementAt(index);
                          final userAsync =
                              ref.watch(userModelStreamProvider(friendId));

                          return userAsync.when(
                            loading: () => const SizedBox(width: 70),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (friend) {
                              if (friend == null) return const SizedBox.shrink();
                              final isSelected =
                                  _selectedFriend?.id == friend.id;

                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedFriend = friend),
                                child: Container(
                                  width: 76,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.accent
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: AppColors.surface,
                                          backgroundImage: NetworkImage(
                                            friend.avatarUrl ??
                                                'https://api.dicebear.com/7.x/bottts/png?seed=${friend.username}',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '@${friend.username}',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? AppColors.accent
                                              : AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Matched Details
                    if (_selectedFriend != null)
                      _buildMatchSection(context, l10n, _selectedFriend!)
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            l10n.communityCineTwinSelectFriend,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildMatchSection(
    BuildContext context,
    AppLocalizations l10n,
    UserModel friend,
  ) {
    final params = CineTwinParams(
      targetUsername: friend.username,
      targetEntries: const [],
      targetTasteGenreIds: friend.shareSwipeTasteForMatching
          ? friend.publicSwipeTasteGenreIds
          : const [],
    );

    final result = ref.watch(cineTwinProvider(params));

    if (result == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            l10n.cineTwinNotEnoughData,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CineTwin Header Card
        CineTwinHeader(
          userAName: l10n.cineTwinYou,
          userBName: '@${friend.username}',
          result: result,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Shared What to Watch Recommendations
        if (result.recommendations.isNotEmpty) ...[
          CineTwinRecommendations(
            recommendations: result.recommendations,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Deep Analysis CTA Button
        AppButton(
          label: l10n.cineTwinTitle,
          icon: Icons.bolt_rounded,
          isFullWidth: true,
          onPressed: () {
            CineTwinScreen.navigate(
              context,
              friend.username,
              const [],
              targetTasteGenreIds: friend.shareSwipeTasteForMatching
                  ? friend.publicSwipeTasteGenreIds
                  : const [],
            );
          },
        ),
      ],
    );
  }
}
