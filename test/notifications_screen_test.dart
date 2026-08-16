import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/core/services/app_settings_store.dart';
import 'package:cinefile/features/notifications/data/notification_repository.dart';
import 'package:cinefile/features/notifications/domain/app_notification.dart';
import 'package:cinefile/features/notifications/presentation/notifications_screen.dart';
import 'package:cinefile/features/notifications/presentation/widgets/notification_bell_button.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'package:cinefile/l10n/app_localizations.dart';

import 'support/network_image_mock.dart';

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  testWidgets('NotificationsScreen renders empty state when no notifications present', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
          appNotificationsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Bildirimler'), findsOneWidget);
    expect(find.text('Bildiriminiz Yok'), findsOneWidget);
  });

  testWidgets('NotificationsScreen renders notification tiles when notifications present', (WidgetTester tester) async {
    final now = DateTime.now();
    final sampleNotifications = [
      AppNotification(
        id: 'n1',
        type: AppNotificationType.comment,
        target: AppNotificationTarget.communityPost,
        targetId: 'p1',
        createdAt: now.subtract(const Duration(minutes: 5)),
        actorId: 'u1',
        actorName: 'Ahmet',
      ),
      AppNotification(
        id: 'n2',
        type: AppNotificationType.follow,
        target: AppNotificationTarget.userProfile,
        targetId: 'u2',
        createdAt: now.subtract(const Duration(hours: 1)),
        actorId: 'u2',
        actorName: 'Ayşe',
        readAt: now,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
          appNotificationsProvider.overrideWith((ref) => Stream.value(sampleNotifications)),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ahmet gönderine yorum yaptı.'), findsOneWidget);
    expect(find.text('Ayşe seni takip etmeye başladı.'), findsOneWidget);
  });

  testWidgets('NotificationBellButton renders unread badge when unread notifications exist', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(AppSettingsStore())..setLocale(const Locale('tr')),
          ),
          appNotificationsProvider.overrideWith(
            (ref) => Stream.value([
              AppNotification(
                id: 'n1',
                type: AppNotificationType.star,
                target: AppNotificationTarget.communityPost,
                targetId: 'p1',
                createdAt: DateTime.now(),
                actorName: 'Mehmet',
              ),
            ]),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: NotificationBellButton()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
