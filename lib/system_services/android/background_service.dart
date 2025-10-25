import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:ios_club_app/system_services/task_executor.dart';

/// 后台任务回调函数
@pragma('vm:entry-point')
void backgroundTask() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 执行课程提醒检查
  await TaskExecutor.checkAndSendCourseReminder();
}

/// 后台服务管理类
class BackgroundService {
  static const int _reminderAlarmId = 1;
  static const int _widgetAlarmId = 2;

  /// 初始化后台服务
  static Future<void> initializeService() async {
    // 初始化 Android Alarm Manager
    await AndroidAlarmManager.initialize();

    debugPrint('Android Alarm Manager 初始化完成');
  }

  /// 启动服务
  static Future<void> startService() async {
    // 启动周期性任务
    await AndroidAlarmManager.periodic(
      const Duration(hours: 8),
      _reminderAlarmId,
      backgroundTask,
      wakeup: true,
      exact: true,
      rescheduleOnReboot: true,
    );

    await AndroidAlarmManager.periodic(
      const Duration(minutes: 5),
      _widgetAlarmId,
      TaskExecutor.updateWidget,
      wakeup: false, // 小组件更新不需要唤醒设备
      exact: true,
      rescheduleOnReboot: true,
    );

    // 立即执行一次任务以测试功能
    Future.delayed(const Duration(seconds: 1), () {
      backgroundTask();
      TaskExecutor.updateWidget();
    });

    debugPrint('周期性任务已注册');
  }

  /// 停止服务
  static Future<void> stopService() async {
    await AndroidAlarmManager.cancel(_reminderAlarmId);
    await AndroidAlarmManager.cancel(_widgetAlarmId);
    debugPrint('所有后台任务已取消');
  }

  /// 手动触发课程提醒检查
  static Future<void> checkCourseReminder() async {
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 1),
      _reminderAlarmId,
      TaskExecutor.checkAndSendCourseReminder,
    );
  }

  /// 手动触发小组件更新
  static Future<void> updateWidget() async {
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 1),
      _widgetAlarmId,
      TaskExecutor.updateWidget,
    );
  }
}

/// 课程提醒服务的外部接口
class CourseReminderService {
  /// 手动执行课程提醒
  static Future<void> performCourseReminder() async {
    await BackgroundService.checkCourseReminder();
  }

  /// 手动更新今日课程
  static Future<void> updateTodayCourse() async {
    await BackgroundService.updateWidget();
  }

  /// 获取服务状态
  static Future<bool> isServiceRunning() async {
    // AndroidAlarmManager 没有直接的 API 来检查任务是否运行
    // 这里简单返回 true 表示已配置
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
      await BackgroundService.startService();
    } else {
      // 禁用时停止服务
      await BackgroundService.stopService();
    }
  }

  /// 获取是否启用提醒
  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
  }
}
