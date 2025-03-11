import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ios_club_app/Models/CourseTime.dart';
import 'package:ios_club_app/Services/DataService.dart';

class ClassReminderService {
  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  Timer? _timer;

  // 存储课程时间
  late List<CourseTime> _classTimes = [];

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

    final data = DataService();
    _classTimes = await data.getAllTime();

    // 开始实时检测
    startMonitoring();
  }

  void startMonitoring() {
    // 每分钟检查一次
    _timer?.cancel(); // 确保不会重复启动
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkClassTimes();
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  void _checkClassTimes() {
    final now = DateTime.now();

    for (var classTime in _classTimes) {
      final difference = classTime.difference(now);

      // 如果距离上课还有15分钟（允许30秒误差）
      if (difference.inMinutes == 15 && difference.inSeconds % 60 < 30) {
        _showNotification(classTime);
        // 如果是单次课程，可以将其从列表中移除
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
      DateTime.now().millisecond, // 使用当前时间毫秒数作为唯一ID
      '课程提醒',
      '您的课程：${classTime.courseName}将在15分钟后开始',
      details,
    );
  }

  // 清理资源
  void dispose() {
    stopMonitoring();
    _classTimes.clear();
  }
}