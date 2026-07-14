import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../main.dart';
import '../../features/movie_detail/presentation/movie_detail_screen.dart';
import '../database/database_provider.dart';
import '../../features/settings/presentation/settings_provider.dart';
import '../../features/auth/controllers/auth_controller.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  // flutter_local_notifications' native implementations reach for
  // platform-channel-backed singletons that are never initialized under
  // flutter_test (no real OS notification surface) — every plugin call
  // throws a LateInitializationError there. It's already caught and
  // logged below, so it never fails a test, but it's noisy on every test
  // that mounts MainShell (which calls initialize()/syncNotifications()
  // unconditionally in initState). Checking the binding's runtime type
  // name avoids a dart:io Platform.environment check, which would break
  // web compilation.
  bool get _isTestEnvironment => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  Future<void> initialize() async {
    if (kIsWeb || _isTestEnvironment) return;

    try {
      // 1. Timezone Database Initialization
      tz.initializeTimeZones();

      // 2. Android Initialization Settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS Initialization Settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 4. Initialize Local Notifications Plugin with named parameter 'settings'
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create high-importance Android channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'release_reminders',
        'Çıkış Hatırlatıcıları',
        description: 'İzleme listendeki film ve dizilerin çıkış günü hatırlatıcıları.',
        importance: Importance.max,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
      }
      
      debugPrint('NotificationService initialized successfully.');
    } catch (e) {
      debugPrint('NotificationService initialization failed: $e');
    }
  }

  /// Request runtime permissions for Android 13+ and iOS
  Future<bool> requestPermissions() async {
    if (kIsWeb || _isTestEnvironment) return false;

    // iOS Request
    final iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted == true) return true;
    }

    // Android 13+ Request
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      if (granted == true) return true;
    }

    return false;
  }

  /// Schedule a local notification on the release date at 10:00 AM
  Future<void> scheduleReleaseReminder({
    required int id,
    required String title,
    required DateTime releaseDate,
    required bool isTv,
  }) async {
    if (kIsWeb || _isTestEnvironment) return;

    try {
      final localTimezone = tz.local;
      final scheduleTime = tz.TZDateTime(
        localTimezone,
        releaseDate.year,
        releaseDate.month,
        releaseDate.day,
        10, // 10:00 AM
        0,
        0,
      );

      if (scheduleTime.isBefore(DateTime.now())) {
        debugPrint('Release date is in the past, skipping notification schedule for: $title');
        return;
      }

      final payload = '$id:$isTv';

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'release_reminders',
        'Çıkış Hatırlatıcıları',
        channelDescription: 'İzleme listendeki film ve dizilerin çıkış günü hatırlatıcıları.',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final String typeText = isTv ? 'yeni bölümü' : 'filmi';
      
      await _notificationsPlugin.zonedSchedule(
        id: id.hashCode,
        title: 'Bugün Çıkıyor! 🎬',
        body: 'İzleme listendeki "$title" $typeText bugün yayınlanıyor.',
        scheduledDate: scheduleTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      debugPrint('Scheduled notification for "$title" at $scheduleTime');
    } catch (e) {
      debugPrint('Failed to schedule notification for "$title": $e');
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelReleaseReminder(int id, bool isTv) async {
    if (kIsWeb || _isTestEnvironment) return;
    try {
      // In v22.0.1, cancel takes a named argument 'id'
      await _notificationsPlugin.cancel(id: id.hashCode);
      debugPrint('Cancelled notification for ID: $id');
    } catch (e) {
      debugPrint('Failed to cancel notification for ID $id: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllReminders() async {
    if (kIsWeb || _isTestEnvironment) return;
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Cancelled all notifications.');
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  /// Synchronize scheduled notifications with the current Firestore settings
  Future<void> syncNotifications() async {
    if (kIsWeb || _isTestEnvironment) return;

    final remindersEnabled = _ref.read(releaseRemindersEnabledProvider);
    if (!remindersEnabled) {
      await cancelAllReminders();
      return;
    }

    try {
      // Fetch all movie settings from Firestore (already loaded re-actively)
      final settingsMap = _ref.read(allMovieSettingsProvider).value ?? {};
      final hasWatchlist = settingsMap.values.any((s) => s.isReWatchList);
      if (!hasWatchlist) {
        await cancelAllReminders();
        return;
      }

      // We need to fetch details for each watchlist item to get their releaseDates
      // Note: we cache releaseDate in Firestore settings doc, let's read it directly.
      final authState = _ref.read(authStateProvider);
      final user = authState.value;
      if (user == null) return;

      final snapshot = await _ref.read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .where('isReWatchList', isEqualTo: true)
          .get();

      // Cancel all existing scheduled notifications first to prevent duplicates/ghost schedules
      await cancelAllReminders();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final tmdbId = data['movieId'] as int? ?? 0;
        final isTv = data['isTv'] as bool? ?? false;
        final releaseDateStr = data['releaseDate'] as String?;

        if (releaseDateStr != null && releaseDateStr.isNotEmpty) {
          final parsedDate = DateTime.tryParse(releaseDateStr);
          if (parsedDate != null && parsedDate.isAfter(DateTime.now())) {
            // Find local movie title or fetch basic title from cache
            final db = _ref.read(databaseProvider);
            final localMovies = await db.select(db.movies).get();
            final localMovie = localMovies.where((m) => m.tmdbId == tmdbId && m.isTv == isTv).firstOrNull;
            final title = localMovie?.title ?? 'İzleme Listendeki Yapım';

            await scheduleReleaseReminder(
              id: tmdbId,
              title: title,
              releaseDate: parsedDate,
              isTv: isTv,
            );
          }
        }
      }
      debugPrint('Synchronized watchlist notifications successfully.');
    } catch (e) {
      debugPrint('Failed to sync notifications: $e');
    }
  }

  /// Callback when notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final parts = payload.split(':');
      if (parts.length != 2) return;

      final tmdbId = int.tryParse(parts[0]);
      final isTv = parts[1] == 'true';

      if (tmdbId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(tmdbId: tmdbId, isTv: isTv),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error navigating from notification tap: $e');
    }
  }
}
