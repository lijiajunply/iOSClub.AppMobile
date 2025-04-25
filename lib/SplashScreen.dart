import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import 'App.dart';
import 'Services/EduService.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    requestPermissions();

    _controller = AnimationController(
      duration: const Duration(seconds: (5)),
      vsync: this,
    );
  }

  void requestPermissions() async {
    await [
      Permission.storage,
      Permission.notification,
      Permission.backgroundRefresh,
      Permission.requestInstallPackages,
      Permission.accessNotificationPolicy,
    ].request();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarIconBrightness: brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Lottie.asset(
      'assets/lottie.json',
      controller: _controller,
      height: MediaQuery.of(context).size.height * 1,
      animate: true,
      onLoaded: (composition) async {
        _controller
          ..duration = composition.duration
          ..repeat();

        _loadDataAndNavigate();
      },
    )));
  }

  Future<void> _loadDataAndNavigate() async {
    // 加载数据，耗时操作
    await EduService.getAllData();

    if (!mounted) return;

    // 跳转主页
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainApp()),
    );
  }
}
