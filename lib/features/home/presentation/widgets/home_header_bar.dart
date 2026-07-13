import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/user_profile_avatar_button.dart';

class HomeHeaderBar extends StatelessWidget {
  const HomeHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoş Geldin,',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              Text(
                'CineFile',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ],
          ),
          // Soft accent glow ring so the avatar reads as a focal point
          // instead of floating in empty space.
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const UserProfileAvatarButton(size: 40),
          ),
        ],
      ),
    );
  }
}
