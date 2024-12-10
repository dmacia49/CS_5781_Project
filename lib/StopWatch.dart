import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors/css.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage>
    with WidgetsBindingObserver {
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  bool _isRunning = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    _restoreStopwatchState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveStopwatchState();
    } else if (state == AppLifecycleState.resumed) {
      _restoreStopwatchState();
    }
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        Navigator.pushNamed(
            context, '/stopwatch'); // Ensure you use the correct route
      },
    );
  }

  void _showStopwatchNotification(String elapsedTime) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'stopwatch_channel',
      'Stopwatch Notifications',
      channelDescription: 'Displays the current stopwatch time',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Stopwatch Running',
      'Elapsed Time: $elapsedTime',
      platformChannelSpecifics,
    );
  }

  void _cancelStopwatchNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
      // Calculate the new start time based on the already elapsed time
      _startTime = DateTime.now().subtract(_elapsedTime);
    });
    _saveStopwatchState(); // Save the state persistently
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_startTime!);
      });

      // Update notification with the elapsed time
      _showStopwatchNotification(_formatElapsedTime());
    });
  }

  void _pauseStopwatch() {
    setState(() {
      _isRunning = false;
      _elapsedTime += DateTime.now().difference(_startTime!);
      _startTime = null;
    });
    _timer?.cancel();
    _cancelStopwatchNotification();
    _saveStopwatchState();
  }

  void _resetStopwatch() {
    setState(() {
      _elapsedTime = Duration.zero;
      _isRunning = false;
      _startTime = null;
    });
    _timer?.cancel();
    _cancelStopwatchNotification();
    _clearStopwatchState();
  }

  Future<void> _saveStopwatchState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('stopwatch_isRunning', _isRunning);
    prefs.setInt('stopwatch_elapsedTime', _elapsedTime.inMilliseconds);
    if (_isRunning && _startTime != null) {
      prefs.setString('stopwatch_startTime', _startTime!.toIso8601String());
    }
  }

  Future<void> _restoreStopwatchState() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool('stopwatch_isRunning') ?? false;
    final elapsedMilliseconds = prefs.getInt('stopwatch_elapsedTime') ?? 0;
    final startTimeString = prefs.getString('stopwatch_startTime');

    setState(() {
      _elapsedTime = Duration(milliseconds: elapsedMilliseconds);
      _isRunning = isRunning;
    });

    if (_isRunning && startTimeString != null) {
      final savedStartTime = DateTime.parse(startTimeString);
      final now = DateTime.now();
      setState(() {
        _elapsedTime += now.difference(savedStartTime);
        _startTime = now;
      });
      _startStopwatch();
    }
  }

  Future<void> _clearStopwatchState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stopwatch_isRunning');
    await prefs.remove('stopwatch_elapsedTime');
    await prefs.remove('stopwatch_startTime');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Stopwatch',
              style: TextStyle(
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ranGradientColors.colors[
                      Random().nextInt(ranGradientColors.colors.length)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatElapsedTime(),
                    style: TextStyle(
                      fontFamily: 'avenir',
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elapsed Time',
                    style: TextStyle(
                      fontFamily: 'avenir',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseStopwatch : _startStopwatch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    backgroundColor:
                        _isRunning ? Colors.redAccent : Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isRunning ? 'Pause' : 'Start',
                    style: TextStyle(
                      fontFamily: 'avenir',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _resetStopwatch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'avenir',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatElapsedTime() {
    final minutes = _elapsedTime.inMinutes;
    final seconds = _elapsedTime.inSeconds % 60;
    final milliseconds = (_elapsedTime.inMilliseconds % 1000) ~/ 100;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}:'
        '${milliseconds.toString().padLeft(1, '0')}';
  }
}
