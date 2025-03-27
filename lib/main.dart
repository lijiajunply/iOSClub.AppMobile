import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'SplashScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
      .copyWith(statusBarIconBrightness: Brightness.dark // 图标颜色
          ));

  runApp(MaterialApp(
    title: 'iOS Club App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: Platform.isWindows ? '微软雅黑' : null,
    ),
    home: const SplashScreen(),
  ));
}
