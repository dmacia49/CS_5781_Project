import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

class AlarmManager {
  NotificationService notificationService = NotificationService();

  void scheduleAlarm(DateTime alarmTime) {
    int alarmId = alarmTime.millisecondsSinceEpoch % pow(2,31).toInt();  // Unique ID based on time
    notificationService.showNotification(
      alarmId,
      'Alarm',
      'Alarm was set!!!!',
    );
    notificationService.zonedScheduleAlarmClockNotification(
      alarmId,
      alarmTime,
      'Alarm title',
      'alarm body'
    );
  }
}
