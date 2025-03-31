import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ios_club_app/Models/BusModel.dart';
import 'package:ios_club_app/Services/DataService.dart';
import 'package:ios_club_app/Services/LoginService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/ScoreModel.dart';
import '../Models/UserData.dart';

class EduService {
  static Future<bool> getAllData() async {
    try {
      // 调用API
      final prefs = await SharedPreferences.getInstance();
      var now = DateTime.now().millisecondsSinceEpoch;
      final last = prefs.getInt('last_fetch_time');
      if (last != null && last != '') {
        if (now - prefs.getInt('last_fetch_time')! < 1000 * 60 * 20) {
          return true;
        }
      }

      final loginResult = await login();
      if (!loginResult) {
        return false;
      }
      var cookieData = await getCookieData();
      await getTime();
      await getCourse(userData: cookieData);
      await getExam(userData: cookieData);
      // await getInfoCompletion(userData: cookieData);
      await prefs.setInt('last_fetch_time', now);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
      return false;
    }
  }

  static Future<bool> refresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var now = DateTime.now().millisecondsSinceEpoch;

      final loginResult = await login();
      if (!loginResult) {
        return false;
      }

      var cookieData = await getCookieData();
      await getSemester(userData: cookieData);
      await getTime();
      await getCourse(userData: cookieData, isRefresh: true);
      await getExam(userData: cookieData);
      await getInfoCompletion(userData: cookieData);
      await prefs.setInt('last_fetch_time', now);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return false;
  }

  static Future<bool> loginFromData(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final loginService = LoginService(http.Client(), CodeService());
      final response = await loginService.loginAsync(username, password);

      if (response["success"] == true) {
        await prefs.setString('user_data', jsonEncode(response));

        var cookieData = await getCookieData();
        var now = DateTime.now().millisecondsSinceEpoch;
        await getSemester(userData: cookieData);
        await getTime();
        await getCourse(userData: cookieData, isRefresh: true);
        await getExam(userData: cookieData);
        await getInfoCompletion(userData: cookieData);
        await prefs.setInt('last_fetch_time', now);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return false;
  }

  static Future<bool> login() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? username = prefs.getString('username');
      final String? password = prefs.getString('password');

      if (username == null || password == null) {
        return false;
      }

      if (username.isEmpty || password.isEmpty) {
        return false;
      }

      final preNow = DateTime.now().millisecondsSinceEpoch;
      final loginService = LoginService(http.Client(), CodeService());
      final response = await loginService.loginAsync(username, password);
      if(kDebugMode){
        print('登录用时: ${DateTime.now().millisecondsSinceEpoch - preNow}');
      }

      if (response["success"] == true) {
        await prefs.setString('user_data', jsonEncode(response));
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return false;
  }

  static Future<UserData?> getCookieData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString('user_data');

      if (jsonString != null) {
        return UserData.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reading local data: $e');
      }
    }
    return null;
  }

  static Future<void> getThisSemester({UserData? userData}) async {
    UserData? cookieData = userData ?? await getCookieData();
    if (cookieData == null) {
      return;
    }

    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final response = await http.get(
          Uri.parse('https://xauatapi.xauat.site/Score/ThisSemester'),
          headers: finalHeaders);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('this_semester_data', response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<void> getSemester({UserData? userData}) async {
    UserData? cookieData = userData ?? await getCookieData();
    if (cookieData == null) {
      return;
    }

    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final response = await http.get(
          Uri.parse(
              'https://xauatapi.xauat.site/Score/Semester?studentId=${cookieData.studentId}'),
          headers: finalHeaders);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('semester_data', response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<void> getCourse(
      {UserData? userData,
      bool isRefresh = false}) async {
    final time = await DataService.getTime();
    final week = await DataService.getWeek();
    if (!isRefresh &&
        (time["startTime"] == null ||
            time["endTime"] == null ||
            week["week"] == null)) {
      return;
    }

    final startTime = DateTime.parse(time["startTime"]!);
    final endTime = DateTime.parse(time["endTime"]!);

    if (!isRefresh &&
        (DateTime.now().isBefore(startTime) ||
            DateTime.now().isAfter(endTime))) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('course_data');
    if (jsonString != null &&
        jsonString.isNotEmpty &&
        week["week"] != null &&
        week["week"] is int &&
        week["week"]! > 2) {
      return;
    }

    UserData? cookieData = userData ?? await getCookieData();
    if (cookieData == null) {
      return;
    }

    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final response = await http.get(
          Uri.parse(
              'https://xauatapi.xauat.site/Course?studentId=${cookieData.studentId}'),
          headers: finalHeaders);
      if (response.statusCode == 200) {
        // 存储到本地

        await prefs.setString(
            'course_data', jsonEncode(jsonDecode(response.body)));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<void> getAllScore({UserData? userData}) async {
    UserData? cookieData = userData ?? await getCookieData();
    if (cookieData == null) {
      return;
    }

    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final list = await DataService.getSemester();
      final Map<String, String> json = {};
      for (var item in list) {
        final response = await http.get(
            Uri.parse(
                'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${item.semester}'),
            headers: finalHeaders);

        if (response.statusCode == 200) {
          json[item.semester] = response.body;
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('all_score_data', jsonEncode(json));
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<List<ScoreList>> getAllScoreFromLocal(
      {bool isRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('all_score_data');
    var now = DateTime.now().millisecondsSinceEpoch;

    final semesters = await DataService.getSemester();

    final last = prefs.getInt('last_Score_time');
    if (last != null && !isRefresh) {
      if (now - prefs.getInt('last_Score_time')! < 1000 * 60 * 60) {
        if (jsonString != null && jsonString.isNotEmpty) {
          final List<ScoreList> list = [];
          final Map<String, dynamic> jsonList = jsonDecode(jsonString);
          jsonList.forEach((String key, value) {
            final scoreList = jsonDecode(value);
            list.add(ScoreList(
              semester: semesters.firstWhere((x) => x.semester == key),
              list: (scoreList as List)
                  .map((e) => ScoreModel.fromJson(e))
                  .toList(),
            ));
          });

          return list;
        }
      }
    }

    UserData? cookieData = await getCookieData();
    if (cookieData == null) {
      return [];
    }

    try {
      Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final list = await DataService.getSemester();
      final Map<String, String> json = {};
      for (var item in list) {
        final response = await http.get(
            Uri.parse(
                'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${item.semester}'),
            headers: finalHeaders);

        if (response.statusCode == 200) {
          json[item.semester] = response.body;
        } else {
          await login();
          final a = await getCookieData();
          if (a == null) {
            continue;
          }
          finalHeaders = {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Cookie': a.cookie,
            'xauat': a.cookie,
          };
          final response = await http.get(
              Uri.parse(
                  'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${item.semester}'),
              headers: finalHeaders);
          if (response.statusCode == 200) {
            json[item.semester] = response.body;
          }
        }
      }

      await prefs.setString('all_score_data', jsonEncode(json));

      final List<ScoreList> scoreReturnList = [];
      final Map<String, dynamic> jsonList = jsonDecode(jsonEncode(json));
      jsonList.forEach((String key, value) {
        final scoreList = jsonDecode(value);
        scoreReturnList.add(ScoreList(
          semester: semesters.firstWhere((x) => x.semester == key),
          list: (scoreList as List).map((e) => ScoreModel.fromJson(e)).toList(),
        ));
      });

      await prefs.setInt('last_Score_time', now);
      return scoreReturnList;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return [];
  }

  static Future<void> getExam({UserData? userData}) async {
    UserData? cookieData = userData ?? await getCookieData();
    if (cookieData == null) {
      return;
    }

    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final response = await http.get(
          Uri.parse(
              'https://xauatapi.xauat.site/Exam?studentId=${cookieData.studentId}'),
          headers: finalHeaders);
      if (response.statusCode == 200) {
        // 存储到本地
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'exam_data', jsonEncode(jsonDecode(response.body)));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<void> getTime() async {
    try {
      final response =
          await http.get(Uri.parse('https://xauatapi.xauat.site/Info/Time'));
      if (response.statusCode == 200) {
        // 存储到本地
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'time_data', jsonEncode(jsonDecode(response.body)));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<void> getInfoCompletion({UserData? userData}) async {
    UserData? cookieData = userData ?? await getCookieData();
    if (cookieData == null) {
      return;
    }

    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final response = await http.get(
          Uri.parse('https://xauatapi.xauat.site/Info/Completion'),
          headers: finalHeaders);
      if (response.statusCode == 200) {
        // 存储到本地
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'info_data', jsonEncode(jsonDecode(response.body)));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<BusModel> getBus({String? dayDate}) async {
    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
          Uri.parse('https://xauatapi.xauat.site/Bus/${dayDate ?? ''}'),
          headers: finalHeaders);
      if (response.statusCode == 200) {
        final now = DateTime.now();
        var result = BusModel.fromJson(jsonDecode(response.body));
        if (result.records.isNotEmpty &&
            dayDate == DateFormat('yyyy-MM-dd').format(now)) {
          result.records = result.records.where((element) {
            final split = element.runTime.split(':');
            if (split.length < 2) return false;
            var time = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(split[0]),
              int.parse(split[1]),
            );
            return time.isAfter(now);
          }).toList();
        }

        return result;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return BusModel(records: [], total: 0);
  }
}
