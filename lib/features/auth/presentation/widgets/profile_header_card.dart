import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../community/presentation/widgets/follow_button.dart';
import '../../../insights/presentation/insights_provider.dart';
import '../../../insights/presentation/screens/achievements_grid_screen.dart';
import '../../models/user_model.dart';

class ProfileHeaderCard extends ConsumerWidget {
  final UserModel userModel;
  final bool isMe;
  final bool showFollowButton;
  final String targetUserId;
  final VoidCallback onEditPressed;

  const ProfileHeaderCard({
    super.key,
    required this.userModel,
    required this.isMe,
    required this.showFollowButton,
    required this.targetUserId,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);
    final unlockedCount = insights?.achievementBadges.where((b) => b.isUnlocked).length ?? 0;
    final totalBadges = insights?.achievementBadges.length ?? 28;

    String rankTitle = AppLocalizations.of(context).profileRankNovice;
    if (unlockedCount >= 15) {
      rankTitle = AppLocalizations.of(context).profileRankGuru;
    } else if (unlockedCount >= 8) {
      rankTitle = AppLocalizations.of(context).profileRankConnoisseur;
    } else if (unlockedCount >= 3) {
      rankTitle = AppLocalizations.of(context).profileRankTicketBuddy;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1B4B).withValues(alpha: 0.9),
            const Color(0xFF2E1035).withValues(alpha: 0.9),
            const Color(0xFF0F172A).withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient glow circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              children: [
                // Edit Button on Top Right
                if (isMe)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                      ),
                      onPressed: onEditPressed,
                      tooltip: AppLocalizations.of(context).profileEdit,
                    ),
                  ),

                // Avatar Stack with Glowing Neon Ring & Rank Badge
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.accentColor,
                            Colors.purpleAccent,
                            Colors.amberAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surfaceColor, width: 3),
                          image: DecorationImage(
                            image: NetworkImage(
                              userModel.avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=${userModel.username}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Rank Tag Pill on Avatar Bottom
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentColor, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        rankTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Username Display
                Text(
                  '@${userModel.username}',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                // Bio
                if (userModel.bio != null && userModel.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      userModel.bio!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Combined Glassmorphic Stat Capsule Row (3 Columns)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10, width: 0.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: AppLocalizations.of(context).profileFollowers,
                        value: '${userModel.followerCount}',
                      ),
                      Container(height: 28, width: 1, color: Colors.white12),
                      _StatColumn(
                        label: AppLocalizations.of(context).profileFollowing,
                        value: '${userModel.followingCount}',
                      ),
                      Container(height: 28, width: 1, color: Colors.white12),
                      GestureDetector(
                        onTap: () => AchievementsGridScreen.navigate(context),
                        child: _StatColumn(
                          label: 'Rozetler',
                          value: '$unlockedCount/$totalBadges',
                          valueColor: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Follow / Unfollow Button
                if (showFollowButton) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FollowButton(targetUserId: targetUserId),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
