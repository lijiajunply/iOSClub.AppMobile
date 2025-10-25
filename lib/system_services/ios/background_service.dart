import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ios_club_app/services/time_service.dart';
import 'package:ios_club_app/system_services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';

import 'package:ios_club_app/models/course_model.dart';
import 'package:ios_club_app/pageModels/schedule_item.dart';
import 'package:ios_club_app/services/data_service.dart';

import '../notification_service.dart';

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
        await TaskExecutor.performPeriodicUpdate();
      },
    );
    
    debugPrint('定时数据更新已启动，间隔: $_updateInterval 秒');
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
  
  /// 手动触发定时更新任务
  static Future<void> performPeriodicUpdate() async {
    await TaskExecutor.performPeriodicUpdate();
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
        final result = await DataService.getTodayOrTomorrowCourse().timeout(
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
      final (isShowingTomorrow, courses) = await DataService.getTodayOrTomorrowCourse(
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
  
  /// 执行定期更新任务
  @pragma('vm:entry-point')
  static Future<void> performPeriodicUpdate() async {
    try {
      debugPrint('开始执行定期数据更新任务');
      
      // 更新今日课程小组件
      await updateTodayWidget();
      
      // 可以在这里添加其他需要定期更新的任务
      // 例如：更新用户数据、检查通知等
      
      debugPrint('定期数据更新任务完成');
    } catch (e) {
      debugPrint('定期数据更新任务失败: $e');
    }
  }

  /// 转换课程数据为小组件显示格式
  static List<ScheduleItem> _convertToScheduleItems(List<CourseModel> courses) {
    final List<ScheduleItem> items = [];

    for (final course in courses) {
      try {
        final time = TimeService.getStartAndEnd(course);

        items.add(ScheduleItem(
          title: course.courseName,
          time: '第${course.startUnit}-${course.endUnit}节 ${time.start}-${time.start}',
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