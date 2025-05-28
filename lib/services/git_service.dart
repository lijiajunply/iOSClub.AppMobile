import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GiteeService {
  static Future<ReleaseModel> getReleases() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, String> finalHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
        Uri.parse('https://xauatapi.xauat.site/App'),
        headers: finalHeaders);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final a = jsonDecode(jsonResponse);
      final re = ReleaseModel.fromJson(a[0] as Map<String, dynamic>);

      if(re.body.contains('[强制更新]')){
        return re;
      }

      final bool? updateIgnored = prefs.getBool('update_ignored');

      if (updateIgnored != null && updateIgnored == true) {
        return ReleaseModel(name: '0.0.0', body: '0.0.0');
      }

      return re;
    } else {
      return ReleaseModel(name: '0.0.0', body: '0.0.0');
    }
  }

  static Future<bool> isNeedUpdate() async {
    final result = await getReleases();
    final packageInfo = await PackageInfo.fromPlatform();
    return result.name != '0.0.0' && result.name != packageInfo.version;
  }

  static Future<void> updateApp(String name) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (name != packageInfo.version) {
      final Uri uri = Uri.parse(
          'https://gitee.com/luckyfishisdashen/iOSClub.AppMobile/releases/download/$name/app-release.apk');

      if (await canLaunchUrl(uri)) {
        final Map<String, String> finalHeaders = {
          'Content-Type': 'application/vnd.android.package-archive',
        };

        final response = await http.get(uri, headers: finalHeaders);

        if (response.statusCode == 200) {
          // 获取应用缓存目录
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/app-release.apk';

          // 保存文件到本地
          final file = File(filePath);
          if(file.existsSync()){
            await file.delete();
          }else{
            await file.create();
          }
          await file.writeAsBytes(response.bodyBytes);

          try{
            await OpenFile.open(filePath);
          }
          catch (e) {
            if (kDebugMode) {
              print('无法打开APK: $e');
            }
          }

          if (kDebugMode) {
            print('APK下载成功: $filePath');
          }
          // 可在此处添加安装APK的逻辑
        } else {
          throw '下载失败，状态码: ${response.statusCode}';
        }
      } else {
        throw '无法下载';
      }
    }
  }
}

class ReleaseModel {
  final String name;
  final String body;

  ReleaseModel({
    required this.name,
    required this.body,
  });

  factory ReleaseModel.fromJson(Map<String, dynamic> json) {
    return ReleaseModel(
      name: json['name'],
      body: json['body'],
    );
  }
}
