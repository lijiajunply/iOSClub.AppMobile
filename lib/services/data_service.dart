import 'dart:convert';
import 'package:ios_club_app/net/edu_service.dart';
import 'package:ios_club_app/models/info_model.dart';
import 'package:ios_club_app/models/score_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:ios_club_app/models/course_model.dart';
import 'package:ios_club_app/pageModels/course_time.dart';
import 'package:ios_club_app/models/semester_model.dart';
import 'package:ios_club_app/services/time_service.dart';

class DataService {
  static Future<List<CourseModel>> getAllCourse(
      {bool isNeedIgnore = true}) async {
    List<String> ig = [];
    if (isNeedIgnore) {
      ig = await getIgnore();
    }
    
    final prefs = await SharedPreferences.getInstance();
    // 检查课程数据最后一次刷新时间，如果是一周前则刷新数据
    final courseLastFetchTime = prefs.getInt(PrefsKeys.COURSE_LAST_FETCH_TIME);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (courseLastFetchTime == null || now - courseLastFetchTime > 1000 * 60 * 60 * 24 * 7) {
      // 课程数据最后一次刷新时间是一周前，调用刷新接口
      await EduService.getCourse(isRefresh: true);
    }
    
    final String? jsonString = prefs.getString(PrefsKeys.COURSE_DATA);
    final List<CourseModel> list = [];
    if (jsonString != null) {
      var jsonList = jsonDecode(jsonString);
      jsonList = jsonList["data"];
      for (var json in jsonList) {
        var a = CourseModel.fromJson(json);
        if (ig.isNotEmpty && ig.any((x) => x == a.courseName)) continue;
        list.add(a);
      }
    }
    return list;
  }

  static Future<List<String>> getCourseName() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.COURSE_DATA);
    final List<String> list = [];
    if (jsonString != null) {
      var jsonList = jsonDecode(jsonString);
      jsonList = jsonList["data"];
      for (var json in jsonList) {
        final c = CourseModel.fromJson(json);
        if (list.any((x) => x == c.courseName)) continue;
        list.add(c.courseName);
      }
    }
    return list;
  }

  static Future<void> setIgnore(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefsKeys.IGNORE_DATA, jsonEncode({"data": list}));
  }

  static Future<List<String>> getIgnore() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.IGNORE_DATA);
    final List<String> list = [];
    if (jsonString != null) {
      var jsonList = jsonDecode(jsonString);
      jsonList = jsonList["data"];
      for (var json in jsonList) {
        list.add(json);
      }
    }
    return list;
  }

  static Future<Map<String, int>> getWeek() async {
    final time = await getTime();
    if (time["startTime"] == null) {
      return {'week': 0, 'maxWeek': 0};
    }

    final startTime = DateTime.parse(time["startTime"]!);
    final endTime = DateTime.parse(time["endTime"]!);
    final now = DateTime.now();

    // 获取某个日期所在周的周日（一周的第一天）
    DateTime getWeekStart(DateTime date) {
      // DateTime.weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
      // 我们需要调整为：0=Sunday, 1=Monday, ..., 6=Saturday
      int daysSinceWeekStart = date.weekday == 7 ? 0 : date.weekday;
      return DateTime(date.year, date.month, date.day)
          .subtract(Duration(days: daysSinceWeekStart));
    }

    // 计算开学时间所在周的周日
    final startWeekSunday = getWeekStart(startTime);

    // 计算当前时间所在周的周日
    final currentWeekSunday = getWeekStart(now);

    // 计算周数差 + 1（第一周为第1周）
    final weekDiff = currentWeekSunday.difference(startWeekSunday).inDays ~/ 7;
    final week = weekDiff + 1;

    // 计算最大周数
    final endWeekSunday = getWeekStart(endTime);
    final maxWeekDiff = endWeekSunday.difference(startWeekSunday).inDays ~/ 7;
    final maxWeek = maxWeekDiff + 1;

    return {'week': week, 'maxWeek': maxWeek};
  }

  static Future<List<CourseModel>> getCourseByWeek({int week = 0}) async {
    final allCourse = await getAllCourse();
    if (week == 0) {
      final time = await getTime();
      week = DateTime.now()
                  .difference(DateTime.parse(time["startTime"]!))
                  .inDays ~/
              7 +
          1;
    }
    return allCourse
        .where((course) => course.weekIndexes.contains(week))
        .toList();
  }

  static Future<(bool, List<CourseModel>)> getCourse(
      {bool isTomorrow = false}) async {
    final allCourse = await getAllCourse();
    final time = await getTime();
    var now = DateTime.now();
    if (time["startTime"] == null) {
      return (false, List<CourseModel>.unmodifiable([]));
    }
    var weekNow =
        now.difference(DateTime.parse(time["startTime"]!)).inDays ~/ 7 + 1;
    var filteredCourses = allCourse.where((course) {
      return course.weekIndexes.contains(weekNow) &&
          course.weekday == now.weekday;
    }).toList();

    if (filteredCourses.isEmpty) {
      if (isTomorrow) {
        filteredCourses = allCourse.where((course) {
          var weekDay = now.weekday + 1;
          if (weekDay == 7) {
            weekNow++;
          }
          if (weekDay > 7) {
            weekDay = 1;
          }
          return course.weekIndexes.contains(weekNow) &&
              course.weekday == weekDay;
        }).toList();
        if (filteredCourses.isEmpty) {
          return (true, filteredCourses);
        }
        filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

        return (true, filteredCourses);
      } else {
        return (false, filteredCourses);
      }
    }

    filteredCourses = filteredCourses.where((course) {
      final time = TimeService.getStartAndEnd(course);

      final l = time.end.split(':');
      var end = DateTime(
          now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);

      return now.isBefore(end);
    }).toList();

    filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    return (false, filteredCourses);
  }

  static Future<List<ScoreList>> getScore() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('all_score_data');
    final s = await getSemester();
    final List<ScoreList> list = [];
    if (jsonString != null) {
      final Map<String, dynamic> jsonList = jsonDecode(jsonString);
      jsonList.forEach((String key, value) {
        final scoreList = jsonDecode(value);
        list.add(ScoreList(
          semester: s.firstWhere((x) => x.semester == key),
          list: (scoreList as List).map((e) => ScoreModel.fromJson(e)).toList(),
        ));
      });
    }

    return list;
  }

  static Future<List<SemesterModel>> getSemester(
      {bool isRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (isRefresh) {
      await EduService.getSemester();
    } else {
      final semesterIntTime = prefs.getInt(PrefsKeys.SEMESTER_TIME);

      if (semesterIntTime != null) {
        final now = DateTime.now();
        if (now
                .difference(
                    DateTime.fromMicrosecondsSinceEpoch(semesterIntTime))
                .inHours <
            1) {
          await EduService.getSemester();
        }
      }
    }

    final String? jsonString = prefs.getString(PrefsKeys.SEMESTER_DATA);
    final List<SemesterModel> list = [];
    if (jsonString != null) {
      var jsonList = jsonDecode(jsonString);
      jsonList = jsonList["data"];
      jsonList.forEach((json) {
        list.add(SemesterModel.fromJson(json));
      });
    }

    return list;
  }

  static Future<Map<String, String>> getTime() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(PrefsKeys.TIME_DATA);
    final timeLastUpdated = prefs.getInt(PrefsKeys.TIME_LAST_UPDATED);
    final now = DateTime.now().millisecondsSinceEpoch;
    final Map<String, String> list = {};
    if (jsonString != null &&
        (timeLastUpdated != null &&
            (now - timeLastUpdated).abs() < 1000 * 60 * 60 * 24)) {
      var jsonList = jsonDecode(jsonString);
      jsonList.forEach((key, value) {
        list[key] = value.toString();
      });
    } else {
      await EduService.getTime();
      jsonString = prefs.getString(PrefsKeys.TIME_DATA);
      var jsonList = jsonDecode(jsonString ?? '{}');
      jsonList.forEach((key, value) {
        list[key] = value.toString();
      });
    }

    return list;
  }

  static Future<List<InfoModel>> getInfoList() async {
    List<InfoModel> list = [];
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.INFO_DATA);
    final time = prefs.getInt(PrefsKeys.INFO_DATA_TIME);

    final date = DateTime.now().millisecondsSinceEpoch;

    if (jsonString != null &&
        time != null &&
        (time - date).abs() < 1000 * 60 * 60 * 3) {
      // 3小时
      final jsonList = jsonDecode(jsonString);
      for (var i in jsonList) {
        list.add(InfoModel.fromJson(i));
      }
      return list;
    } else {
      // 从网络获取数据
      await EduService.getInfoCompletion();
      final String? jsonString = prefs.getString(PrefsKeys.INFO_DATA);

      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString);
        for (var i in jsonList) {
          list.add(InfoModel.fromJson(i));
        }

        await prefs.setInt(PrefsKeys.INFO_DATA_TIME, date);
      }

      return list;
    }
  }

  static Future<List<CourseTime>> getAllTime() async {
    final allCourse = await getAllCourse();
    final weekData = await getWeek();
    var now = DateTime.now();

    final List<CourseTime> timeList = [];
    final weekCourses = allCourse.where((course) {
      return course.weekIndexes.contains(weekData["week"]!);
    }).toList();

    for (var j = now.weekday; j < 7; j++) {
      final dayCourses = weekCourses.where((course) {
        return course.weekday == j;
      }).toList();

      dayCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

      for (var courseToday in dayCourses) {
        final time = TimeService.getStartAndEnd(courseToday);
        var l = time.start.split(':');

        var start = DateTime(
            now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);

        if (start.compareTo(now) <= 0) continue;

        if (timeList.isNotEmpty && timeList.last.startTime == start) continue;

        l = time.end.split(':');
        var end = DateTime(
            now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);

        timeList.add(CourseTime(
            startTime: start,
            courseName: courseToday.courseName,
            endTime: end));
      }
      now = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    }
    return timeList;
  }
}
