import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ios_club_app/net/club_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';

import 'package:ios_club_app/models/todo_item.dart';

/// 待办事项服务类
/// 
/// 提供本地和云端待办事项的管理功能，包括获取、设置和同步待办事项列表
class TodoService {

  /// 保存待办事项列表到本地存储
  /// 
  /// 将待办事项列表保存到 SharedPreferences 中，以用户名作为键进行区分
  /// 
  /// [list] 需要保存的待办事项列表
  static Future<void> setTodoList(List<TodoItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.TODO_DATA);
    final String? username = prefs.getString(PrefsKeys.USERNAME);

    if (username != null) {
      final Map<String, dynamic> jsonList =
          jsonString == null ? {} : jsonDecode(jsonString);
      jsonList[username] = list;
      final json = jsonEncode(jsonList);
      prefs.setString(PrefsKeys.TODO_DATA, json);
    } else {
      throw Exception('No data found');
    }
  }

  /// 从本地存储获取待办事项列表
  /// 
  /// 从 SharedPreferences 中读取当前用户的待办事项列表
  static Future<List<TodoItem>> getLocalTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.TODO_DATA);
    final String? username = prefs.getString(PrefsKeys.USERNAME);

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

  /// 从俱乐部服务器获取待办事项列表
  /// 
  /// 通过 HTTP 请求从俱乐部服务器获取用户的待办事项列表
  /// 如果认证失败会尝试重新登录并再次请求
  static Future<List<TodoItem>> getClubTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final memberDataString = prefs.getString(PrefsKeys.MEMBER_DATA);

    if (memberDataString == null || memberDataString.isEmpty) {
      return [];
    }

    final memberData = jsonDecode(memberDataString);

    var jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
    Map<String, String> finalHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt'
    };

    final response = await http.get(
        Uri.parse('https://www.xauat.site/api/Member/GetTodos'),
        headers: finalHeaders);

    if (response.statusCode == 200) {
      final List<TodoItem> list = [];
      for (var i in jsonDecode(response.body)) {
        list.add(fromJsonClub(i));
      }

      return list;
    }

    if (response.statusCode == 401) {
      if (await ClubService.loginMember(memberData['userName'], memberData['userId'])) {
        jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
        finalHeaders['Authorization'] = 'Bearer $jwt';

        if (response.statusCode == 200) {
          final List<TodoItem> list = [];
          for (var i in jsonDecode(response.body)) {
            list.add(fromJsonClub(i));
          }

          return list;
        }
      }
    }

    return [];
  }

  /// 将俱乐部API返回的JSON数据转换为TodoItem对象
  /// 
  /// [json] 从俱乐部API获取的待办事项JSON数据
  /// 返回转换后的TodoItem对象
  static TodoItem fromJsonClub(Map<String, dynamic> json) {
    final a = TodoItem(
      title: json['title'],
      deadline: json['endTime'],
      isCompleted: json['status'] ?? false, // 默认值处理
    );

    a.description = json['description'];
    a.key = json['key'];

    return a;
  }

  /// 将本地待办事项同步到俱乐部服务器
  /// 
  /// 将本地存储的待办事项逐一上传到俱乐部服务器
  /// 如果全部上传成功，则清除本地待办事项数据
  static Future<void> nowToUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final memberDataString = prefs.getString(PrefsKeys.MEMBER_DATA);

    if (memberDataString == null || memberDataString.isEmpty) {
      return;
    }

    var jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
    Map<String, String> finalHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt'
    };

    final list = await getLocalTodoList();
    var isOK = true;
    for (var i in list) {
      final response = await http.post(
          Uri.parse('https://www.xauat.site/api/Member/AddTodo'),
          headers: finalHeaders,
          body: jsonEncode(
            {
              'title': i.title,
              'description': i.description,
              'endTime': i.deadline,
              'status': i.isCompleted
            },
          ));

      if (response.statusCode != 200) {
        isOK = false;
      }
    }

    if (isOK) {
      prefs.remove(PrefsKeys.TODO_DATA);
    }
  }
}