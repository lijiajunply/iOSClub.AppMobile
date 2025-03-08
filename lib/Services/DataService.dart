import 'dart:convert';
import 'package:ios_club_app/Models/ScoreModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/CourseModel.dart';
import '../Models/ExamModel.dart';
import '../Models/SemesterModel.dart';

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
    final week = DateTime.now().difference(DateTime.parse(time["startTime"]!)).inDays ~/ 7 + 1;
    final maxWeek =DateTime.parse(time["endTime"]!).difference(DateTime.parse(time["startTime"]!)).inDays ~/ 7 + 1;
    return {'week':week,'maxWeek':maxWeek};
  }

  Future<List<CourseModel>> getCourseByWeek({int week = 0}) async {
    final allCourse = await getAllCourse();
    if(week == 0){
      final time = await getTime();
      week = DateTime.now().difference(DateTime.parse(time["startTime"]!)).inDays ~/ 7 + 1;
    }
    return allCourse
        .where((course) => course.weekIndexes.contains(week))
        .toList();
  }

  Future<List<CourseModel>> getCourse() async {
    final allCourse = await getAllCourse();
    final time = await getTime();
    var a = DateTime.now().difference(DateTime.parse(time["startTime"]!)).inDays ~/ 7 + 1;
    return allCourse
        .where((course) =>
            course.weekIndexes.contains(a) &&
            course.weekday == DateTime.now().weekday)
        .toList();
  }

  Future<List<ScoreModel>> getScore() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('score_data');
    final List<ScoreModel> list = [];
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString);
      jsonList.forEach((json) {
        list.add(ScoreModel.fromJson(json));
      });
    }

    return list;
  }

  Future<List<ExamDataRaw>> getExam() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('exam_data');
    final List<ExamDataRaw> list = [];
    if (jsonString != null) {
      var jsonList = jsonDecode(jsonString);
      jsonList = jsonList["exams"];
      jsonList.forEach((json) {
        list.add(ExamDataRaw.fromJson(json));
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
}
