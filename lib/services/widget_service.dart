import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../PageModels/ScheduleItem.dart';
import 'data_service.dart';

class WidgetService {
  static const String appWidgetProviderClass = 'TodayCoursesWidgetProvider';

  // 更新小组件数据
  static Future<void> updateTodayCourses(
      List<ScheduleItem> todayCourses) async {
    final now = DateTime.now();

    final week = await DataService.getWeek();
    const a = ['日', '一', '二', '三', '四', '五', '六', '日'];
    final weekNow = week['week']!;

    // 更新小组件
    await HomeWidget.saveWidgetData<String>('flutter.title', '今日课表');
    await HomeWidget.saveWidgetData<String>('flutter.date',
        '第$weekNow周 周${a[now.weekday]} ${now.hour}时 ${DateFormat('mm').format(now)}分');
    await HomeWidget.saveWidgetData<String>(
        'flutter.courses', jsonEncode(todayCourses));

    // 刷新小组件
    await HomeWidget.updateWidget(
      name: appWidgetProviderClass,
      androidName: 'TodayCoursesWidgetProvider',
      qualifiedAndroidName:
          'com.example.ios_club_app.TodayCoursesWidgetProvider',
    );
  }
}
