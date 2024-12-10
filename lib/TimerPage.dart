import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors/css.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  List<TimerInfo> _timers = [];

  @override
  void initState() {
    super.initState();
    _initializeTimers();
    _initializeNotifications();
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.cancel(); // Cancel all timers when leaving the screen
    }
    super.dispose();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _initializeTimers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedTimers = prefs.getStringList('timers');
    if (savedTimers != null) {
      setState(() {
        _timers = savedTimers.map((timerData) {
          final data = jsonDecode(timerData);
          return TimerInfo.fromJson(data, _updateUI, _showNotification);
        }).toList();
      });
    }
  }

  void _saveTimers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedTimers =
        _timers.map((timer) => jsonEncode(timer.toJson())).toList();
    prefs.setStringList('timers', savedTimers);
  }

  void _startTimer(TimerInfo timerInfo) {
    timerInfo.start();
    _saveTimers();
    setState(() {});
  }

  void _pauseTimer(TimerInfo timerInfo) {
    timerInfo.pause();
    _saveTimers();
    setState(() {});
  }

  void _resumeTimer(TimerInfo timerInfo) {
    timerInfo.resume();
    _saveTimers();
    setState(() {});
  }

  void _deleteTimer(TimerInfo timerInfo) {
    timerInfo.cancel();
    setState(() {
      _timers.remove(timerInfo);
    });
    _saveTimers();
  }

  void _updateUI() {
    setState(() {}); // Update the UI when timer changes
    _saveTimers(); // Save the updated timer states
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('timer_channel', 'Timer Notifications',
            channelDescription: 'Notifications for completed timers',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        Random().nextInt(1000), title, body, platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Timers',
            style: TextStyle(
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
                fontSize: 24),
          ),
          Expanded(
            child: ListView(
              children: _timers.map((timerInfo) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: ranGradientColors.colors[
                          Random().nextInt(ranGradientColors.colors.length)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 4,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timerInfo.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'avenir',
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${timerInfo.remainingDuration.inMinutes}:${(timerInfo.remainingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'avenir',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: timerInfo.isRunning
                                ? () => _pauseTimer(timerInfo)
                                : () => _resumeTimer(timerInfo),
                            icon: Icon(
                              timerInfo.isRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteTimer(timerInfo),
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList()
                ..add(
                  Container(
                    decoration: BoxDecoration(
                      color: CustomColors.clockBG,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddTimerDialog(
                              onSetTimer: (TimerInfo newTimer) {
                                setState(() {
                                  _timers.add(newTimer);
                                });
                                _saveTimers();
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
                            'Add Timer',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'avenir'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerInfo {
  final String title;
  final Duration duration;
  Duration remainingDuration;
  Timer? _timer;
  bool isRunning = false;
  VoidCallback onUpdate; // Callback to notify UI of updates
  final Function(String, String) onComplete; // Notify when timer completes

  TimerInfo({
    required this.title,
    required this.duration,
    required this.onUpdate,
    required this.onComplete,
  }) : remainingDuration = duration;

  void start() {
    isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingDuration.inSeconds <= 1) {
        timer.cancel();
        isRunning = false;
        onComplete('Timer Completed', '$title has completed.');
      } else {
        remainingDuration -= Duration(seconds: 1);
        onUpdate();
      }
    });
  }

  void pause() {
    isRunning = false;
    _timer?.cancel();
  }

  void resume() {
    start();
  }

  void cancel() {
    _timer?.cancel();
    isRunning = false;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'duration': duration.inSeconds,
      'remainingDuration': remainingDuration.inSeconds,
      'isRunning': isRunning,
    };
  }

  static TimerInfo fromJson(Map<String, dynamic> json, VoidCallback onUpdate,
      Function(String, String) onComplete) {
    final timerInfo = TimerInfo(
      title: json['title'],
      duration: Duration(seconds: json['duration']),
      onUpdate: onUpdate,
      onComplete: onComplete,
    );
    timerInfo.remainingDuration =
        Duration(seconds: json['remainingDuration'] ?? json['duration']);
    if (json['isRunning']) {
      timerInfo.start();
    }
    return timerInfo;
  }
}

class AddTimerDialog extends StatelessWidget {
  final Function(TimerInfo) onSetTimer;

  AddTimerDialog({required this.onSetTimer});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    int minutes = 0;

    return AlertDialog(
      title: Text('Add Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Timer Title'),
          ),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Minutes'),
            onChanged: (value) {
              minutes = int.tryParse(value) ?? 0;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (titleController.text.isNotEmpty && minutes > 0) {
              final timer = TimerInfo(
                title: titleController.text,
                duration: Duration(minutes: minutes),
                onUpdate: () {},
                onComplete: (title, body) {},
              );
              onSetTimer(timer);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please provide valid details.')),
              );
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
