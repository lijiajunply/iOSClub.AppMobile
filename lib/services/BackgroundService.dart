import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:ios_club_app/Services/time_service.dart';
import 'package:ios_club_app/services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/CourseModel.dart';
import '../PageModels/ScheduleItem.dart';
import 'data_service.dart';
import 'notification_service.dart';

class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: false,
        autoStartOnBoot: true,
      ),
    );
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (!isRunning) {
      service.startService();
    }
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stop");
  }
}

// iOS 后台处理
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// 主要的后台服务入口点
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // 服务停止标志
  bool shouldStop = false;

  // Android 前台服务配置
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stop').listen((event) {
    shouldStop = true;
    service.stopSelf();
  });

  // 定时器用于课程提醒（8小时间隔）
  Timer.periodic(const Duration(hours: 8), (timer) async {
    if (shouldStop) {
      timer.cancel();
      return;
    }
    await _performCourseReminder();
  });

  // 定时器用于更新今日课程（15分钟间隔）
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    if (shouldStop) {
      timer.cancel();
      return;
    }
    await _updateTodayCourse();
  });

  // 立即执行一次
  await _performCourseReminder();
  await _updateTodayCourse();
}

// 课程提醒逻辑
Future<void> _performCourseReminder() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var nowTime = DateTime.now();

    final lastRemind = prefs.getInt('last_remind_time');
    final isRemind = prefs.getBool('is_remind') ?? false;

    if (isRemind &&
        ((lastRemind == null || lastRemind == 0) || nowTime.day != lastRemind)) {
      try {
        final result = await DataService.getCourse();
        await NotificationService.toList(result.$2);
        debugPrint('提醒课程成功');
        await prefs.setInt('last_remind_time', nowTime.day);
      } catch (e) {
        debugPrint('提醒课程失败: $e');
      }
    }
  } catch (e) {
    debugPrint('课程提醒执行失败: $e');
  }
}

// 更新今日课程逻辑
Future<void> _updateTodayCourse() async {
  try {
    final (isShowingTomorrow, courses) = await DataService.getCourse(
        isTomorrow: false);
    final scheduleItems = changeScheduleItems(courses);
    await WidgetService.updateTodayCourses(scheduleItems);
    debugPrint('更新今日课程成功');
  } catch (e) {
    debugPrint('更新今日课程失败: $e');
  }
}

List<ScheduleItem> changeScheduleItems(List<CourseModel> a) {
  List<ScheduleItem> scheduleItems = [];
  scheduleItems.addAll(a.map((course) {
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
  }));

  return scheduleItems;
}