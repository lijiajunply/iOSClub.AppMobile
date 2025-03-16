import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GiteeService {
  static Future<ReleaseModel> getReleases() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? updateIgnored = prefs.getBool('update_ignored');

    if(updateIgnored! == true){
      return ReleaseModel(name: '0.0.0', body: '0.0.0');
    }

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
      return ReleaseModel.fromJson(a[0] as Map<String, dynamic>);
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
        await launchUrl(uri);
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
