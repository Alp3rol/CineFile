import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../auth/presentation/widgets/user_profile_avatar_button.dart';
import '../../../notifications/presentation/widgets/notification_bell_button.dart';
import '../../../settings/presentation/settings_screen.dart';

class HomeHeaderBar extends StatelessWidget {
  final int streak;

  const HomeHeaderBar({super.key, this.streak = 0});

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return AppLocalizations.of(context).homeGreetingMorning;
    } else if (hour >= 12 && hour < 18) {
      return AppLocalizations.of(context).homeGreetingDay;
    } else if (hour >= 18 && hour < 22) {
      return AppLocalizations.of(context).homeGreetingEvening;
    } else {
      return AppLocalizations.of(context).homeGreetingNight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(context),
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'CineFile',
                        style: textTheme.displayLarge?.copyWith(
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (streak > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      AppBadge(
                        label: l10n.homeStreakDays(streak),
                        icon: Icons.local_fire_department_rounded,
                        tone: AppBadgeTone.warning,
                        shape: AppBadgeShape.pill,
                        outlined: true,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NotificationBellButton(),
              const SizedBox(width: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.textPrimary
                      .withValues(alpha: AppOpacity.faint),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textPrimary
                        .withValues(alpha: AppOpacity.subtle),
                    width: AppSize.hairline,
                  ),
                ),
                child: IconButton(
                  tooltip: l10n.settingsTitle,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.textSecondary,
                    size: AppSize.iconLg,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent
                          .withValues(alpha: AppOpacity.muted),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const UserProfileAvatarButton(size: AppSize.avatarMd),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
