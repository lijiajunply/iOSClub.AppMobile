import 'package:flutter/material.dart';

class DashedSeparator extends StatelessWidget {
  final Axis axis;
  final double length;
  final double thickness;
  final Color color;
  final List<double> dashPattern;

  const DashedSeparator({
    super.key,
    this.axis = Axis.horizontal,
    this.length = double.infinity,
    this.thickness = 1.0,
    this.color = Colors.grey,
    this.dashPattern = const [5.0, 3.0], // [dash, gap]
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: axis == Axis.horizontal
          ? Size(length, thickness)
          : Size(thickness, length),
      painter: DashedLinePainter(
        axis: axis,
        thickness: thickness,
        color: color,
        dashPattern: dashPattern,
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Axis axis;
  final double thickness;
  final Color color;
  final List<double> dashPattern;

  DashedLinePainter({
    required this.axis,
    required this.thickness,
    required this.color,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final path = Path();
    final dashLength = dashPattern.reduce((a, b) => a + b);
    final numDashes = (axis == Axis.horizontal
            ? size.width
            : size.height) /
        dashLength;

    for (int i = 0; i < numDashes.floor(); i++) {
      double position = i * dashLength;
      for (int j = 0; j < dashPattern.length; j += 2) {
        double dash = dashPattern[j];
        double gap = j + 1 < dashPattern.length ? dashPattern[j + 1] : 0;

        if (axis == Axis.horizontal) {
          path.moveTo(position, size.height / 2);
          path.lineTo(position + dash, size.height / 2);
          position += dash + gap;
        } else {
          path.moveTo(size.width / 2, position);
          path.lineTo(size.width / 2, position + dash);
          position += dash + gap;
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}