import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inspirational dua reminder messages to rotate daily
  static const List<String> _morningMessages = [
    'Start your day with blessings. Open the app and read your morning Duas.',
    'Begin your morning with the beautiful supplications of the Prophets (AS).',
    'A new day, a new blessing. Read a Dua and seek Allah\'s guidance.',
    'The Prophets started every day with remembrance. Follow their path today.',
    'Bismillah! Let the words of the Prophets guide your morning.',
    'Wake up with gratitude. Read a Dua from the Holy Quran today.',
    'Every morning is a gift. Start it with a prophetic supplication.',
  ];

  static const List<String> _eveningMessages = [
    'End your day with peace and gratitude. Read your evening Duas.',
    'Reflect on your blessings today. Read a Dua before you rest.',
    'The Prophets never forgot to supplicate in the evening. Neither should you.',
    'As the sun sets, turn to Allah with the Duas of the Prophets (AS).',
    'Close your day beautifully — read a supplication from the Quran.',
    'Evening time is the best time for reflection. Open the app and read Duas.',
    'Alhamdulillah for this day. End it with a prophetic Dua.',
  ];

  /// Initializes the local notification plugin and sets up timezone configurations.
  static Future<void> init() async {
    try {
      if (!kIsWeb) {
        tz.initializeTimeZones();
        try {
          final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
          final String timeZoneName = tzInfo is String ? tzInfo : tzInfo.identifier;
          tz.setLocalLocation(tz.getLocation(timeZoneName));
        } catch (e) {
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
          onDidReceiveNotificationResponse: _onNotificationTap,
        );
      }
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Called when the user taps on a notification.
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // The app will be brought to the foreground automatically.
    // If you need deep-link navigation in the future, handle it here.
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

  /// Cancels all scheduled daily reminder notifications.
  static Future<void> cancelDailyReminders() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancel(id: 0); // Morning reminder
      await _notificationsPlugin.cancel(id: 1); // Evening reminder
    } catch (e) {
      debugPrint('NotificationService cancel error: $e');
    }
  }

  /// Schedules two daily notifications:
  /// - Morning Dua Reminder at 9:00 AM
  /// - Evening Dua Reminder at 6:00 PM
  /// Both repeat every day and show rotating inspirational messages.
  static Future<void> scheduleDailyDuaNotification() async {
    if (kIsWeb) return;
    try {
      // Cancel existing scheduled notifications first to prevent duplicates
      await cancelDailyReminders();

      final random = Random();

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_dua_reminder',
        'Daily Dua Reminder',
        channelDescription: 'Reminder to open the app and read daily Duas',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
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

      // Pick a random message for variety
      final morningBody = _morningMessages[random.nextInt(_morningMessages.length)];
      final eveningBody = _eveningMessages[random.nextInt(_eveningMessages.length)];

      // 1. Morning Notification at 7:00 AM
      await _notificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Morning Dua Reminder 🕌',
        body: morningBody,
        scheduledDate: _nextInstanceOfTime(7, 0),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'morning_dua',
      );

      debugPrint('Morning notification scheduled for ${_nextInstanceOfTime(7, 0)}');

      // 2. Evening Notification at 6:00 PM (18:00)
      await _notificationsPlugin.zonedSchedule(
        id: 1,
        title: 'Evening Dua Reminder 🕌',
        body: eveningBody,
        scheduledDate: _nextInstanceOfTime(18, 0),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'evening_dua',
      );

      debugPrint('Evening notification scheduled for ${_nextInstanceOfTime(18, 0)}');
    } catch (e) {
      debugPrint('NotificationService schedule error: $e');
    }
  }

  /// Computes the next occurrence of the given hour:minute in the local timezone.
  /// If the time has already passed today, it returns tomorrow's instance.
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
    if (kIsWeb) return;
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_dua_reminder',
        'Test Notification',
        channelDescription: 'Used for testing/verifying app notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
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
        payload: 'test',
      );
    } catch (e) {
      debugPrint('NotificationService showImmediateTestNotification error: $e');
    }
  }
}
