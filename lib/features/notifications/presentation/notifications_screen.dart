import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinefile/core/l10n/date_text.dart';
import 'package:cinefile/core/ui/ui.dart';
import 'package:cinefile/core/widgets/glass_container.dart';
import 'package:cinefile/features/auth/presentation/user_profile_screen.dart';
import 'package:cinefile/features/movie_detail/presentation/movie_detail_screen.dart';
import 'package:cinefile/l10n/app_localizations.dart';
import '../data/notification_repository.dart';
import '../domain/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(appNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.notificationsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppColors.textSecondary),
            tooltip: l10n.notificationsMarkAllRead,
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onSelected: (value) async {
              if (value == 'clear_read') {
                await ref.read(notificationRepositoryProvider).clearRead();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_read',
                child: Text(
                  l10n.notificationsClearRead,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => Center(
          child: AppErrorState(
            title: l10n.errorGenericTitle,
            onRetry: () => ref.invalidate(appNotificationsProvider),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return _NotificationTile(notification: item);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.notificationsEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notificationsEmptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isUnread = !notification.isRead;

    return GlassContainer(
      opacity: isUnread ? 0.2 : 0.08,
      borderRadius: 16,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleTap(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildTypeIcon(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getNotificationText(l10n),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRelativeTime(context, notification.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isUnread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color color;

    switch (notification.type) {
      case AppNotificationType.comment:
        iconData = Icons.chat_bubble_outline_rounded;
        color = AppColors.accent;
        break;
      case AppNotificationType.star:
        iconData = Icons.star_rounded;
        color = AppColors.rating;
        break;
      case AppNotificationType.follow:
        iconData = Icons.person_add_outlined;
        color = Colors.greenAccent;
        break;
      case AppNotificationType.newEpisode:
        iconData = Icons.tv_rounded;
        color = Colors.purpleAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _getNotificationText(AppLocalizations l10n) {
    final actor = notification.actorName ?? 'Bir kullanıcı';
    switch (notification.type) {
      case AppNotificationType.comment:
        return l10n.notificationComment(actor);
      case AppNotificationType.star:
        return l10n.notificationStar(actor);
      case AppNotificationType.follow:
        return l10n.notificationFollow(actor);
      case AppNotificationType.newEpisode:
        return l10n.notificationNewEpisode;
    }
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (!notification.isRead) {
      ref.read(notificationRepositoryProvider).markRead(notification.id);
    }

    switch (notification.target) {
      case AppNotificationTarget.userProfile:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(userId: notification.targetId),
          ),
        );
        break;
      case AppNotificationTarget.tvShow:
        final tmdbId = int.tryParse(notification.targetId);
        if (tmdbId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(tmdbId: tmdbId, isTv: true),
            ),
          );
        }
        break;
      case AppNotificationTarget.communityPost:
        // Closed safely for community post target or pops back to community
        Navigator.pop(context);
        break;
    }
  }
}
