import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

class AlarmManager {
  NotificationService notificationService = NotificationService();

  void scheduleAlarm(DateTime alarmTime) {
    int alarmId = alarmTime.millisecondsSinceEpoch % pow(2, 31).toInt();
    // notificationService.showNotification(
    //   alarmId,
    //   'Alarm',
    //   'Alarm was set !!!! $alarmTime ',
    // );
    // notificationService.zonedScheduleAlarmClockNotification(
    //     alarmId, alarmTime, 'Alarm title', 'alarm body');

    // notificationService.showNotificationWithActions(
    //   alarmId,
    //   'Alarm',
    //   'Alarm was set !!!! $alarmTime ',
    // );
    //notificationService.showInsistentNotification(alarmId);
    // notificationService.showPersistentNotificationWithActions(
    //     alarmId, alarmTime, 'Alarm was set', 'Alarm body');
      notificationService.showFullScreenPersistentNotification(
          alarmId,alarmTime, "alarm", "Alarm was set");
    }
  }

