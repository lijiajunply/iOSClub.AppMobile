import 'package:flutter/material.dart';

class CourseColorManager {
  static Color generateSoftColor(key, {bool isDark = false}) {
    final hashCode = key.hashCode;
    final hue = (hashCode % 360).toDouble();
    const saturation = 0.4; // 低饱和度
    const lightness = 0.6; // 中等明度
    return HSLColor.fromAHSL(isDark ? 1 : 0.75, hue, saturation, lightness)
        .toColor();
  }
}
