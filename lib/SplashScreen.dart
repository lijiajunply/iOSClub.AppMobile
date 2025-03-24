import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'App.dart';

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
    _controller = AnimationController(
      duration: const Duration(seconds: (5)),
      vsync: this,
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

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyApp(),
              ));
        },
      ),
    ));
  }
}
