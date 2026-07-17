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
import '../network/tmdb_service.dart';
import '../utils/tv_episode_math.dart';

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

  /// Schedule a reminder for the next unwatched episode of an actively-
  /// tracked TV show, on its air date at 10:00 AM. Uses a distinct ID
  /// namespace ('ep_$tmdbId'.hashCode) from scheduleReleaseReminder's
  /// (tmdbId.hashCode) so a show that's both on the watchlist AND actively
  /// being watched can have both reminder kinds scheduled without colliding.
  Future<void> scheduleNextEpisodeReminder({
    required int tmdbId,
    required String showTitle,
    required int seasonNumber,
    required int episodeNumber,
    required DateTime airDate,
  }) async {
    if (kIsWeb || _isTestEnvironment) return;

    try {
      final localTimezone = tz.local;
      final scheduleTime = tz.TZDateTime(
        localTimezone,
        airDate.year,
        airDate.month,
        airDate.day,
        10, // 10:00 AM
        0,
        0,
      );

      if (scheduleTime.isBefore(DateTime.now())) {
        debugPrint('Episode air date is in the past, skipping notification schedule for: $showTitle');
        return;
      }

      final payload = 'episode:$tmdbId:true:$seasonNumber:$episodeNumber';

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

      await _notificationsPlugin.zonedSchedule(
        id: 'ep_$tmdbId'.hashCode,
        title: 'Yeni Bölüm! 🎬',
        body: '"$showTitle" dizisinin $seasonNumber. sezon $episodeNumber. bölümü bugün yayınlanıyor.',
        scheduledDate: scheduleTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      debugPrint('Scheduled episode notification for "$showTitle" S$seasonNumber E$episodeNumber at $scheduleTime');
    } catch (e) {
      debugPrint('Failed to schedule episode notification for "$showTitle": $e');
    }
  }

  /// Cancel a scheduled next-episode reminder for a show
  Future<void> cancelNextEpisodeReminder(int tmdbId) async {
    if (kIsWeb || _isTestEnvironment) return;
    try {
      await _notificationsPlugin.cancel(id: 'ep_$tmdbId'.hashCode);
      debugPrint('Cancelled episode notification for tmdbId: $tmdbId');
    } catch (e) {
      debugPrint('Failed to cancel episode notification for tmdbId $tmdbId: $e');
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

  /// Synchronize scheduled notifications with the current Firestore settings.
  /// Two independent notification kinds are synced here: (1) release-date
  /// reminders for watchlist items, (2) next-episode reminders for TV shows
  /// currently being actively watched. Neither kind depends on the other
  /// being present — a show can be actively watched without being on the
  /// watchlist, so both loops run unconditionally rather than early-
  /// returning off just the watchlist check.
  Future<void> syncNotifications() async {
    if (kIsWeb || _isTestEnvironment) return;

    final remindersEnabled = _ref.read(releaseRemindersEnabledProvider);
    if (!remindersEnabled) {
      await cancelAllReminders();
      return;
    }

    final authState = _ref.read(authStateProvider);
    final user = authState.value;
    if (user == null) return;

    // Cancel all existing scheduled notifications first to prevent
    // duplicates/ghost schedules, then let both loops below rebuild from
    // scratch (same brute-force dedup strategy the release-reminder sync
    // always used).
    await cancelAllReminders();

    // Fetch all movie settings from Firestore (already loaded re-actively)
    final settingsMap = _ref.read(allMovieSettingsProvider).value ?? {};

    try {
      final hasWatchlist = settingsMap.values.any((s) => s.isReWatchList);
      if (hasWatchlist) {
        final snapshot = await _ref.read(firestoreProvider)
            .collection('users')
            .doc(user.uid)
            .collection('movie_settings')
            .where('isReWatchList', isEqualTo: true)
            .get();

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
      }
      debugPrint('Synchronized watchlist release-date notifications successfully.');
    } catch (e) {
      debugPrint('Failed to sync release-date notifications: $e');
    }

    try {
      final tmdbService = _ref.read(tmdbServiceProvider);
      final activelyWatching = settingsMap.entries.where((e) => e.key.isTv && e.value.isActivelyWatching);

      for (final entry in activelyWatching) {
        final tmdbId = entry.key.tmdbId;
        final setting = entry.value;
        try {
          final showDetails = await tmdbService.getMovieDetails(tmdbId, isTv: true);
          final seasons = showDetails?['seasons'] as List<dynamic>? ?? [];
          final sorted = sortedRegularSeasons(seasons);
          final nextOverallIndex = (setting.lastWatchedEpisode ?? 0) + 1;
          final mapping = mapOverallIndexToSeasonEpisode(sorted, nextOverallIndex);
          if (mapping == null) continue; // show fully watched, or no season data

          final seasonData = await tmdbService.getTvSeasonDetails(tmdbId, mapping.seasonNumber);
          final episodes = (seasonData?['episodes'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
          final episodeData = episodes.where((e) => e['episode_number'] == mapping.episodeNumberInSeason).firstOrNull;
          final airDateStr = episodeData?['air_date'] as String?;
          if (airDateStr == null || airDateStr.isEmpty) continue;

          final airDate = DateTime.tryParse(airDateStr);
          if (airDate == null || !airDate.isAfter(DateTime.now())) continue;

          final title = (showDetails?['name'] ?? showDetails?['original_name']) as String? ?? 'Takip Ettiğin Dizi';

          await scheduleNextEpisodeReminder(
            tmdbId: tmdbId,
            showTitle: title,
            seasonNumber: mapping.seasonNumber,
            episodeNumber: mapping.episodeNumberInSeason,
            airDate: airDate,
          );
        } catch (e) {
          debugPrint('Bölüm bildirimi planlanamadı (tmdbId: $tmdbId): $e');
        }
      }
      debugPrint('Synchronized next-episode notifications successfully.');
    } catch (e) {
      debugPrint('Failed to sync episode notifications: $e');
    }
  }

  /// Callback when notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final parts = payload.split(':');

      // Episode reminders use a 5-part 'episode:tmdbId:isTv:season:episode'
      // payload; there's no dedicated episode-guide sub-route today, so this
      // opens the show's detail page directly (its Bölüm Rehberi section is
      // already visible there).
      if (parts.length == 5 && parts[0] == 'episode') {
        final tmdbId = int.tryParse(parts[1]);
        final isTv = parts[2] == 'true';
        if (tmdbId != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(tmdbId: tmdbId, isTv: isTv),
            ),
          );
        }
        return;
      }

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
