import 'package:flutter/material.dart';

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> gradientColors;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.gradientColors = const [
      Color(0xFFF9BF65),
      Color(0xFFFFAB6B),
      Color(0xFFFC8986),
      Color(0xFFEF7E95),
      Color(0xFFBF83C1),
      Color(0xFFAB8DCF),
      Color(0xFF7FA0DC),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          transform: const GradientRotation(-64 * 3.14159 / 180), // 转换角度为弧度
          colors: gradientColors,
        ).createShader(bounds);
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // 使用白色作为基础颜色
      ),
    );
  }
}