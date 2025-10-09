import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/router.dart';
import 'package:ios_club_app/system_services/download_service.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/settings_store.dart';

import 'bottom_navigation.dart';
import 'modern_sidebar.dart';
import 'net/git_service.dart';
import 'system_services/check_update_manager.dart';
import 'under_maintenance_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  final SettingsStore settingsStore = SettingsStore.to;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb && Platform.isAndroid) {
      CheckUpdateManager.checkForUpdates().then((result) async {
        if (result.$1) {
          showUpdateDialog(result.$2);
        }
      });
    }

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _currentIndex = prefs.getInt(PrefsKeys.PAGE_DATA) ?? 0;
        Get.toNamed(_routeMap[_currentIndex] ?? '/');
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarIconBrightness: brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light),
    );
  }

  void showUpdateDialog(ReleaseModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('有新版本了！'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.name),
              const SizedBox(height: 16),
              Text(model.body),
              const SizedBox(height: 16),
            ],
          ),
        ),
        actions: [
          Wrap(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('忽略本次更新'),
              ),
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool(PrefsKeys.UPDATE_IGNORED, true);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('忽略所有更新'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  UpdateManager.showUpdateWithProgress(context, model.name);
                },
                child: const Text('现在就更新'),
              ),
            ],
          )
        ],
      ),
    );
  }

  final List<SidebarDestination> _destinations = const [
    SidebarDestination(
      icon: (CupertinoIcons.house),
      selectedIcon: (CupertinoIcons.house_fill),
      label: '首页',
    ),
    SidebarDestination(
      icon: (Icons.schedule_outlined),
      selectedIcon: (Icons.schedule),
      label: '课表',
    ),
    SidebarDestination(
      icon: (CupertinoIcons.creditcard),
      selectedIcon: (CupertinoIcons.creditcard_fill),
      label: '成绩',
    ),
    SidebarDestination(
      icon: (CupertinoIcons.person_alt_circle),
      selectedIcon: (CupertinoIcons.person_crop_circle_fill),
      label: '我的',
    ),
    SidebarDestination(
      icon: (CupertinoIcons.bolt),
      selectedIcon: (CupertinoIcons.bolt_fill),
      label: '电费',
    ),
    SidebarDestination(
      icon: (Icons.directions_bus_outlined),
      selectedIcon: (Icons.directions_bus_rounded),
      label: '校车',
    ),
    SidebarDestination(
      icon: (CupertinoIcons.money_dollar),
      selectedIcon: (CupertinoIcons.money_dollar_circle_fill),
      label: '饭卡',
    ),
  ];

  static const Map<int, String> _routeMap = {
    0: '/',
    1: '/Schedule',
    2: '/Score',
    3: '/Profile',
    4: '/Electricity',
    5: '/SchoolBus',
    6: '/Payment',
  };

  GetMaterialApp _app(bool isTablet) => GetMaterialApp(
      title: 'iOS Club App',
      debugShowCheckedModeBanner: false,
      defaultTransition: (kIsWeb)
          ? Transition.fadeIn
          : isTablet
              ? Transition.fadeIn
              : Transition.native,
      theme: ThemeData(
        fontFamily: SettingsStore.to.fontFamily.isEmpty
            ? (!kIsWeb && Platform.isWindows ? '微软雅黑' : null)
            : SettingsStore.to.fontFamily,
      ),
      darkTheme: ThemeData(
        fontFamily: SettingsStore.to.fontFamily.isEmpty
            ? (!kIsWeb && Platform.isWindows ? '微软雅黑' : null)
            : SettingsStore.to.fontFamily,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      getPages: AppRouter.getPages,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => UnderMaintenanceScreen(),
        );
      });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return isTablet
        ? Scaffold(
            body: SafeArea(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesktopSidebar(
                  items: _destinations,
                  selectedIndex: _currentIndex,
                  onItemSelected: (int index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    Get.toNamed(_routeMap[index] ?? '/');
                  },
                ),
                Expanded(
                  child: _app(isTablet),
                ),
              ],
            )),
          )
        : Scaffold(
            body: SafeArea(child: _app(isTablet)),
            bottomNavigationBar: BottomNavigation(
              destinations: _destinations.sublist(0, 4).map((destination) {
                return NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                );
              }).toList(),
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
                Get.toNamed(_routeMap[index] ?? '/');
              },
              backgroundColor: Theme.of(context)
                  .scaffoldBackgroundColor
                  .withValues(alpha: 0.95),
            ) // 不显示底部导航,
            );
  }
}
