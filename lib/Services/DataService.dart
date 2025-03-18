import 'dart:convert';
import 'package:ios_club_app/Models/InfoModel.dart';
import 'package:ios_club_app/Models/ScoreModel.dart';
import 'package:ios_club_app/Models/TodoItem.dart';
import 'package:ios_club_app/Services/EduService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/CourseModel.dart';
import '../PageModels/CourseTime.dart';
import '../Models/ExamModel.dart';
import '../Models/SemesterModel.dart';
import 'TimeService.dart';

class DataService {
  static Future<List<CourseModel>> getAllCourse({bool isNeedIgnore = true}) async {
    List<String> ig = [];
    if (isNeedIgnore) {
      ig = await getIgnore();
    }
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('course_data');
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
    final String? jsonString = prefs.getString('course_data');
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
    prefs.setString('ignore_data', jsonEncode({"data": list}));
  }

  static Future<List<String>> getIgnore() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('ignore_data');
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
    final week =
        DateTime.now().difference(DateTime.parse(time["startTime"]!)).inDays ~/
                7 +
            1;
    final maxWeek = DateTime.parse(time["endTime"]!)
                .difference(DateTime.parse(time["startTime"]!))
                .inDays ~/
            7 +
        1;
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

  static Future<List<CourseModel>> getCourse() async {
    final allCourse = await getAllCourse();
    final time = await getTime();
    final now = DateTime.now();
    var a = now.difference(DateTime.parse(time["startTime"]!)).inDays ~/ 7 + 1;
    final filteredCourses = allCourse.where((course) {
      var endTime = "";
      if (course.room.substring(0, 2) == "雁塔") {
        if (now.month >= 5 && now.month <= 10) {
          endTime = TimeService.YanTaXia[course.endUnit];
        } else {
          endTime = TimeService.YanTaDong[course.endUnit];
        }
      } else {
        endTime = TimeService.CanTangTime[course.endUnit];
      }

      final l = endTime.split(':');
      var end = DateTime(
          now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);
      return course.weekIndexes.contains(a) &&
          course.weekday == now.weekday &&
          now.isBefore(end);
    }).toList();

    filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    return filteredCourses;
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

  static Future<List<ExamItem>> getExam() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('exam_data');
    final List<ExamItem> list = [];
    if (jsonString != null) {
      var jsonList = jsonDecode(jsonString);
      jsonList = jsonList["exams"];
      jsonList.forEach((json) {
        list.add(ExamItem.fromJson(json));
      });
    }

    return list;
  }

  static Future<List<SemesterModel>> getSemester() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('semester_data');
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
    final String? jsonString = prefs.getString('time_data');
    final Map<String, String> list = {};
    if (jsonString != null) {
      var jsonList = jsonDecode(jsonString);
      jsonList.forEach((key, value) {
        list[key] = value.toString();
      });
    }

    return list;
  }

  static Future<List<InfoModel>> getInfoList() async {
    List<InfoModel> list = [];
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('info_data');

    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString);
      for (var i in jsonList) {
        list.add(InfoModel.fromJson(i));
      }
      return list;
    } else {
      await EduService.getInfoCompletion();
      final String? jsonString = prefs.getString('info_data');

      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString);
        for (var i in jsonList) {
          list.add(InfoModel.fromJson(i));
        }
      }

      return list;
    }
  }

  static Future<List<TodoItem>> getTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('todo_data');
    final String? username = prefs.getString('username');

    if (jsonString != null && username != null) {
      final List<TodoItem> list = [];

      final Map<String, dynamic> jsonList = jsonDecode(jsonString);
      if (jsonList.containsKey(username)) {
        final d = jsonList[username];
        for (var i in d) {
          list.add(TodoItem.fromJson(i));
        }
        return list;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  static Future<void> setTodoList(List<TodoItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('todo_data');
    final String? username = prefs.getString('username');

    if (username != null) {
      final Map<String, dynamic> jsonList =
          jsonString == null ? {} : jsonDecode(jsonString);
      jsonList[username] = list;
      final json = jsonEncode(jsonList);
      prefs.setString('todo_data', json);
    } else {
      throw Exception('No data found');
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
        var startTime = "";
        var endTime = "";
        if (courseToday.room.substring(0, 2) == "草堂") {
          startTime = TimeService.CanTangTime[courseToday.startUnit];
          endTime = TimeService.CanTangTime[courseToday.endUnit];
        } else {
          final now = DateTime.now();
          if (now.month >= 5 && now.month <= 10) {
            startTime = TimeService.YanTaXia[courseToday.startUnit];
            endTime = TimeService.YanTaXia[courseToday.endUnit];
          } else {
            startTime = TimeService.YanTaDong[courseToday.startUnit];
            endTime = TimeService.YanTaDong[courseToday.endUnit];
          }
        }
        var l = startTime.split(':');

        var start = DateTime(
            now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);

        if (start.compareTo(now) <= 0) continue;

        if (timeList.isNotEmpty && timeList.last == start) continue;

        l = endTime.split(':');
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
