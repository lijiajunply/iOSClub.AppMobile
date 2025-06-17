import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/pages/program_page.dart';
import 'package:ios_club_app/services/download_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Pages/about_page.dart';
import 'Pages/home_page.dart';
import 'Pages/link_page.dart';
import 'Pages/other_page.dart';
import 'Pages/profile_page.dart';
import 'Pages/schedule_list_page.dart';
import 'Pages/schedule_setting_page.dart';
import 'Pages/school_bus_page.dart';
import 'Pages/score_page.dart';
import 'Pages/todo_page.dart';
import 'Pages/member_page.dart';
import 'Services/git_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      GiteeService.getReleases().then((result) async {
        final packageInfo = await PackageInfo.fromPlatform();
        if (result.name != '0.0.0' && result.name != packageInfo.version) {
          showUpdateDialog(result);
        }
      });
    }

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _currentIndex = prefs.getInt('page_index') ?? 0;
        navigatorKey.currentState?.pushNamed(_routeMap[_currentIndex] ?? '/');
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
                  prefs.setBool('update_ignored', true);
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

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '首页',
    ),
    NavigationDestination(
      icon: Icon(Icons.schedule_outlined),
      selectedIcon: Icon(Icons.schedule),
      label: '课表',
    ),
    NavigationDestination(
      icon: Icon(Icons.credit_score_outlined),
      selectedIcon: Icon(Icons.credit_score),
      label: '成绩',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: '我的',
    ),
  ];

  static const Map<int, String> _routeMap = {
    0: '/',
    1: '/Schedule',
    2: '/Score',
    3: '/Profile',
  };

  final MaterialApp _app = MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            // 为不同平台配置不同的转场动画
            TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CustomPageTransitionBuilder(),
            TargetPlatform.fuchsia: const FadeUpwardsPageTransitionsBuilder(),
            // 其他平台也可以添加
          },
        ),
      ),
      darkTheme: ThemeData.dark(),
      routes: {
        '/': (context) => const HomePage(),
        '/Schedule': (context) => const ScheduleListPage(),
        '/Score': (context) => const ScorePage(),
        '/Profile': (context) => const ProfilePage(),
        '/Link': (context) => const LinkPage(),
        '/Todo': (context) => const TodoPage(),
        '/About': (context) => const AboutPage(),
        '/ScheduleSetting': (context) => const ScheduleSettingPage(),
        '/SchoolBus': (context) => const SchoolBusPage(),
        '/Other': (context) => const OtherPage(),
        '/iMember': (context) => const MemberPage(),
        '/Program': (context) => const ProgramPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('未找到页面: ${settings.name}'),
            ),
          ),
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
            children: [
              // 左侧导航
              NavigationRail(
                labelType: NavigationRailLabelType.all,
                destinations: _destinations.map((destination) {
                  return NavigationRailDestination(
                    icon: destination.icon,
                    selectedIcon: destination.selectedIcon,
                    label: Text(destination.label),
                  );
                }).toList(),
                onDestinationSelected: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  navigatorKey.currentState?.pushNamed(_routeMap[index] ?? '/');
                },
                selectedIndex: _currentIndex,
              ),
              // 垂直分割线
              const VerticalDivider(thickness: 1, width: 1),
              // 主要内容区域
              Expanded(child: _app),
            ],
          )))
        : Scaffold(
            body: SafeArea(child: _app),
            bottomNavigationBar: NavigationBar(
              destinations: _destinations,
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
                navigatorKey.currentState?.pushNamed(_routeMap[index] ?? '/');
              },
            ),
          );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 或者滑动效果
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
