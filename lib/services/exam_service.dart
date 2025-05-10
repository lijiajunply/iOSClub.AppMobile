import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ios_club_app/Models/UserData.dart';
import 'package:ios_club_app/models/ExamModel.dart';
import 'package:ios_club_app/services/edu_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamService {
  static Future<List<ExamItem>> getExam({bool isRefresh = false}) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // 缓存检查
    final cacheResult = _checkCache(prefs, now, isRefresh);
    if (!cacheResult.$1 && cacheResult.$2.isNotEmpty) {
      return _parseExamItems(cacheResult.$2, now);
    }

    // 数据获取
    final cookieData = await EduService.getUserData();
    if (cookieData == null) return [];

    // HTTP请求
    final result = await _fetchExamData(cookieData, now);
    if (result.$1) {
      await _updateCache(prefs, result.$2, now);
      return _parseExamItems(result.$2, now);
    }

    return [];
  }

  static (bool needRefresh, String jsonString) _checkCache(
      SharedPreferences prefs, DateTime now, bool isRefresh) {
    final String jsonString = prefs.getString('exam_data') ?? '';
    final int? examTime = prefs.getInt('exam_time');

    final bool isCached = examTime != null &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(examTime)).inHours <
            1 &&
        jsonString.isNotEmpty;

    return (isRefresh || !isCached, jsonString);
  }

  static Future<(bool isSuccess, String jsonString)> _fetchExamData(
      UserData cookieData, DateTime now) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final url = Uri.parse(
          'https://xauatapi.xauat.site/Exam?studentId=${cookieData.studentId}');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return (true, jsonEncode(jsonDecode(response.body)));
      }

      debugPrint('Initial request failed: ${response.statusCode}');
      return await _retryWithNewLogin(cookieData, url, headers);
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return (false, '');
    }
  }

  static Future<(bool isSuccess, String jsonString)> _retryWithNewLogin(
      UserData oldCookie, Uri url, Map<String, String> headers) async {
    if (!(await EduService.login())) return (false, '');

    final newCookie = await EduService.getUserData();
    if (newCookie == null) return (false, '');

    try {
      final newHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': newCookie.cookie,
        'xauat': newCookie.cookie,
      };

      final response = await http.get(url, headers: newHeaders);
      final success = response.statusCode == 200;

      debugPrint(success ? '数据获取成功' : '重试失败: ${response.statusCode}');

      return (success, success ? jsonEncode(jsonDecode(response.body)) : '');
    } catch (e) {
      debugPrint('重试请求失败: $e');
      return (false, '');
    }
  }

  static Future<void> _updateCache(
      SharedPreferences prefs, String jsonString, DateTime now) async {
    await prefs.setString('exam_data', jsonString);
    await prefs.setInt('exam_time', now.microsecondsSinceEpoch);
  }

  static List<ExamItem> _parseExamItems(String jsonString, DateTime now) {
    final List<ExamItem> list = [];
    if (jsonString.isEmpty) return list;

    try {
      final jsonList = jsonDecode(jsonString)['exams'];

      for (final json in jsonList) {
        final item = ExamItem.fromJson(json);

        try {
          final endTime = _parseExamTime(item.examTime, now);
          if (endTime != null && !now.isAfter(endTime)) {
            list.add(item);
          }
        } catch (e) {
          debugPrint('时间解析失败: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('JSON解析失败: $e');
    }

    debugPrint('解析完成，找到${list.length}个有效考试');
    return list;
  }

  static DateTime? _parseExamTime(String timeStr, DateTime now) {
    try {
      final timeSplit = timeStr.split(' ');
      final dateSplit = timeSplit[0].split('-');
      final endHourSplit = timeSplit[1].split('~')[1].split(':');

      return DateTime(
        now.year, // 使用当前年份避免绝对过期
        int.parse(dateSplit[1]),
        int.parse(dateSplit[2]),
        int.parse(endHourSplit[0]),
        int.parse(endHourSplit[1]),
      );
    } catch (e) {
      debugPrint('时间格式错误: $e');
      return null;
    }
  }
}
