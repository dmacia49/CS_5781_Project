import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakeup/notification_service.dart';
import 'menu.dart';
import 'homepage.dart';
import 'enums.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'puzzle_page.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

final navigatorKey = GlobalKey<NavigatorState>();

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Los_Angeles'));
  // Set your timezone
  final NotificationService notificationService = NotificationService();
  await notificationService.init(); // Call init() on an instanc

//  handle in terminated state
  var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    // LocalNotifications.onClickNotification.stream.listen((event) {
    Future.delayed(Duration(seconds: 1), () {
      // print(event);
      navigatorKey.currentState!.pushNamed('/another',
          arguments: initialNotification?.notificationResponse?.payload);
    });
  }

  // var initializationSettingsAndroid =
  //     AndroidInitializationSettings('@mipmap/ic_launcher');
  // var initializationSettingsDarwin = DarwinInitializationSettings(
  //   requestAlertPermission: true,
  //   requestBadgePermission: true,
  //   requestSoundPermission: true,
  // );
  //
  // var initializationSettings = InitializationSettings(
  //   android: initializationSettingsAndroid,
  //   iOS: initializationSettingsDarwin,
  // );
  //
  //
  // await flutterLocalNotificationsPlugin.initialize(
  //   initializationSettings,
  //   onDidReceiveNotificationResponse: (NotificationResponse response) async {
  //     if (response.payload != null) {
  //       debugPrint('IN main Notification payload: ${response.payload}');
  //     }
  //   },
  // );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WakeUp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider<MenuInfo>(
        create: (context) => MenuInfo(MenuType.clock),
        child: HomePage(),
      ),
      routes: {
        '/another': (context) => PuzzlePage(
              notificationId: 0,
            ),
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WakeUp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider<MenuInfo>(
        create: (context) => MenuInfo(MenuType.clock),
        child: HomePage(),
      ),
    );
  }
}
