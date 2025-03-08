import 'package:flutter/material.dart';

class SwipeWidget extends StatefulWidget {
  final Widget child;
  final Function() onSwipeLeft;
  final Function() onSwipeRight;

  const SwipeWidget({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  State<SwipeWidget> createState() => _SwipeWidgetState();
}

class _SwipeWidgetState extends State<SwipeWidget> {
  double _dragStartX = 0.0;
  static const double _swipeThreshold = 50.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _dragStartX = details.globalPosition.dx;
      },
      onHorizontalDragEnd: (details) {
        final dragEndX = details.velocity.pixelsPerSecond.dx;
        final difference = dragEndX - _dragStartX;

        if (difference.abs() > _swipeThreshold) {
          if (difference > 0) {
            widget.onSwipeRight();
          } else {
            widget.onSwipeLeft();
          }
        }
      },
      child: widget.child,
    );
  }
}