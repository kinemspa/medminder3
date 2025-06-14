import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'dose_channel',
      'Dose Reminders',
      importance: Importance.max,
      description: 'Channel for dose reminder notifications',
    );
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.requestNotificationsPermission();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('app_icon');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    final initialized = await _plugin.initialize(settings);
    print('Notification service initialized: $initialized');
  }

  static Future<void> scheduleNotification(String title, String body, DateTime scheduledTime, int id) async {
    print('Scheduling notification: $title at $scheduledTime with ID $id');
    await _plugin.show(
      id + 1000,
      'Debug: $title',
      'Immediate test for $body',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dose_channel',
          'Dose Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.getLocation('Australia/Sydney'));
    print('TZ scheduled time: $tzScheduledTime (UTC: ${tzScheduledTime.toUtc()})');
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'dose_channel',
            'Dose Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Notification scheduled successfully');
    } catch (e) {
      print('Failed to schedule notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    print('Cancelling notification with ID $id');
    await _plugin.cancel(id);
    await _plugin.cancel(id + 1000);
  }
}