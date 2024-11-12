import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'menu.dart';
import 'homepage.dart';
import 'enums.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WakeUp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:ChangeNotifierProvider<MenuInfo>(
      create: (context) => MenuInfo(MenuType.clock),
      child:HomePage(),
      ),
    );
  }
}
