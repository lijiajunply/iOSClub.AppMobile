import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../Models/CourseModel.dart';
import 'data_service.dart';
import 'time_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();

  static NotificationService get instance => _instance;
  bool isInit = false;

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // 将时区注册为本地时区（后续调用 tz.local 就是本地时区）
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    final androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notifications.initialize(
      initSettings,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'ios_club_app_course_reminders',
          '课程通知',
          description: '进行每日课表的课程通知，提前15分钟进行通知',
          importance: Importance.max,
        ));

    isInit = true;
  }

  Future<void> scheduleCourseReminder(
      {required int id,
      required String title,
      required String body,
      required DateTime courseTime}) async {
    final now = DateTime.now();
    final reminderTime = courseTime.subtract(Duration(minutes: 6));

    if (reminderTime.isBefore(now)) {
      debugPrint('Cannot schedule notification for past reminder time');
      return;
    }

    final tzDateTime = tz.TZDateTime.from(reminderTime, tz.local);

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final canScheduleExact = await android.canScheduleExactNotifications();
      if (canScheduleExact == null || !canScheduleExact) {
        debugPrint('Exact alarm scheduling not allowed');
        return;
      }
    }

    debugPrint('Scheduling notification at $tzDateTime with id=$id');

    try {
      await notifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ios_club_app_course_reminders',
            '课程通知',
            channelDescription: '进行每日课表的课程通知，提前15分钟进行通知',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'ios_club_app_course_reminders',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> set(BuildContext context) async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      await remind();
      return;
    }

    if (context.mounted) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('请允许使用闹钟'),
                content: Text('您需要允许使用闹钟才能使用课程通知功能'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('取消'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Permission.scheduleExactAlarm.request();
                      if (await Permission.scheduleExactAlarm.isGranted) {
                        await remind();
                      }
                    },
                    child: Text('去设置'),
                  )
                ]);
          });
    }
  }

  static Future<void> remind() async {
    if (!NotificationService.instance.isInit) {
      await NotificationService.instance.initialize();
    }

    final a = await DataService.getCourse();
    final now = DateTime.now();

    for (var course in a.$2) {
      var startTime = "";
      if (course.room.substring(0, 2) == "草堂") {
        startTime = TimeService.CanTangTime[course.startUnit];
      } else {
        if (now.month >= 5 && now.month <= 10) {
          startTime = TimeService.YanTaXia[course.startUnit];
        } else {
          startTime = TimeService.YanTaDong[course.startUnit];
        }
      }

      final spilt = startTime.split(':');

      if (spilt.length < 2) continue;

      await NotificationService.instance.scheduleCourseReminder(
          id: course.hashCode,
          title: '课程提醒',
          body: '${course.courseName} 将在15分钟后开始',
          courseTime: DateTime(now.year, now.month, now.day,
              int.parse(spilt[0]), int.parse(spilt[1])));
    }
  }

  static Future<void> toList(List<CourseModel> a) async {
    if (!NotificationService.instance.isInit) {
      await NotificationService.instance.initialize();
    }

    final now = DateTime.now();

    for (var course in a) {
      var startTime = "";
      if (course.room.substring(0, 2) == "草堂") {
        startTime = TimeService.CanTangTime[course.startUnit];
      } else {
        if (now.month >= 5 && now.month <= 10) {
          startTime = TimeService.YanTaXia[course.startUnit];
        } else {
          startTime = TimeService.YanTaDong[course.startUnit];
        }
      }

      final spilt = startTime.split(':');

      if (spilt.length < 2) continue;

      await NotificationService.instance.scheduleCourseReminder(
          id: course.hashCode,
          title: '课程提醒',
          body: '${course.courseName} 将在15分钟后开始',
          courseTime: DateTime(now.year, now.month, now.day,
              int.parse(spilt[0]), int.parse(spilt[1])));
    }
  }
}
