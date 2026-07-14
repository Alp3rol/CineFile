import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../community/presentation/widgets/follow_button.dart';
import '../../models/user_model.dart';

class ProfileHeaderCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Radial background glow for avatar depth
        Positioned(
          top: 20,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentColor.withValues(alpha: 0.25),
                  Colors.purple.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // The main card
        GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Stack(
            children: [
              if (isMe)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white70),
                    onPressed: onEditPressed,
                    tooltip: 'Profili Düzenle',
                  ),
                ),
              Column(
                children: [
                  // Glowing border around Avatar
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentColor,
                          Colors.purpleAccent,
                          Colors.blueAccent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceColor, width: 2.5),
                        image: DecorationImage(
                          image: NetworkImage(
                            userModel.avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=${userModel.username}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username with modern Outfit styling
                  Text(
                    '@${userModel.username}',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (userModel.bio != null && userModel.bio!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        userModel.bio!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Stats inside capsule row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PremiumStatCapsule(label: 'Takipçi', value: '${userModel.followerCount}'),
                      const SizedBox(width: 16),
                      _PremiumStatCapsule(label: 'Takip', value: '${userModel.followingCount}'),
                    ],
                  ),
                  // Follow / Unfollow Button within the header card
                  if (showFollowButton) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FollowButton(targetUserId: targetUserId),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumStatCapsule extends StatelessWidget {
  final String label;
  final String value;
  const _PremiumStatCapsule({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
