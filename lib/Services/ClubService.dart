import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/LinkModel.dart';
import 'package:http/http.dart' as http;

class ClubService {
  static Future<List<CategoryModel>> getLinks() async {
    final List<CategoryModel> list = [];
    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
          Uri.parse('https://link.xauat.site/api/Link/GetCategory'),
          headers: finalHeaders);

      if (response.statusCode == 200) {
        for (var item in jsonDecode(response.body)) {
          list.add(CategoryModel.fromJson(item));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    list.sort((a, b) => a.index.compareTo(b.index));
    return list;
  }

  static Future<bool> loginMember(String username, String password) async {
    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      var response =
          await http.post(Uri.parse('https://www.xauat.site/api/Member/Login'),
              headers: finalHeaders,
              body: jsonEncode({
                'Name': username,
                'Id': password,
              }));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Login successful');
        }

        final jwt = response.body.replaceAll('"', '');

        finalHeaders.addAll({'Authorization': 'Bearer $jwt'});

        response = await http.get(
            Uri.parse('https://www.xauat.site/api/Member/GetData'),
            headers: finalHeaders);

        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('GetData successful');
          }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('member_data', response.body);
          await prefs.setString('member_jwt', jwt);
          return true; // 李嘉俊
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return false;
  }

  static Future<Map<String, dynamic>> getMemberInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final memberData = prefs.getString('member_data');

    final Map<String, dynamic> data = {};

    if (memberData != null) {
      data['memberData'] = jsonDecode(memberData);
    }

    if (prefs.getString('member_jwt') != null) {
      final jwt = prefs.getString('member_jwt');
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt'
      };

      try {
        final response = await http.get(
            Uri.parse('https://www.xauat.site/api/Member/GetInfo'),
            headers: finalHeaders);

        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('GetInfo successful');
          }
          data['info'] = jsonDecode(response.body);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching data: $e');
        }
      }
    }

    return data;
  }
}
