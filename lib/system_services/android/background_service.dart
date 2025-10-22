import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ios_club_app/services/time_service.dart';
import 'package:ios_club_app/system_services/android/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'package:ios_club_app/models/course_model.dart';
import 'package:ios_club_app/pageModels/schedule_item.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:ios_club_app/system_services/notification_service.dart';

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
      TaskExecutor.updateTodayWidget,
      wakeup: false, // 小组件更新不需要唤醒设备
      exact: true,
      rescheduleOnReboot: true,
    );

    // 立即执行一次任务以测试功能
    Future.delayed(const Duration(seconds: 1), () {
      backgroundTask();
      TaskExecutor.updateTodayWidget();
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
      TaskExecutor.updateTodayWidget,
    );
  }
}

/// 任务执行器 - 实际的业务逻辑
@pragma('vm:entry-point')
class TaskExecutor {
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
          await prefs.setString(
              PrefsKeys.LAST_REMIND_DATE, now.toIso8601String());
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
  @pragma('vm:entry-point')
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
        final isCaoTang = course.campus == "草堂校区" ||
            (course.room.length >= 2 && course.room.startsWith("草堂"));

        if (isCaoTang) {
          // 草堂校区时间
          startTime = TimeService.CanTangTime[course.startUnit];
          endTime = TimeService.CanTangTime[course.endUnit];
        } else {
          // 雁塔校区时间（根据季节）
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
          teacher: course.teachers.join(','),
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
