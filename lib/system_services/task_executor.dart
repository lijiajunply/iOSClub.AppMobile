import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ios_club_app/models/course_model.dart';
import 'package:ios_club_app/pageModels/schedule_item.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:ios_club_app/services/time_service.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:ios_club_app/system_services/notification_service.dart';
import 'package:ios_club_app/system_services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @pragma('vm:entry-point')
  static Future<void> updateWidget() async {
    try {
      await updateTodayWidget();
      await updateTodayAndTomorrowWidget();
    } catch (e) {
      debugPrint('更新小组件失败: $e');
    }
  }

  /// 更新今日课程小组件
  @pragma('vm:entry-point')
  static Future<void> updateTodayWidget() async {
    try {
      final (isShowingTomorrow, courses) =
      await DataService.getTodayOrTomorrowCourse(
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

  /// 更新近日课程小组件
  @pragma('vm:entry-point')
  static Future<void> updateTodayAndTomorrowWidget() async {
    try {
      final courses = await DataService.getTodayAndTomorrowCourses().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('获取今日课程超时');
        },
      );

      if (courses.isNotEmpty) {
        Map<String, List<ScheduleItem>> scheduleItems = {};
        scheduleItems['today'] = _convertToScheduleItems(courses['today']!);
        scheduleItems['tomorrow'] =
            _convertToScheduleItems(courses['tomorrow']!);
        await WidgetService.updateTodayAndTomorrowCourses(scheduleItems);
        debugPrint('小组件更新成功: ${DateTime.now().toIso8601String()}');
      } else {
        // 没有课程也要更新小组件显示"今日无课"
        await WidgetService.updateTodayAndTomorrowCourses(
            {'today': [], 'tomorrow': []});
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
        final time = TimeService.getStartAndEnd(course);

        items.add(ScheduleItem(
          title: course.courseName,
          time:
          '第${course.startUnit}-${course.endUnit}节 ${time.start}-${time.end}',
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