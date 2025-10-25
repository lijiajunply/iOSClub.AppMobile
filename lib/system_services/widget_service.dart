import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'package:ios_club_app/pageModels/schedule_item.dart';
import 'package:ios_club_app/services/data_service.dart';

class WidgetService {
  // 更新小组件数据
  @pragma('vm:entry-point')
  static Future<void> updateTodayCourses(
      List<ScheduleItem> todayCourses) async {
    final now = DateTime.now();

    final week = await DataService.getWeek();
    const a = ['日', '一', '二', '三', '四', '五', '六', '日'];
    final weekNow = week['week']!;

    // 更新小组件
    await HomeWidget.saveWidgetData<String>(
        'flutter.date', '第$weekNow周 周${a[now.weekday]}');
    await HomeWidget.saveWidgetData<String>(
        'flutter.courses', jsonEncode(todayCourses));

    debugPrint('小组件数据更新完成');

    // 刷新小组件
    await HomeWidget.updateWidget(
      name: 'TodayCoursesWidgetProvider',
      androidName: 'TodayCoursesWidgetProvider',
      iOSName: 'TodayCoursesWidget',
      qualifiedAndroidName:
          'com.example.ios_club_app.TodayCoursesWidgetProvider',
    );
  }

  @pragma('vm:entry-point')
  static Future<void> updateTodayAndTomorrowCourses(
      Map<String, List<ScheduleItem>> courses) async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    final week = await DataService.getWeek();
    const a = ['日', '一', '二', '三', '四', '五', '六', '日'];
    final weekNow = week['week']!;

    // 更新小组件
    await HomeWidget.saveWidgetData<String>(
        'flutter.tomorrow.date', '第$weekNow周 周${a[now.weekday]}');
    await HomeWidget.saveWidgetData<String>(
        'flutter.tomorrow.tomorrowDate', '${tomorrow.month}月${tomorrow.day}日');

    await HomeWidget.saveWidgetData<String>(
        'flutter.tomorrow.courses', jsonEncode(courses['today']));
    await HomeWidget.saveWidgetData<String>(
        'flutter.tomorrow.tomorrowCourses', jsonEncode(courses['tomorrow']));

    debugPrint('小组件数据更新完成');

    // 刷新小组件
    await HomeWidget.updateWidget(
      name: 'TomorrowCoursesWidgetProvider',
      androidName: 'TomorrowCoursesWidgetProvider',
      iOSName: 'TomorrowCoursesWidget',
      qualifiedAndroidName:
          'com.example.ios_club_app.TomorrowCoursesWidgetProvider',
    );
  }
}
