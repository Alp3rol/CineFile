import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/presentation/user_profile_screen.dart';
import '../../../relationship_graph/presentation/screens/cine_twin_screen.dart';
import 'follow_button.dart';

// Shared row for a user search result — avatar + @username + follower
// count + FollowButton, tapping navigates to that user's profile. Used by
// both the full-page UserSearchScreen and the inline search on
// CommunityFeedScreen so the two entry points stay visually identical.
class UserSearchResultTile extends StatelessWidget {
  final UserModel user;
  const UserSearchResultTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(userId: user.id),
            ),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.border,
              backgroundImage: NetworkImage(
                user.avatarUrl ??
                    'https://api.dicebear.com/7.x/bottts/png?seed=${user.username}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).userFollowerCount(user.followerCount),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(
                Icons.bolt_rounded,
                color: AppColors.accent,
                size: 20,
              ),
              tooltip: AppLocalizations.of(context).cineTwinSeeMatch,
              onPressed: () {
                CineTwinScreen.navigate(
                  context,
                  user.username,
                  [],
                  targetTasteGenreIds: user.shareSwipeTasteForMatching
                      ? user.publicSwipeTasteGenreIds
                      : const [],
                );
              },
            ),
            SizedBox(width: 100, child: FollowButton(targetUserId: user.id)),
          ],
        ),
      ),
    );
  }
}
