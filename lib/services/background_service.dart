import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ios_club_app/services/time_service.dart';
import 'package:ios_club_app/services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';

import 'package:ios_club_app/models/course_model.dart';
import 'package:ios_club_app/pageModels/schedule_item.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:ios_club_app/services/notification_service.dart';

/// 后台服务管理类
class BackgroundService {
  static const String _channelId = 'course_reminder_service';
  static const String _channelName = '课程提醒服务';
  static const String _channelDescription = '用于课程提醒和小组件更新的后台服务';

  /// 初始化后台服务
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // 根据平台配置不同的服务
    if (Platform.isIOS) {
      await _configureIOSService(service);
    } else if (Platform.isAndroid) {
      await _configureAndroidService(service);
    }
  }

  /// 配置 iOS 服务
  static Future<void> _configureIOSService(
      FlutterBackgroundService service) async {
    await service.configure(
      iosConfiguration: IosConfiguration(
        // iOS 不建议 autoStart，让用户手动控制
        autoStart: false,
        onForeground: _onStartIOS,
        // iOS 后台任务应该快速完成
        onBackground: _onIOSBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStartAndroid,
        autoStart: false,
        isForegroundMode: false,
        autoStartOnBoot: false,
      ),
    );
  }

  /// 配置 Android 服务
  static Future<void> _configureAndroidService(
      FlutterBackgroundService service) async {
    // Android 通知通道配置
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStartIOS,
        onBackground: _onIOSBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStartAndroid,
        autoStart: true,
        isForegroundMode: true,
        autoStartOnBoot: true,
      ),
    );
  }

  /// 启动服务
  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();

    if (!isRunning) {
      await service.startService();
      debugPrint('后台服务已启动');
    } else {
      debugPrint('后台服务已在运行');
    }
  }

  /// 停止服务
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
    debugPrint('后台服务停止指令已发送');
  }

  /// 手动触发课程提醒检查
  static Future<void> checkCourseReminder() async {
    final service = FlutterBackgroundService();
    service.invoke("checkReminder");
  }

  /// 手动触发小组件更新
  static Future<void> updateWidget() async {
    final service = FlutterBackgroundService();
    service.invoke("updateWidget");
  }
}

/// iOS 后台处理入口
@pragma('vm:entry-point')
Future<bool> _onIOSBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // iOS 后台任务应该快速完成并返回
  try {
    // 执行快速的后台任务
    await TaskExecutor.performQuickTasks();
    return true;
  } catch (e) {
    debugPrint('iOS 后台任务执行失败: $e');
    return false;
  }
}

/// iOS 前台服务入口
@pragma('vm:entry-point')
void _onStartIOS(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  debugPrint('iOS 前台服务启动');

  // iOS 使用定时器而不是 while 循环
  Timer? reminderTimer;
  Timer? widgetTimer;

  // 立即执行一次
  await TaskExecutor.checkAndSendCourseReminder();
  await TaskExecutor.updateTodayWidget();

  // 设置定时器
  // 课程提醒：每小时检查一次（会在内部判断是否需要提醒）
  reminderTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
    await TaskExecutor.checkAndSendCourseReminder();
  });

  // 小组件更新：每30分钟更新一次
  widgetTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
    await TaskExecutor.updateTodayWidget();
  });

  // 监听服务控制事件
  service.on('stopService').listen((event) {
    debugPrint('iOS 服务收到停止指令');
    reminderTimer?.cancel();
    widgetTimer?.cancel();
    service.stopSelf();
  });

  service.on('checkReminder').listen((event) async {
    await TaskExecutor.checkAndSendCourseReminder();
  });

  service.on('updateWidget').listen((event) async {
    await TaskExecutor.updateTodayWidget();
  });
}

/// Android 服务入口
@pragma('vm:entry-point')
void _onStartAndroid(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  debugPrint('Android 后台服务启动');

  // Android 特有的前台服务设置
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    // 设置为前台服务
    service.setAsForegroundService();
  }

  // 使用标志控制循环
  bool shouldStop = false;

  // 监听停止事件
  service.on('stopService').listen((event) {
    debugPrint('Android 服务收到停止指令');
    shouldStop = true;
  });

  // 监听手动触发事件
  service.on('checkReminder').listen((event) async {
    await TaskExecutor.checkAndSendCourseReminder();
  });

  service.on('updateWidget').listen((event) async {
    await TaskExecutor.updateTodayWidget();
  });

  // 立即执行一次
  await TaskExecutor.checkAndSendCourseReminder();
  await TaskExecutor.updateTodayWidget();

  // 记录上次执行时间
  DateTime lastReminderCheck = DateTime.now();
  DateTime lastWidgetUpdate = DateTime.now();

  // Android 可以使用循环，但要优化
  while (!shouldStop) {
    try {
      final now = DateTime.now();

      // 每8小时检查一次课程提醒
      if (now.difference(lastReminderCheck).inHours >= 8) {
        await TaskExecutor.checkAndSendCourseReminder();
        lastReminderCheck = now;
      }

      // 每15分钟更新一次小组件
      if (now.difference(lastWidgetUpdate).inMinutes >= 15) {
        await TaskExecutor.updateTodayWidget();
        lastWidgetUpdate = now;
      }
    } catch (e) {
      debugPrint('Android 后台任务执行错误: $e');
    }

    // 等待1分钟再检查
    await Future.delayed(const Duration(minutes: 1));
  }

  // 循环结束，停止服务
  service.stopSelf();
  debugPrint('Android 后台服务已停止');
}

/// 任务执行器 - 实际的业务逻辑
class TaskExecutor {
  /// 执行快速任务（iOS后台用）
  static Future<void> performQuickTasks() async {
    // iOS 后台执行时间有限，只执行最重要的任务
    await checkAndSendCourseReminder();
  }

  /// 检查并发送课程提醒
  static Future<void> checkAndSendCourseReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 检查是否启用提醒
      final isReminderEnabled = prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
      if (!isReminderEnabled) {
        debugPrint('课程提醒未启用');
        return;
      }

      // 检查今天是否已经提醒过
      final now = DateTime.now();
      final lastRemindTimeStr = prefs.getString(PrefsKeys.LAST_REMIND_DATE);

      if (lastRemindTimeStr != null) {
        try {
          final lastRemindDate = DateTime.parse(lastRemindTimeStr);
          if (_isSameDay(now, lastRemindDate)) {
            debugPrint('今天已经提醒过了');
            return;
          }
        } catch (e) {
          debugPrint('解析上次提醒时间失败: $e');
        }
      }

      // 获取课程数据并发送提醒
      try {
        final result = await DataService.getCourse().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('获取课程数据超时');
          },
        );

        if (result.$2.isNotEmpty) {
          await NotificationService.toList(result.$2);

          // 记录提醒时间（使用ISO格式字符串）
          await prefs.setString(PrefsKeys.LAST_REMIND_DATE, now.toIso8601String());
          debugPrint('课程提醒发送成功: ${now.toIso8601String()}');
        } else {
          debugPrint('没有需要提醒的课程');
        }
      } catch (e) {
        debugPrint('获取课程或发送提醒失败: $e');
      }
    } catch (e) {
      debugPrint('课程提醒检查失败: $e');
    }
  }

  /// 更新今日课程小组件
  static Future<void> updateTodayWidget() async {
    try {
      final (isShowingTomorrow, courses) = await DataService.getCourse(
        isTomorrow: false,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('获取今日课程超时');
        },
      );

      if (courses.isNotEmpty) {
        final scheduleItems = _convertToScheduleItems(courses);
        await WidgetService.updateTodayCourses(scheduleItems);
        debugPrint('小组件更新成功: ${DateTime.now().toIso8601String()}');
      } else {
        // 没有课程也要更新小组件显示"今日无课"
        await WidgetService.updateTodayCourses([]);
        debugPrint('今日无课，小组件已更新');
      }
    } catch (e) {
      debugPrint('更新小组件失败: $e');
    }
  }

  /// 转换课程数据为小组件显示格式
  static List<ScheduleItem> _convertToScheduleItems(List<CourseModel> courses) {
    final List<ScheduleItem> items = [];

    for (final course in courses) {
      try {
        String startTime = "";
        String endTime = "";

        // 安全的字符串判断
        final isCaoTang =
            course.room.length >= 2 && course.room.startsWith("草堂");

        if (isCaoTang) {
          // 草堂校区时间
          startTime = TimeService.CanTangTime[course.startUnit];
          endTime = TimeService.CanTangTime[course.endUnit];
        } else {
          // 研塔校区时间（根据季节）
          final now = DateTime.now();
          final isSummer = now.month >= 5 && now.month <= 10;

          if (isSummer) {
            startTime = TimeService.YanTaXia[course.startUnit];
            endTime = TimeService.YanTaXia[course.endUnit];
          } else {
            startTime = TimeService.YanTaDong[course.startUnit];
            endTime = TimeService.YanTaDong[course.endUnit];
          }
        }

        items.add(ScheduleItem(
          title: course.courseName,
          time:
              '第${course.startUnit}节 ~ 第${course.endUnit}节 | $startTime~$endTime',
          location: course.room,
        ));
      } catch (e) {
        debugPrint('转换课程 ${course.courseName} 失败: $e');
        // 即使单个课程转换失败，也继续处理其他课程
        continue;
      }
    }

    return items;
  }

  /// 判断是否同一天
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// 课程提醒服务的外部接口
class CourseReminderService {
  /// 手动执行课程提醒
  static Future<void> performCourseReminder() async {
    await TaskExecutor.checkAndSendCourseReminder();
  }

  /// 手动更新今日课程
  static Future<void> updateTodayCourse() async {
    await TaskExecutor.updateTodayWidget();
  }

  /// 获取服务状态
  static Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  /// 获取上次提醒时间
  static Future<DateTime?> getLastReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimeStr = prefs.getString(PrefsKeys.LAST_REMIND_DATE);

    if (lastTimeStr != null) {
      try {
        return DateTime.parse(lastTimeStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// 设置是否启用提醒
  static Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.IS_REMIND, enabled);

    if (enabled) {
      // 启用时自动启动服务
      await BackgroundService.startService();
    }
  }

  /// 获取是否启用提醒
  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
  }
}
