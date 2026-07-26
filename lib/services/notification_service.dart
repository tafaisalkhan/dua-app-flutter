import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the local notification plugin and sets up timezone configurations.
  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      try {
        final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
        final String timeZoneName = tzInfo is String ? tzInfo : tzInfo.identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        // Fallback to UTC if device timezone detection fails or in test environment.
        tz.setLocalLocation(tz.UTC);
        debugPrint('Could not get local timezone, falling back to UTC: $e');
      }

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
        return granted ?? true;
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
      await _notificationsPlugin.cancel(id: 1);
    } catch (e) {
      debugPrint('NotificationService cancel error: $e');
    }
  }

  /// Schedules two daily notifications: one in the morning (9:00 AM) and one in the evening (6:00 PM).
  static Future<void> scheduleDailyDuaNotification() async {
    try {
      // Cancel existing scheduled notifications first to prevent multiple notifications
      await cancelDailyReminders();

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

      // 1. Morning Notification at 9:00 AM
      await _notificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Morning Dua Reminder 🕌',
        body: 'Start your day with blessings. Open the app and read your morning Duas.',
        scheduledDate: _nextInstanceOfTime(9, 0),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 2. Evening Notification at 6:00 PM (18:00)
      await _notificationsPlugin.zonedSchedule(
        id: 1,
        title: 'Evening Dua Reminder 🕌',
        body: 'End your day with peace and gratitude. Open the app and read your evening Duas.',
        scheduledDate: _nextInstanceOfTime(18, 0),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('NotificationService schedule error: $e');
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Triggers an immediate test notification to verify that configuration and permissions are working correctly.
  static Future<void> showImmediateTestNotification() async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_dua_reminder',
        'Test Notification',
        channelDescription: 'Used for testing/verifying app notifications',
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

      await _notificationsPlugin.show(
        id: 99,
        title: 'Test Notification 🕌',
        body: 'Alhamdulillah! If you see this, notifications are configured and working correctly.',
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('NotificationService showImmediateTestNotification error: $e');
    }
  }
}
