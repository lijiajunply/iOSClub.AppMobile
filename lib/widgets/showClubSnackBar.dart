import 'package:flutter/material.dart';

void showClubSnackBar(BuildContext context, Widget child) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: child,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}