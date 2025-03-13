import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ios_club_app/Models/CourseTime.dart';
import 'package:ios_club_app/Services/DataService.dart';

class ClassReminderService extends WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  late List<CourseTime> _classTimes = [];
  static const BACKGROUND_FETCH_TASK = "com.example.class-reminder";

  Future<void> initialize() async {
    // 初始化通知
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // 加载课程数据
    final data = DataService();
    _classTimes = await data.getAllTime();

    // 配置后台任务
    await _configureBackgroundFetch();
  }

  Future<void> _configureBackgroundFetch() async {
    // 配置 BackgroundFetch
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        // 最小间隔15分钟
        stopOnTerminate: false,
        // 应用终止时继续运行
        enableHeadless: true,
        // 支持后台运行
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      _onBackgroundFetch, // 后台任务回调
      _onBackgroundFetchTimeout, // 超时回调
    );

    // 注册任务
    await BackgroundFetch.registerHeadlessTask(_backgroundFetchHeadlessTask);

    // 启动后台任务
    await BackgroundFetch.start();
  }

  // 后台任务实现
  void _onBackgroundFetch(String taskId) async {
    await _checkClassTimes();
    BackgroundFetch.finish(taskId);
  }

  // 超时处理
  void _onBackgroundFetchTimeout(String taskId) {
    BackgroundFetch.finish(taskId);
  }

  // 无界面后台任务入口点
  static void _backgroundFetchHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;

    if (isTimeout) {
      BackgroundFetch.finish(taskId);
      return;
    }

    final service = ClassReminderService();
    await service.initialize();
    await service._checkClassTimes();

    BackgroundFetch.finish(taskId);
  }

  Future<void> _checkClassTimes() async {
    final now = DateTime.now();

    for (var classTime in _classTimes) {
      final difference = classTime.difference(now);

      if (difference.inMinutes == 15 && difference.inSeconds % 60 < 30) {
        await _showNotification(classTime);
        _classTimes.remove(classTime);
        break;
      }
    }
  }

  Future<void> _showNotification(CourseTime classTime) async {
    const androidDetails = AndroidNotificationDetails(
      'class_reminder',
      '课程提醒',
      channelDescription: '课程开始前的提醒通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'default',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      '课程提醒',
      '您的课程：${classTime.courseName}将在15分钟后开始',
      details,
    );
  }

  void dispose() {
    BackgroundFetch.stop();
    _classTimes.clear();
  }
}
