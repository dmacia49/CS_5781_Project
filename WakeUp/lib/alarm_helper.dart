
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'global.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static Future<void> scheduleAlarmNotification(
      int id, DateTime scheduledTime, String title, String body) async {

    var androidDetails = AndroidNotificationDetails(
      'alarm_channel_id',
      'Alarm Notifications',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.high,
      priority: Priority.high,
      // Other Android-specific details can be added here
    );

    //var iosDetails = DarwinNotificationDetails();

    var notificationDetails = NotificationDetails(
      android: androidDetails,
     // iOS: iosDetails,
    );

    // Convert DateTime to TZDateTime
    final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock, // Use schedule mode
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}