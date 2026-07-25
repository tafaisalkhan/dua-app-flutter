import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the local notification plugin and sets up timezone configurations.
  static Future<void> init() async {
    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
      );
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Request permissions for local notifications (specifically for Android 13+ and iOS).
  static Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('NotificationService requestPermissions error: $e');
    }
    return false;
  }

  /// Cancels scheduled notifications.
  static Future<void> cancelDailyReminders() async {
    try {
      await _notificationsPlugin.cancel(id: 0);
    } catch (e) {
      debugPrint('NotificationService cancel error: $e');
    }
  }

  /// Schedules a daily notification to remind the user to open the app and read Duas.
  /// (Modified to hourly for local testing)
  static Future<void> scheduleDailyDuaNotification() async {
    try {
      // Cancel existing scheduled notifications first to prevent multiple notifications
      await _notificationsPlugin.cancel(id: 0);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_dua_reminder',
        'Daily Dua Reminder',
        channelDescription: 'Reminder to open the app and read daily Duas',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule a daily notification at 9:00 AM
      await _notificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Time for Daily Dua 🕌',
        body: 'Start your day with blessings. Open the app and read your daily Duas.',
        scheduledDate: _nextInstanceOfNineAM(),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('NotificationService schedule error: $e');
    }
  }

  static tz.TZDateTime _nextInstanceOfNineAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
