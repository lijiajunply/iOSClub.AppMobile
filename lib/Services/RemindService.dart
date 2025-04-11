import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'DataService.dart';
import 'TimeService.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();

  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleCourseReminder({
    required int id,
    required String title,
    required String body,
    required DateTime courseTime,
  }) async {
    final reminderTime = courseTime.subtract(const Duration(minutes: 15));
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'course_reminders',
          'Course Reminders',
          channelDescription: 'Notifications for course reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  static Future<void> set(BuildContext context) async {
    if (!await Permission
        .scheduleExactAlarm
        .isGranted) {
      showDialog(
          context: context,
          builder:
              (context) {
            return AlertDialog(
                title: Text(
                    '请允许使用闹钟'),
                content: Text(
                    '您需要允许使用闹钟才能使用课程通知功能'),
                actions: [
                  TextButton(
                    onPressed:
                        () {
                      Navigator.of(context)
                          .pop();
                    },
                    child: Text(
                        '取消'),
                  ),
                  TextButton(
                    onPressed:
                        () async {
                      await openAppSettings();
                      Navigator.of(context)
                          .pop();
                      if (await Permission
                          .scheduleExactAlarm
                          .isGranted) {
                        await remind();
                      }
                    },
                    child: Text(
                        '去设置'),
                  )
                ]);
          });
    } else {
      await remind();
    }
  }

  static Future<void> remind() async {
    final prefs = await SharedPreferences.getInstance();
    final isRemind = prefs.getBool('is_remind') ?? false;
    if (isRemind) {
      final a = await DataService.getCourse();
      for (var course in a.$2) {
        var startTime = "";
        if (course.room.substring(0, 2) == "草堂") {
          startTime = TimeService.CanTangTime[course.startUnit];
        } else {
          final now = DateTime.now();
          if (now.month >= 5 && now.month <= 10) {
            startTime = TimeService.YanTaXia[course.startUnit];
          } else {
            startTime = TimeService.YanTaDong[course.startUnit];
          }
        }

        final spilt = startTime.split(':');

        if (spilt.length < 2) continue;

        final now = DateTime.now();
        await NotificationService.instance.scheduleCourseReminder(
            id: course.hashCode,
            title: '课程提醒',
            body: '${course.courseName} 将在15分钟后开始',
            courseTime: DateTime(now.year, now.month, now.day,
                int.parse(spilt[0]), int.parse(spilt[1])));
      }
    }
  }
}
