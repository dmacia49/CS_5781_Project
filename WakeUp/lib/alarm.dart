import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:wakeup/alarminfo.dart';
import 'package:wakeup/data.dart';
import 'alarm_helper.dart';
import 'colors/css.dart';
import 'main.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();

}

class _AlarmPageState extends State<AlarmPage> {
  TextEditingController _titleController = TextEditingController();
  DateTime? selectedDate; // Declare the selectedDate variable
  TimeOfDay? _selectedTime;



  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Alarm',
            style: TextStyle(
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
                fontSize: 24),
          ),
          Expanded(
            child: ListView(
              children: alarms.map<Widget>((alarm) {
                var alarmTime =
                    DateFormat('hh:mm aa').format(alarm.alarmDateTime);
                var alarmDate = DateFormat('yMMMd').format(alarm.alarmDateTime);
                return Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: alarm.gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: alarm.gradientColors.last.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 4,
                            offset: Offset(4, 4))
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.label,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                alarm.title!,
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'avenir'),
                              ),
                            ],
                          ),
                          Switch(
                            onChanged: (bool value) {},
                            value: true,
                            activeColor: Colors.white,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                alarms.remove(alarm);
                              });
                            },
                            icon: Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        alarmDate,
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'avenir'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            alarmTime,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'avenir',
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 36,
                            color: Colors.white,
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }).followedBy([
                Container(
                  decoration: BoxDecoration(
                      color: CustomColors.clockBG,
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddAlarmDialog(
                            onAddAlarm: (AlarmInfo newAlarm) {
                              setState(() {
                                alarms.add(newAlarm);
                                _zonedScheduleAlarmClockNotification();// Add the new alarm to the list
                              });
                            },
                          );
                        },
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset('assets/add_alarm.png', scale: 1.5),
                        SizedBox(height: 8),
                        Text(
                          'Add Alarm',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'avenir'),
                        ),
                      ],
                    ),
                  ),
                ),
              ]).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _zonedScheduleAlarmClockNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      123,
      'scheduled alarm clock title',
      'scheduled alarm clock body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
          android: AndroidNotificationDetails(
              'alarm_clock_channel', 'Alarm Clock Channel',
              channelDescription: 'Alarm Clock Notification')),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime);
}

class AddAlarmDialog extends StatefulWidget {
  final Function(AlarmInfo) onAddAlarm;

  AddAlarmDialog({required this.onAddAlarm});

  @override
  _AddAlarmDialogState createState() => _AddAlarmDialogState();
}

class _AddAlarmDialogState extends State<AddAlarmDialog> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? _selectedTime;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Alarm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Alarm Title Input
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Alarm Title'),
          ),
          SizedBox(height: 16),

          // Select Date Button
          TextButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            child: Text(
              selectedDate == null
                  ? 'Select Date'
                  : 'Date: ${DateFormat('yMMMd').format(selectedDate!)}',
            ),
          ),
          SizedBox(height: 16),

          // Select Time Button
          TextButton(
            onPressed: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  _selectedTime = pickedTime;
                });
              }
            },
            child: Text(
              _selectedTime == null
                  ? 'Select Time'
                  : 'Time: ${_selectedTime!.format(context)}',
            ),
          ),
        ],
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () => Navigator.pop(context), // Close dialog
          child: Text('Cancel'),
        ),

        // Add Alarm Button
        TextButton(
          onPressed: () async{
            if (_titleController.text.isNotEmpty &&
                selectedDate != null &&
                _selectedTime != null) {
              // Combine date and time into a DateTime object
              final alarmDateTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );

              // Generate a random gradient
              final random = Random();
              final randomGradient = ranGradientColors.colors[
              random.nextInt(ranGradientColors.colors.length)
              ];
              // Create and pass the new alarm
              widget.onAddAlarm(AlarmInfo(
                title: _titleController.text,
                alarmDateTime: alarmDateTime,
                gradientColors: randomGradient,
              ));


              NotificationHelper.scheduleAlarmNotification(
                UniqueKey().hashCode, // Unique ID for each alarm
                alarmDateTime,
                'Alarm: ${_titleController.text}', // Notification title
                'Your alarm is set for ${DateFormat('yMMMd hh:mm aa').format(alarmDateTime)}.', // Notification body
              );

              Navigator.pop(context); // Close dialog
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

