import 'package:flutter/material.dart';
import 'package:ios_club_app/ScreenUtil.dart';
import 'package:lottie/lottie.dart';

class EmptyWidget extends StatefulWidget {
  const EmptyWidget({super.key});

  @override
  State<EmptyWidget> createState() => _EmptyWidgetState();
}

class _EmptyWidgetState extends State<EmptyWidget>
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
    return Lottie.asset(
      'assets/Empty.json',
      controller: _controller,
      height: 120.h,
      animate: true,
      onLoaded: (composition) async {
        _controller
          ..duration = composition.duration
          ..forward();
      },
    );
  }
}
