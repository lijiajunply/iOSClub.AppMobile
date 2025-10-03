import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ios_club_app/models/member_model.dart';
import 'package:ios_club_app/services/gzip_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';

import 'package:ios_club_app/models/link_model.dart';
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
          await prefs.setString(PrefsKeys.MEMBER_DATA, response.body);
          await prefs.setString(PrefsKeys.MEMBER_JWT, jwt);
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
    final Map<String, dynamic> data = {};
    Map<String, dynamic> memberData = {};
    try {
      final memberDataString = prefs.getString(PrefsKeys.MEMBER_DATA);
      memberData = jsonDecode(memberDataString ?? '{}');
      data['memberData'] = memberData;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
      prefs.setString(PrefsKeys.MEMBER_DATA, '');
      return {};
    }
    data['memberData'] = memberData;

    if (prefs.getString(PrefsKeys.MEMBER_JWT) != null) {
      var jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
      Map<String, String> finalHeaders = {
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
        if (response.statusCode == 401) {
          if (await loginMember(memberData['userName'], memberData['userId'])) {
            jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
            finalHeaders['Authorization'] = 'Bearer $jwt';

            final response = await http.get(
                Uri.parse('https://www.xauat.site/api/Member/GetInfo'),
                headers: finalHeaders);

            if (response.statusCode == 200) {
              if (kDebugMode) {
                print('GetInfo successful');
              }
              data['info'] = jsonDecode(response.body);
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching data: $e');
        }
      }
    }

    return data;
  }

  static Future<MemberData> getMembersByPage(int pageNum, int pageSize) async {
    final url =
        'https://www.xauat.site/api/President/GetAllDataByPage?pageNum=$pageNum&pageSize=$pageSize';
    final prefs = await SharedPreferences.getInstance();
    final memberDataString = prefs.getString(PrefsKeys.MEMBER_DATA);

    final memberData = jsonDecode(memberDataString ?? '{}');
    var jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
    if (jwt == null) {
      return MemberData(
        data: [],
        totalCount: 0,
        totalPages: 0,
      );
    }

    Map<String, String> finalHeaders = {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: finalHeaders);

      if (response.statusCode == 200) {
        var result = await GzipService.decompress(response.body);
        return MemberData.fromJson(jsonDecode(result));
      }
      if (response.statusCode == 401) {
        if (await ClubService.loginMember(
            memberData['userName'], memberData['userId'])) {
          jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
          finalHeaders['Authorization'] = 'Bearer $jwt';

          final response =
              await http.get(Uri.parse(url), headers: finalHeaders);

          if (response.statusCode == 200) {
            if (kDebugMode) {
              print('GetAllDataByPage successful');
            }
            var result = await GzipService.decompress(response.body);
            return MemberData.fromJson(jsonDecode(result));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return MemberData(
      data: [],
      totalCount: 0,
      totalPages: 0,
    );
  }

  static Future<MemberData> getStaffsByPage(int pageNum, int pageSize) async {
    final url =
        'https://www.xauat.site/api/President/GetStaffsByPage?pageNum=$pageNum&pageSize=$pageSize';
    final prefs = await SharedPreferences.getInstance();
    final memberDataString = prefs.getString(PrefsKeys.MEMBER_DATA);

    final memberData = jsonDecode(memberDataString ?? '{}');
    var jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
    if (jwt == null) {
      return MemberData(
        data: [],
        totalCount: 0,
        totalPages: 0,
      );
    }

    Map<String, String> finalHeaders = {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: finalHeaders);

      if (response.statusCode == 200) {
        var result = await GzipService.decompress(response.body);
        return MemberData.fromJson(jsonDecode(result));
      }
      if (response.statusCode == 401) {
        if (await ClubService.loginMember(
            memberData['userName'], memberData['userId'])) {
          jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
          finalHeaders['Authorization'] = 'Bearer $jwt';

          final response =
              await http.get(Uri.parse(url), headers: finalHeaders);

          if (response.statusCode == 200) {
            if (kDebugMode) {
              print('GetStaffsByPage successful');
            }
            var result = await GzipService.decompress(response.body);
            return MemberData.fromJson(jsonDecode(result));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return MemberData(
      data: [],
      totalCount: 0,
      totalPages: 0,
    );
  }
}
