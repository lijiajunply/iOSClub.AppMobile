import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// 一个跨平台的对话框组件
/// 在 iOS 和 macOS 上使用 Cupertino 风格，在其他平台上使用 Material 风格
class PlatformDialog {
  /// 显示一个确认对话框
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) async {
    if (kIsWeb) {
      // Web 端使用 Material 风格
      return _showMaterialConfirmDialog(
        context,
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      );
    } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      // iOS 和 macOS 使用 Cupertino 风格
      return _showCupertinoConfirmDialog(
        context,
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      );
    } else {
      // 其他平台使用 Material 风格
      return _showMaterialConfirmDialog(
        context,
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      );
    }
  }

  /// 显示一个带输入框的对话框
  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? hintText,
    String? confirmText,
    String? cancelText,
  }) async {
    if (kIsWeb) {
      // Web 端使用 Material 风格
      return _showMaterialInputDialog(
        context,
        title: title,
        content: content,
        hintText: hintText,
        confirmText: confirmText,
        cancelText: cancelText,
      );
    } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      // iOS 和 macOS 使用 Cupertino 风格
      return _showCupertinoInputDialog(
        context,
        title: title,
        content: content,
        hintText: hintText,
        confirmText: confirmText,
        cancelText: cancelText,
      );
    } else {
      // 其他平台使用 Material 风格
      return _showMaterialInputDialog(
        context,
        title: title,
        content: content,
        hintText: hintText,
        confirmText: confirmText,
        cancelText: cancelText,
      );
    }
  }

  /// 显示 Material 风格的确认对话框
  static Future<bool?> _showMaterialConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText ?? '取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(confirmText ?? '确认'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  /// 显示 Cupertino 风格的确认对话框
  static Future<bool?> _showCupertinoConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) async {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(cancelText ?? '取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              child: Text(confirmText ?? '确认'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  /// 显示 Material 风格的输入对话框
  static Future<String?> _showMaterialInputDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? hintText,
    String? confirmText,
    String? cancelText,
  }) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (content != null) Text(content),
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: hintText),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText ?? '取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(confirmText ?? '确认'),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        );
      },
    );
  }

  /// 显示 Cupertino 风格的输入对话框
  static Future<String?> _showCupertinoInputDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? hintText,
    String? confirmText,
    String? cancelText,
  }) async {
    final TextEditingController controller = TextEditingController();
    return showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (content != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(content),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CupertinoTextField(
                  controller: controller,
                  placeholder: hintText,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(cancelText ?? '取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: Text(confirmText ?? '确认'),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        );
      },
    );
  }
}