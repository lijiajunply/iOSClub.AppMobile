import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ios_club_app/system_services/task_executor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';

/// iOS后台任务回调函数
@pragma('vm:entry-point')
void backgroundTask() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 执行课程提醒检查
  await TaskExecutor.checkAndSendCourseReminder();
}

/// iOS后台服务管理类
class IOSBackgroundService {
  static Timer? _timer;
  static const int _updateInterval = 3600; // 1小时更新一次，单位秒

  /// 初始化后台服务
  static Future<void> initializeService() async {
    // iOS平台不需要特殊的初始化
    debugPrint('iOS Background Service 初始化完成');
  }

  /// 启动服务
  static Future<void> startService() async {
    // iOS平台使用不同的后台执行机制
    // 在iOS上，我们依赖系统提供的后台执行时间
    debugPrint('iOS Background Service 已启动');

    // 启动定时更新
    _startPeriodicUpdate();
  }

  /// 停止服务
  static Future<void> stopService() async {
    // iOS平台不需要特殊的停止操作
    debugPrint('iOS Background Service 已停止');

    // 停止定时更新
    _stopPeriodicUpdate();
  }

  /// 启动定时更新
  static void _startPeriodicUpdate() {
    _stopPeriodicUpdate(); // 先停止现有的定时器

    // 创建新的定时器，定期更新数据
    _timer = Timer.periodic(
      const Duration(seconds: _updateInterval),
      (timer) async {
        debugPrint('执行定时数据更新任务');
        await performPeriodicUpdate();
      },
    );

    debugPrint('定时数据更新已启动，间隔: $_updateInterval 秒');
  }

  /// 执行定期更新任务
  @pragma('vm:entry-point')
  static Future<void> performPeriodicUpdate() async {
    try {
      debugPrint('开始执行定期数据更新任务');

      // 更新今日课程小组件
      await TaskExecutor.updateWidget();

      // 可以在这里添加其他需要定期更新的任务
      // 例如：更新用户数据、检查通知等

      debugPrint('定期数据更新任务完成');
    } catch (e) {
      debugPrint('定期数据更新任务失败: $e');
    }
  }

  /// 停止定时更新
  static void _stopPeriodicUpdate() {
    _timer?.cancel();
    _timer = null;
    debugPrint('定时数据更新已停止');
  }

  /// 手动触发课程提醒检查
  static Future<void> checkCourseReminder() async {
    await TaskExecutor.checkAndSendCourseReminder();
  }

  /// 手动触发小组件更新
  static Future<void> updateWidget() async {
    await TaskExecutor.updateTodayWidget();
  }
}

/// 课程提醒服务的外部接口
class CourseReminderService {
  /// 手动执行课程提醒
  static Future<void> performCourseReminder() async {
    await IOSBackgroundService.checkCourseReminder();
  }

  /// 手动更新今日课程
  static Future<void> updateTodayCourse() async {
    await IOSBackgroundService.updateWidget();
  }

  /// 获取服务状态
  static Future<bool> isServiceRunning() async {
    // iOS上简单返回true表示服务可用
    return true;
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
      // 启用时启动服务
      await IOSBackgroundService.startService();
    } else {
      // 禁用时停止服务
      await IOSBackgroundService.stopService();
    }
  }

  /// 获取是否启用提醒
  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
  }

  /// 手动执行定期更新任务
  static Future<void> performPeriodicUpdate() async {
    await IOSBackgroundService.performPeriodicUpdate();
  }
}