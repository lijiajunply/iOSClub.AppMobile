import 'dart:async';

import 'package:display_mode/display_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/system_services/background_service.dart';
import 'package:ios_club_app/stores/init.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'main_app.dart';
import 'package:ios_club_app/stores/settings_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Stores
  initStores();

  requestPermissions();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // 初始化 window_manager
    await windowManager.ensureInitialized();

    // 配置窗口选项
    WindowOptions windowOptions = const WindowOptions(
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else if (kIsWeb ||
      !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // 只在非Web平台调用FlutterDisplayMode
    if (!kIsWeb) {
      await FlutterDisplayMode.setHighRefreshRate();
      await BackgroundService.initializeService();
      await BackgroundService.startService();
    }
  }

  initApp();
}

String? _getFontFamily() {
  // 检查是否为桌面平台
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // 获取设置存储实例
    final settingsStore = SettingsStore.to;
    // 如果设置了自定义字体，则使用自定义字体，否则使用系统默认字体
    return settingsStore.fontFamily.isEmpty ? null : settingsStore.fontFamily;
  }
  // 非桌面平台保持原有逻辑
  return !kIsWeb && Platform.isWindows ? '微软雅黑' : null;
}

void initApp() {
  runApp(MaterialApp(
    title: 'iOS Club App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: _getFontFamily(),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    ),
    darkTheme: ThemeData(
      fontFamily: _getFontFamily(),
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
    home: !kIsWeb && Platform.isWindows ? const WindowPage() : const MainApp(),
  ));
}

void requestPermissions() async {
  List<Permission> permissions = [
    Permission.notification,
  ];

  // 只在非Web平台请求权限
  if (!kIsWeb) {
    permissions.addAll([
      Permission.backgroundRefresh,
      Permission.storage,
      Permission.requestInstallPackages,
    ]);
  }

  await permissions.request();
}

class WindowPage extends StatefulWidget {
  const WindowPage({super.key});

  @override
  State<WindowPage> createState() => _WindowPageState();
}

class _WindowPageState extends State<WindowPage>
    with WindowListener, TrayListener {
  bool _isPreventClose = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    _init();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
    await windowManager.setPreventClose(true);

    await trayManager.setIcon(
      !kIsWeb && Platform.isWindows ? 'assets/icon.ico' : 'assets/icon.webp',
    );
  }

  // 优化的退出方法
  Future<void> _exitApp() async {
    _isPreventClose = false;
    await windowManager.setPreventClose(false);
    exit(0);
  }

  @override
  Widget build(BuildContext context) => const MainApp();

  @override
  void onWindowClose() async {
    if (_isPreventClose && mounted) {
      // 显示退出选项
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('关闭窗口'),
            content: const Text('选择您要执行的操作'),
            actions: [
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('最小化到任务栏'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.hide();
                },
              ),
              TextButton(
                child: const Text('退出程序'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _exitApp();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }
}
