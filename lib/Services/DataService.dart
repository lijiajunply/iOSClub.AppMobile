import 'dart:convert';
import 'package:ios_club_app/Models/InfoModel.dart';
import 'package:ios_club_app/Models/ScoreModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/CourseModel.dart';
import '../Models/ExamModel.dart';
import '../Models/SemesterModel.dart';
import 'TimeService.dart';

class DataService {
  Future<List<CourseModel>> getAllCourse() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('course_data');
    final List<CourseModel> list = [];
    if (jsonString != null) {
      var jsonList = jsonDecode(jsonString);
      jsonList = jsonList["data"];
      for (var json in jsonList) {
        list.add(CourseModel.fromJson(json));
      }
    }
    return list;
  }

  Future<Map<String, int>> getWeek() async {
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

  Future<List<CourseModel>> getCourseByWeek({int week = 0}) async {
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

  Future<List<CourseModel>> getCourse() async {
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

  Future<List<ScoreList>> getScore() async {
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

  Future<List<ExamItem>> getExam() async {
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

  Future<List<SemesterModel>> getSemester() async {
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

  Future<Map<String, String>> getTime() async {
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

  Future<InfoModel> getInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('info_data');

    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString);
      return InfoModel.fromJson((jsonList as List<dynamic>)[0]);
    } else {
      throw Exception('No data found');
    }
  }
}
