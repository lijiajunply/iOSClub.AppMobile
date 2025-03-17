import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:ios_club_app/Pages/TodoPage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/HomePage.dart';
import 'Pages/LinkPage.dart';
import 'Pages/ProfilePage.dart';
import 'Pages/ScheduleListPage.dart';
import 'dart:io';

import 'Pages/ScheduleSettingPage.dart';
import 'Pages/ScorePage.dart';
import 'Pages/AboutPage.dart';
import 'Services/DataService.dart';
import 'Services/EduService.dart';
import 'Services/GiteeService.dart';
import 'Services/TimeService.dart';
import 'Services/WidgetService.dart';
import 'Widgets/ScheduleCard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
      title: 'iOS Club App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
      ),
      home: const SplashScreen()));
}

Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'updatetimetable') {

    final value = await DataService.getCourse();

    List<ScheduleItem> courses = [];
    courses.clear();
    courses.addAll((value.map((course) {
      var startTime = "";
      var endTime = "";
      if (course.room.substring(0, 2) == "草堂") {
        startTime = TimeService.CanTangTime[course.startUnit];
        endTime = TimeService.CanTangTime[course.endUnit];
      } else {
        final now = DateTime.now();
        if (now.month >= 5 && now.month <= 10) {
          startTime = TimeService.YanTaXia[course.startUnit];
          endTime = TimeService.YanTaXia[course.endUnit];
        } else {
          startTime = TimeService.YanTaDong[course.startUnit];
          endTime = TimeService.YanTaDong[course.endUnit];
        }
      }
      return ScheduleItem(
        title: course.courseName,
        time:
            '第${course.startUnit}节 ~ 第${course.endUnit}节 | $startTime~$endTime',
        location: course.room,
      );
    })));

    await WidgetService.updateTodayCourses(courses);
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: (5)),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Lottie.asset(
        'assets/lottie.json',
        controller: _controller,
        height: MediaQuery.of(context).size.height * 1,
        animate: true,
        onLoaded: (composition) async {
          _controller
            ..duration = composition.duration
            ..repeat();

          // 获取并存储数据
          final dataFuture = EduService.getAllData();
          HomeWidget.setAppGroupId('com.example.ios_club_app');
          HomeWidget.registerInteractivityCallback(backgroundCallback);

          await Future.wait([
            dataFuture,
          ]);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyApp(),
              ));
        },
      ),
    ));
  }
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

    if (Platform.isAndroid) {
      GiteeService.getReleases().then((result) async {
        final packageInfo = await PackageInfo.fromPlatform();
        final needUpdate =
            result.name != '0.0.0' && result.name != packageInfo.version;
        if (needUpdate) {
          showUpdateDialog(result);
        }
      });
    }
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
                  Navigator.of(context).pop();
                },
                child: const Text('忽略所有更新'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('正在下载更新...可以继续使用')),
                  );
                  await GiteeService.updateApp(model.name);
                },
                child: const Text('现在就更新'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> requestPermissions() async {
    await [
      Permission.storage,
      Permission.notification,
      Permission.backgroundRefresh,
      Permission.requestInstallPackages,
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
        useMaterial3: true,
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            // 为不同平台配置不同的转场动画
            TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CustomPageTransitionBuilder(),
            TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CustomPageTransitionBuilder(),
            // 其他平台也可以添加
          },
        ),
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/Schedule': (context) => const ScheduleListPage(),
        '/Score': (context) => const ScorePage(),
        '/Profile': (context) => const ProfilePage(),
        '/Link': (context) => const LinkPage(),
        '/Todo': (context) => const TodoPage(),
        '/About': (context) => const AboutPage(),
        '/ScheduleSetting': (context) => const ScheduleSettingPage(),
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
    final theme = Theme.of(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: theme.scaffoldBackgroundColor, // 状态栏背景颜色
      statusBarIconBrightness: theme.brightness == Brightness.dark
          ? Brightness.light // 如果是深色主题，图标为亮色
          : Brightness.dark, // 如果是浅色主题，图标为暗色
    ));
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
