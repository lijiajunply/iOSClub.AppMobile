import 'package:flutter/material.dart';

class ClubCard extends StatelessWidget {
  const ClubCard({super.key, this.child, this.margin, this.padding});

  final Widget? child;
  final EdgeInsets? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? theme.hoverColor : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}