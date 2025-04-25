import 'package:flutter/material.dart';

class PageHeaderDelegate extends SliverPersistentHeaderDelegate {
  PageHeaderDelegate({
    required this.title,
    required this.minHeight,
    required this.maxHeight,
    this.icon,
    this.onPressed,
  });

  final String title;
  final double minHeight;
  final double maxHeight;
  late Icon? icon;
  late Function()? onPressed;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: icon == null ? Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ) : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(onPressed: onPressed, icon: icon!)
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant PageHeaderDelegate oldDelegate) {
    return title != oldDelegate.title ||
        minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight;
  }
}

class HeaderChildDelegate extends SliverPersistentHeaderDelegate {
  HeaderChildDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  final Widget child;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant HeaderChildDelegate oldDelegate) {
    return child != oldDelegate.child ||
        minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight;
  }
}
