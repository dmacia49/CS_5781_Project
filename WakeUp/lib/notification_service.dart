import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    var androidSettings = AndroidInitializationSettings('app_icon');
    var settings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> showNotification(int id, String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
        id, title, body, notificationDetails);
  }

  Future<void> zonedScheduleAlarmClockNotification(
      int id, DateTime scheduledTime, String tittle, String body) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        tittle,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'alarm_clock_channel', 'Alarm Clock Channel',
                channelDescription: 'Alarm Clock Notification')),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }


}
