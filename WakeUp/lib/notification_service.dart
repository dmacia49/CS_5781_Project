import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String urlLaunchActionId = 'id_1';
  static const String navigationActionId = 'id_3';
  static const String secondActionId = 'action_2';
  static const String dismissActionId = 'dismiss_action';

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

  Future<void> showNotificationWithActions(
      int id, String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          urlLaunchActionId,
          'Action 1',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          contextual: true,
        ),
        AndroidNotificationAction(
          'id_2',
          'Action 2',
          titleColor: Color.fromARGB(255, 255, 0, 0),
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        AndroidNotificationAction(
          navigationActionId,
          'Action 3',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          showsUserInterface: true,
          // By default, Android plugin will dismiss the notification when the
          // user tapped on a action (this mimics the behavior on iOS).
          cancelNotification: false,
        ),
      ],
    );
    const LinuxNotificationDetails linuxNotificationDetails =
        LinuxNotificationDetails(
      actions: <LinuxNotificationAction>[
        LinuxNotificationAction(
          key: urlLaunchActionId,
          label: 'Action 1',
        ),
        LinuxNotificationAction(
          key: navigationActionId,
          label: 'Action 2',
        ),
      ],
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      linux: linuxNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', notificationDetails,
        payload: 'item z');
  }

  Future<void> showInsistentNotification(int id) async {
    // This value is from: https://developer.android.com/reference/android/app/Notification.html#FLAG_INSISTENT
    const int insistentFlag = 4;
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            additionalFlags: Int32List.fromList(<int>[insistentFlag]));
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'insistent title', 'insistent body', notificationDetails,
        payload: 'item x');
  }

  Future<void> showPersistentNotificationWithActions(
      int id, String tittle, String body) async {
    // Android-specific notification details
    const int insistentFlag =
        4; // FLAG_INSISTENT value for persistent notifications
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'persistent_channel_id', // Channel ID
      'Persistent Notifications', // Channel name
      channelDescription: 'This channel is for persistent notifications',
      // Channel description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      ongoing: true,
      // Makes the notification non-dismissible
      autoCancel: false,
      // Prevents the notification from auto-dismissing
      additionalFlags: Int32List.fromList(<int>[insistentFlag]),
      // Persistent flag
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          urlLaunchActionId,
          'Action 1',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          contextual: true,
        ),
        AndroidNotificationAction(
          'id2',
          'Action 2',
          titleColor: Color.fromARGB(255, 255, 0, 0),
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        AndroidNotificationAction(
          navigationActionId,
          'Dismiss',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          showsUserInterface: true,
          cancelNotification: true, // Allows dismissal only through this action
        ),
      ],
    );

    // Combine into the notification details
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );


    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      id,
      tittle, // Notification title
      body, // Notification body
      notificationDetails,
      payload: 'persistent_notification_payload',
    );
  }


  Future<void> showFullScreenPersistentNotification(
      int id,DateTime scheduledTime, String title, String body) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'full_screen_channel_id', // Channel ID
      'Full-Screen Notifications', // Channel name
      channelDescription:
          'This channel is for full-screen persistent notifications',
      // Channel description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      fullScreenIntent: true,
      // Enables full-screen intent
      ongoing: true,
      // Prevents user dismissal
      autoCancel: false,
      // Prevents auto-dismissal
      additionalFlags: Int32List.fromList(<int>[
        4, // FLAG_INSISTENT for persistent alert
        268435456 // FLAG_KEEP_SCREEN_ON to prevent minimization
      ]),
      actions: <AndroidNotificationAction>[
        // AndroidNotificationAction(
        //   urlLaunchActionId,
        //   'Action 1',
        //   icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        //   contextual: true,
        // ),
        AndroidNotificationAction(
          secondActionId,
          'Action 2',
          titleColor: Color.fromARGB(255, 255, 0, 0),
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        AndroidNotificationAction(
          dismissActionId,
          'Dismiss',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          showsUserInterface: true,
          cancelNotification: true, // Dismisses the notification
        ),
      ],
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }
}
