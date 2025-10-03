import 'package:flutter/material.dart';

import '../PageModels/course_color_manager.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.icon});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final color = CourseColorManager.generateSoftColor(title + subtitle);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
