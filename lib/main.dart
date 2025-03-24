import 'package:flutter/material.dart';
import 'dart:io';

import 'SplashScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
      title: 'iOS Club App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
      ),
      home: const SplashScreen()));
}

class ScreenUtil {
  static MediaQueryData mediaQuery = MediaQueryData.fromView(View.of(navigatorKey.currentContext!));

  // 屏幕宽度
  static double screenWidth = mediaQuery.size.width;
  // 屏幕高度
  static double screenHeight = mediaQuery.size.height;
  // 设备像素比
  static double pixelRatio = mediaQuery.devicePixelRatio;
  // 状态栏高度
  static double statusBarHeight = mediaQuery.padding.top;
}

extension SizeExtension on num {
  // 按照设计稿宽度比例计算
  double get w => this * ScreenUtil.screenWidth / 375.0;

  // 按照设计稿高度比例计算
  double get h => this * ScreenUtil.screenHeight / 812.0;

  // 根据设备像素比适配字体大小
  double get sp => this * ScreenUtil.pixelRatio;
}