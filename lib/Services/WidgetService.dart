import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../PageModels/ScheduleItem.dart';

class WidgetService {
  static const String appWidgetProviderClass = 'TodayCoursesWidgetProvider';

  // 更新小组件数据
  static Future<void> updateTodayCourses(List<ScheduleItem> todayCourses) async {
    final now = DateTime.now();

    // 更新小组件
    await HomeWidget.saveWidgetData<String>('title', '今日课表');
    await HomeWidget.saveWidgetData<String>(
        'date', DateFormat('yyyy-MM-dd').format(now));
    await HomeWidget.saveWidgetData<String>(
        'courses', jsonEncode(todayCourses));

    // 刷新小组件
    await HomeWidget.updateWidget(
      name: appWidgetProviderClass,
      androidName: 'TodayCoursesWidgetProvider',
      qualifiedAndroidName: 'com.example.ios_club_app.TodayCoursesWidgetProvider',
    );
  }
}
