import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/user_profile_avatar_button.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'CineFile',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (streak > 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.4), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.25),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.orangeAccent),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context).homeStreakDays(streak),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                ),
                child: IconButton(
                  tooltip: AppLocalizations.of(context).settingsTitle,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary, size: 22),
                ),
              ),
              const SizedBox(width: 10),
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
        ],
      ),
    );
  }
}
