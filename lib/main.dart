import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:io';

import 'SplashScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HomeWidget.initiallyLaunchedFromHomeWidget();
  HomeWidget.setAppGroupId('com.example.ios_club_app');

  runApp(MaterialApp(
      title: 'iOS Club App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
      ),
      home: const SplashScreen()));
}
