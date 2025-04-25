import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'Services/RemindService.dart';
import 'SplashScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  runApp(MaterialApp(
    title: 'iOS Club App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          foregroundColor: Colors.black,
          elevation: 0,
        )),
    darkTheme: ThemeData(
      fontFamily: Platform.isWindows ? '微软雅黑' : null,
      brightness: Brightness.dark,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
    home: const SplashScreen(),
  ));
}
