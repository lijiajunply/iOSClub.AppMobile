import 'package:flutter/material.dart';

class ClubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ClubAppBar({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
    this.centerTitle = true,
    this.titleWidget,
    this.bottom,
  });

  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ??
          Text(
            title ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
      actions: actions,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }
}
