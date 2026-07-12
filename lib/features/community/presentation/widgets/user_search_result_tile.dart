import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/presentation/user_profile_screen.dart';
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
            MaterialPageRoute(builder: (_) => UserProfileScreen(userId: user.id)),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.borderColor,
              backgroundImage: NetworkImage(
                user.avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=${user.username}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${user.username}',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.followerCount} takipçi',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(width: 110, child: FollowButton(targetUserId: user.id)),
          ],
        ),
      ),
    );
  }
}
