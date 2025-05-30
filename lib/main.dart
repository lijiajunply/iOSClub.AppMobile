import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/services/background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'main_app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  requestPermissions();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await CourseReminderService.performCourseReminder();
  } else {
    await BackgroundService.initializeService();
    await BackgroundService.startService();
  }

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
    home: const MainApp(),
  ));
}

void requestPermissions() async {
  await [
    Permission.storage,
    Permission.notification,
    Permission.backgroundRefresh,
    Permission.requestInstallPackages,
  ].request();
}
