import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ios_club_app/Services/club_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/TodoItem.dart';

class TodoService {
  static Future<List<TodoItem>> getTodoList() async {
    final prefs = await SharedPreferences.getInstance();

    final isUpdateToClub = prefs.getBool('is_update_club') ?? false;
    if (isUpdateToClub) {
      return await getClubTodoList();
    }
    final List<TodoItem> list = [];
    list.addAll(await getLocalTodoList());
    //list.addAll(await getClubTodoList());
    return list;
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

  static Future<List<TodoItem>> getLocalTodoList() async {
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
        list.addAll(await getClubTodoList());
        return list;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  static Future<List<TodoItem>> getClubTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final memberDataString = prefs.getString('member_data');

    if (memberDataString == null || memberDataString.isEmpty) {
      return [];
    }

    final memberData = jsonDecode(memberDataString);

    var jwt = prefs.getString('member_jwt');
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
        jwt = prefs.getString('member_jwt');
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

  static Future<void> nowToUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final memberDataString = prefs.getString('member_data');

    if (memberDataString == null || memberDataString.isEmpty) {
      return;
    }

    var jwt = prefs.getString('member_jwt');
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
      prefs.remove("todo_data");
    }
  }
}
