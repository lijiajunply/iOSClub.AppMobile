import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'Services/data_service.dart';
import 'Services/notification_service.dart';
import 'main_app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  requestPermissions();
  start();

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

Future<void> start() async {
  final prefs = await SharedPreferences.getInstance();
  var nowTime = DateTime.now();

  final lastRemind = prefs.getInt('last_remind_time');
  final isRemind = prefs.getBool('is_remind') ?? false;
  if (isRemind &&
      ((lastRemind == null || lastRemind == 0) || nowTime.day != lastRemind)) {
    final result = await DataService.getCourse();
    await NotificationService.toList(result.$2);
    try {} catch (e) {
      debugPrint('提醒课程失败: $e');
    }
    debugPrint('提醒课程成功');
    await prefs.setInt('last_remind_time', nowTime.day);
  }
}
