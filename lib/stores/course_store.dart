import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import 'prefs_keys.dart';

class CourseStore extends GetxController {
  static CourseStore get to => Get.find();

  final _courses = <CourseModel>[].obs;
  final _ignoreCourses = <String>[].obs;

  List<CourseModel> get courses => _courses.toList();
  List<String> get ignoreCourses => _ignoreCourses.toList();

  /// 加载所有课程
  Future<void> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.COURSE_DATA);
    
    if (jsonString != null) {
      try {
        final List<CourseModel> list = [];
        var jsonList = jsonDecode(jsonString);
        jsonList = jsonList["data"];
        for (var json in jsonList) {
          list.add(CourseModel.fromJson(json));
        }
        _courses.assignAll(list);
      } catch (e) {
        // 解析失败，清除数据
        await prefs.remove(PrefsKeys.COURSE_DATA);
      }
    }
  }

  /// 加载忽略的课程
  Future<void> loadIgnoreCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.IGNORE_DATA);
    
    if (jsonString != null) {
      try {
        final List<String> list = [];
        var jsonList = jsonDecode(jsonString);
        jsonList = jsonList["data"];
        for (var json in jsonList) {
          list.add(json);
        }
        _ignoreCourses.assignAll(list);
      } catch (e) {
        // 解析失败，清除数据
        await prefs.remove(PrefsKeys.IGNORE_DATA);
      }
    }
  }

  /// 设置忽略的课程
  Future<void> setIgnoreCourses(List<String> ignoreList) async {
    _ignoreCourses.assignAll(ignoreList);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.IGNORE_DATA, jsonEncode({"data": ignoreList}));
  }

  /// 添加忽略的课程
  Future<void> addIgnoreCourse(String courseName) async {
    if (!_ignoreCourses.contains(courseName)) {
      _ignoreCourses.add(courseName);
      await setIgnoreCourses(_ignoreCourses.toList());
    }
  }

  /// 移除忽略的课程
  Future<void> removeIgnoreCourse(String courseName) async {
    if (_ignoreCourses.contains(courseName)) {
      _ignoreCourses.remove(courseName);
      await setIgnoreCourses(_ignoreCourses.toList());
    }
  }
}