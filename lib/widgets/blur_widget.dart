import 'package:flutter/material.dart';

/// 模糊组件
class BlurWidget extends StatelessWidget {
  const BlurWidget({
    super.key,
    this.child,
    this.sigmaX = 20,
    this.sigmaY = 20,
    this.radius = BorderRadius.zero,
  });

  final double sigmaX;

  final double sigmaY;

  final Widget? child;

  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect();
    // if (Platform.isWindows) return ClipRRect();
    // ThemeData theme = Theme.of(context);
    // return ClipRRect(
    //   borderRadius: radius,
    //   child: BackdropFilter.grouped(
    //     filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
    //     child: DecoratedBox(
    //       decoration: BoxDecoration(color: theme.cardColor),
    //       child: child,
    //     ),
    //   ),
    // );
  }
}
