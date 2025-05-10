import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pageModels/ElectricData.dart';

class TileService {
  static Future<double?> getTextAfterKeyword({String? url}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (url == null || url.isEmpty) {
        url = prefs.getString('electricity_url') ?? '';

        if (url.isEmpty) {
          return null;
        }
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('HTTP请求失败: ${response.statusCode}');
      }

      // 解析HTML内容
      final document = parser.parse(response.body);

      // 获取所有文本节点
      final textNodes = document.body?.text
              .split('\n')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty) ??
          [];

      // 遍历所有文本节点查找关键字
      for (var text in textNodes) {
        if (text.contains('充值余额：¥')) {
          // 提取关键字后面的内容
          final textAfterKeyword = text.split('充值余额：¥')[1].trim();
          // 尝试将提取的内容转换为double
          final result = double.tryParse(textAfterKeyword);
          if (result != null) {
            await prefs.setString('electricity_url', url);
            return result;
          }
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('请求失败: $e');
      }
      return null;
    }
  }

  static Future<void> setTiles(List<String> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tiles', map);
  }

  static Future<List<String>> getTiles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('tiles') ?? [];
  }

  static Future<void> openInWeChat(String url) async {
    // 尝试打开微信
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // 如果无法打开微信，则直接在浏览器中打开
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw '无法打开 URL: $url';
      }
    }
  }

  static Future<List<ElectricData>> getElectricityWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();

    var url = prefs.getString('electricity_url') ?? '';

    if (url.isEmpty) {
      return [];
    }

    url = url.replaceAll('wxAccount', 'wxElecDtl');

    final response = await http.get(Uri.parse(url));
    var document = parser.parse(response.body);
    var tables = document.querySelectorAll('table');
    final List<ElectricData> data = [];
    for (var table in tables) {
      var rows = table.querySelectorAll('tr');
      for (var row in rows) {
        var cells = row.querySelectorAll('td');
        if (cells.length == 3) {
          final split = cells[1].text.split(' ');
          final dayTime = split[0].split('/');
          final time = split[1].split(':');
          final date = DateTime(int.parse(dayTime[0]), int.parse(dayTime[1]),
              int.parse(dayTime[2]), int.parse(time[0]));
          if (data.isEmpty || data.last.timestamp.hour != date.hour) {
            data.add(ElectricData(
              timestamp: date,
              value: double.tryParse(cells[2].text)!,
            ));
          } else {
            data.last.value += double.tryParse(cells[2].text)!;
          }
        }
      }
    }

    data.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return data;
  }
}
