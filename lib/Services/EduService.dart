import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ios_club_app/Services/DataService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/ScoreModel.dart';
import '../Models/UserData.dart';

class EduService {
  Future<bool> getAllData() async {
    try {
      // 调用API
      final prefs = await SharedPreferences.getInstance();
      var now = DateTime.now().millisecondsSinceEpoch;
      final last = prefs.getInt('last_fetch_time');
      if (last != null) {
        if (now - prefs.getInt('last_fetch_time')! < 1000 * 60 * 30) {
          return true;
        }
      }

      final loginResult = await login();
      if (!loginResult) {
        return false;
      }
      var cookieData = await getCookieData();
      await getSemester(userData: cookieData);
      await getTime();
      await getCourse(userData: cookieData);
      await getExam(userData: cookieData);
      await prefs.setInt('last_fetch_time', now);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
      return false;
    }
  }

  Future<bool> loginFromData(String username, String password) async {
    if(username.isEmpty || password.isEmpty){
      return false;
    }

    try {
      // 调用API
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };
      final prefs = await SharedPreferences.getInstance();

      final String jsonBody =
      jsonEncode({'username': username, 'password': password});

      final response = await http.post(
          Uri.parse('https://xauatapi.xauat.site/Login'),
          body: jsonBody,
          headers: finalHeaders);

      if (response.statusCode == 200) {
        await prefs.setString('user_data', response.body);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return false;
  }

  Future<bool> login() async {
    try {
      // 调用API
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };
      final prefs = await SharedPreferences.getInstance();
      final String? username = prefs.getString('username');
      final String? password = prefs.getString('password');

      if(username == null || password == null){
        return false;
      }

      if (username.isEmpty || password.isEmpty) {
        return false;
      }

      final String jsonBody =
          jsonEncode({'username': username, 'password': password});

      final response = await http.post(
          Uri.parse('https://xauatapi.xauat.site/Login'),
          body: jsonBody,
          headers: finalHeaders);

      if (response.statusCode == 200) {
        await prefs.setString('user_data', response.body);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return false;
  }

  Future<UserData?> getCookieData() async {
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

  Future<void> getThisSemester({UserData? userData}) async {
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
        await prefs.setString(
            'this_semester_data', response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> getSemester({UserData? userData}) async {
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
          Uri.parse('https://xauatapi.xauat.site/Score/Semester'),
          headers: finalHeaders);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'semester_data', response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> getCourse({String semester = '281', UserData? userData}) async {

    final data = DataService();
    final time = await data.getTime();
    if (time["startTime"] == null || time["endTime"] == null) {
      return;
    }

    final startTime = DateTime.parse(time["startTime"]!);
    final endTime = DateTime.parse(time["endTime"]!);

    if (DateTime.now().isBefore(startTime) || DateTime.now().isAfter(endTime)) {
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'course_data', jsonEncode(jsonDecode(response.body)));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> getAllScore({UserData? userData}) async {
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

      final data = DataService();
      final list = await data.getSemester();
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

  Future<List<ScoreList>> getAllScoreFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('all_score_data');
    final dateService = DataService();
    final semesters = await dateService.getSemester();

    if(jsonString != null && jsonString.isNotEmpty){
      final List<ScoreList> list = [];
      final Map<String, dynamic> jsonList = jsonDecode(jsonString);
      jsonList.forEach((String key, value) {
        final scoreList = jsonDecode(value);
        list.add(ScoreList(
          semester: semesters.firstWhere((x) => x.semester == key),
          list: (scoreList as List).map((e) => ScoreModel.fromJson(e)).toList(),
        ));
      });

      return list;
    }

    UserData? cookieData = await getCookieData();
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

      final data = DataService();
      final list = await data.getSemester();
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

      return scoreReturnList;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return [];
  }

  Future<void> getExam({String semester = '281', UserData? userData}) async {
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
          Uri.parse('https://xauatapi.xauat.site/Exam'),
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

  Future<void> getTime() async {
    try {
      final response = await http.get(
          Uri.parse('https://xauatapi.xauat.site/Info/Time'));
      if (response.statusCode == 200) {
        // 存储到本地
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'time_data', jsonEncode(jsonDecode(response.body)));
      }
    }catch(e){
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }
}
