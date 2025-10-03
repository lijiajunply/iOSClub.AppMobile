import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ios_club_app/models/bus_model.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:ios_club_app/services/login_service.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/models/score_model.dart';
import 'package:ios_club_app/models/user_data.dart';
import 'package:ios_club_app/models/plan_course.dart';

class EduService {
  static Future<bool> refresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var now = DateTime.now().millisecondsSinceEpoch;

      final loginResult = await login();
      if (!loginResult) {
        return false;
      }

      var cookieData = await getUserData();
      await getSemester(userData: cookieData);
      await getTime();
      await getCourse(userData: cookieData, isRefresh: true);
      await getExam(userData: cookieData);
      await getInfoCompletion(userData: cookieData);
      await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now);
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

    final prefs = await SharedPreferences.getInstance();

    final loginService = LoginService(http.Client());
    final response = await loginService.loginAsync(username, password);
    if (response["success"] == true) {
      await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(response));

      var cookieData = await getUserData();
      var now = DateTime.now().millisecondsSinceEpoch;
      await getSemester(userData: cookieData);
      await getTime();
      await getCourse(userData: cookieData, isRefresh: true);
      await getExam(userData: cookieData);
      await getInfoCompletion(userData: cookieData);
      await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now);
      return true;
    }

    return false;
  }

  static Future<bool> login() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? username = prefs.getString(PrefsKeys.USERNAME);
      final String? password = prefs.getString(PrefsKeys.PASSWORD);

      if (username == null || password == null) {
        return false;
      }

      if (username.isEmpty || password.isEmpty) {
        return false;
      }

      final preNow = DateTime.now().millisecondsSinceEpoch;
      final loginService = LoginService(http.Client());
      final response = await loginService.loginAsync(username, password);
      if (kDebugMode) {
        print('登录用时: ${DateTime.now().millisecondsSinceEpoch - preNow}');
      }

      if (response["success"] == true) {
        await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(response));
        var now = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now);

        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return false;
  }

  static Future<UserData?> getUserData() async {
    // 尝试获取缓存数据
    final cachedData = await getCookie();
    if (cachedData is UserData) return cachedData;

    // 缓存无效时尝试登录
    final loginSuccess = await login();
    if (!loginSuccess) return null;

    // 登录后重新获取数据
    final freshData = await getCookie();
    if (freshData is UserData) return freshData;

    // 数据仍然无效时抛出异常（或根据业务需求处理）
    throw const FormatException(
        'Cookie data is invalid after successful login');
  }

  static Future<UserData?> getCookie() async {
    try {
      var now = DateTime.now().millisecondsSinceEpoch;

      final prefs = await SharedPreferences.getInstance();
      final lastFetchTime = prefs.getInt(PrefsKeys.LAST_FETCH_TIME);
      if (lastFetchTime == null || now - lastFetchTime > 1000 * 60 * 20) {
        // 20小时
        return null;
      }
      final String? jsonString = prefs.getString(PrefsKeys.USER_DATA);

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
    UserData? cookieData = userData ?? await getUserData();
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
        await prefs.setString(PrefsKeys.THIS_SEMESTER_DATA, response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<void> getSemester({UserData? userData}) async {
    UserData? cookieData = userData ?? await getUserData();
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
        await prefs.setString(PrefsKeys.SEMESTER_DATA, response.body);

        final now = DateTime.now().microsecondsSinceEpoch;
        await prefs.setInt(PrefsKeys.SEMESTER_TIME, now);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<void> getCourse(
      {UserData? userData, bool isRefresh = false}) async {
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
    final String? jsonString = prefs.getString(PrefsKeys.COURSE_DATA);
    if (jsonString != null &&
        jsonString.isNotEmpty &&
        week["week"] != null &&
        week["week"] is int &&
        week["week"]! > 2 &&
        !isRefresh) {
      return;
    }

    UserData? cookieData = userData ?? await getUserData();
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
            PrefsKeys.COURSE_DATA, jsonEncode(jsonDecode(response.body)));
      } else {
        if (!(await login())) return;
        var a = await getUserData();
        if (a == null) return;
        final response = await http.get(
            Uri.parse(
                'https://xauatapi.xauat.site/Course?studentId=${a.studentId}'),
            headers: finalHeaders);
        if (response.statusCode == 200) {
          await prefs.setString(
              PrefsKeys.COURSE_DATA, jsonEncode(jsonDecode(response.body)));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<void> getAllScore({UserData? userData}) async {
    var cookieData = userData ?? await getUserData();
    if (cookieData == null) {
      return;
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
        var response = await http.get(
            Uri.parse(
                'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${item.semester}'),
            headers: finalHeaders);

        if (response.statusCode == 200) {
          json[item.semester] = response.body;
        } else {
          if (!(await login())) return;
          var a = await getUserData();
          if (a == null) {
            continue;
          }

          finalHeaders['Cookie'] = finalHeaders['Cookie'] = a.cookie;
          response = await http.get(
              Uri.parse(
                  'https://xauatapi.xauat.site/Score?studentId=${a.studentId}&semester=${item.semester}'),
              headers: finalHeaders);

          if (response.statusCode == 200) {
            json[item.semester] = response.body;
          }
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefsKeys.ALL_SCORE_DATA, jsonEncode(json));
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<List<ScoreList>> getAllScoreFromLocal(
      {bool isRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.ALL_SCORE_DATA);
    var now = DateTime.now().millisecondsSinceEpoch;

    final semesters = await DataService.getSemester();

    final last = prefs.getInt(PrefsKeys.LAST_SCORE_TIME);
    if (last != null && !isRefresh) {
      if (now - prefs.getInt(PrefsKeys.LAST_SCORE_TIME)! < 1000 * 60 * 60) {
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

    UserData? cookieData = await getUserData();
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
          if (!(await login())) return [];
          final a = await getUserData();
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

      await prefs.setString(PrefsKeys.ALL_SCORE_DATA, jsonEncode(json));

      final List<ScoreList> scoreReturnList = [];
      final Map<String, dynamic> jsonList = jsonDecode(jsonEncode(json));
      jsonList.forEach((String key, value) {
        final scoreList = jsonDecode(value);
        scoreReturnList.add(ScoreList(
          semester: semesters.firstWhere((x) => x.semester == key),
          list: (scoreList as List).map((e) => ScoreModel.fromJson(e)).toList(),
        ));
      });

      await prefs.setInt(PrefsKeys.LAST_SCORE_TIME, now);
      return scoreReturnList;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return [];
  }

  static Future<void> getExam({UserData? userData}) async {
    UserData? cookieData = userData ?? await getUserData();
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
      final prefs = await SharedPreferences.getInstance();
      if (response.statusCode == 200) {
        await prefs.setString(
            PrefsKeys.EXAM_DATA, jsonEncode(jsonDecode(response.body)));
      } else {
        if (!(await login())) return;
        final a = await getUserData();
        if (a == null) {
          return;
        }
        finalHeaders['Cookie'] = finalHeaders['xauat'] = a.cookie;
        final response = await http.get(
            Uri.parse(
                'https://xauatapi.xauat.site/Exam?studentId=${a.studentId}'),
            headers: finalHeaders);
        if (response.statusCode == 200) {
          await prefs.setString(
              PrefsKeys.EXAM_DATA, jsonEncode(jsonDecode(response.body)));
        }
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
            PrefsKeys.TIME_DATA, jsonEncode(jsonDecode(response.body)));
        final now = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(PrefsKeys.TIME_LAST_UPDATED, now);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  static Future<void> getInfoCompletion({UserData? userData}) async {
    UserData? cookieData = userData ?? await getUserData();
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

      final prefs = await SharedPreferences.getInstance();
      final response = await http.get(
          Uri.parse('https://xauatapi.xauat.site/Info/Completion'),
          headers: finalHeaders);
      if (response.statusCode == 200) {
        await prefs.setString(
            PrefsKeys.INFO_DATA, jsonEncode(jsonDecode(response.body)));
      } else {
        if (!(await login())) return;
        final a = await getUserData();
        if (a == null) {
          return;
        }

        finalHeaders['Cookie'] = finalHeaders['xauat'] = a.cookie;
        final response = await http.get(
            Uri.parse('https://xauatapi.xauat.site/Info/Completion'),
            headers: finalHeaders);

        if (response.statusCode == 200) {
          await prefs.setString(
              PrefsKeys.INFO_DATA, jsonEncode(jsonDecode(response.body)));
        }
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

  static Future<List<PlanCourse>> getProgram() async {
    UserData? cookieData = await getUserData();
    if (cookieData == null) {
      return [];
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
              'https://xauatapi.xauat.site/Program?id=${cookieData.studentId}'),
          headers: finalHeaders);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (kDebugMode) {
          print('找到了培养方案：${result.length}');
        }
        return result.map<PlanCourse>((e) => PlanCourse.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return [];
  }

  static Future<List<PlanCourseList>> getPrograms() async {
    UserData? cookieData = await getUserData();
    if (cookieData == null) {
      return [];
    }

    final Map<String, String> finalHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookieData.cookie,
      'xauat': cookieData.cookie,
    };

    try {
      var response = await http.get(
          Uri.parse(
              'https://xauatapi.xauat.site/Program/GetDic?id=${cookieData.studentId}'),
          headers: finalHeaders);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (kDebugMode) {
          print('找到了培养方案：${result.length}');
        }
        return result.entries
            .map<PlanCourseList>(
                (entry) => PlanCourseList.fromMap(entry.key, entry.value))
            .toList();
      } else {
        if (!(await login())) return [];
        final a = await getUserData();
        if (a == null) {
          return [];
        }

        finalHeaders['Cookie'] = finalHeaders['xauat'] = a.cookie;

        response = await http.get(
            Uri.parse(
                'https://xauatapi.xauat.site/Program/GetDic?id=${cookieData.studentId}'),
            headers: finalHeaders);

        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          if (kDebugMode) {
            print('找到了培养方案：${result.length}');
          }
          return result.entries
              .map<PlanCourseList>(
                  (entry) => PlanCourseList.fromMap(entry.key, entry.value))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return [];
  }
}
