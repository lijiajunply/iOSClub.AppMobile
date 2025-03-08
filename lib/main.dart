import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Pages/HomePage.dart';
import 'Pages/SchedulePage.dart';
import 'dart:io';

import 'Pages/ScorePage.dart';
import 'Pages/SettingPage.dart';
import 'Services/EduService.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dataService = EduService();
  // 获取并存储数据
  await dataService.getAllData();

  runApp(MaterialApp(
      title: 'iOS Club App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
      ),
      home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化逻辑转移到 WebView 属性中
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.storage,
    ].request();
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
      icon: Icon(Icons.score_outlined),
      selectedIcon: Icon(Icons.score),
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
    3: '/Setting',
  };

  final MaterialApp _app = MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/Schedule': (context) => const SchedulePage(),
        '/Score': (context) => const ScorePage(),
        '/Setting': (context) => const SettingPage(),
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

    return SafeArea(
      child: isTablet
          ? Scaffold(
              body: Row(
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
                      navigatorKey.currentState
                          ?.pushNamed(_routeMap[index] ?? '/');
                    },
                    selectedIndex: _currentIndex,
                  ),
                  // 垂直分割线
                  const VerticalDivider(thickness: 1, width: 1),
                  // 主要内容区域
                  Expanded(child: _app),
                ],
              ),
            )
          : Scaffold(
              body: _app,
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
            ),
    );
  }
}
