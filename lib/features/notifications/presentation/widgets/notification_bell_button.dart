import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/notification_repository.dart';
import '../notifications_screen.dart';

class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
          width: AppSize.hairline,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: l10n.notificationsTitle,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: Icon(
              unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_outlined,
              color: unreadCount > 0 ? AppColors.accent : AppColors.textSecondary,
              size: AppSize.iconLg,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
