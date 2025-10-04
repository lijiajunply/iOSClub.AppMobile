import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class NetService {
  static Future<Map<String, dynamic>> get() async {
    const maxRetries = 3;
    const timeoutDuration = Duration(seconds: 3);
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(
                'http://10.99.144.34/cgi-bin/rad_user_info?callback=json'))
            .timeout(timeoutDuration);
            
        if (response.statusCode == 200) {
          var text = response.body;
          text = text.substring(text.indexOf('{'), text.lastIndexOf('}') + 1);
          final res = jsonDecode(text);
          return res;
        } else {
          throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      } on SocketException catch (e) {
        if (attempt == maxRetries - 1) {
          throw Exception('网络连接失败: $e');
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      } on TimeoutException catch (e) {
        if (attempt == maxRetries - 1) {
          throw Exception('请求超时: $e');
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      } catch (e) {
        if (attempt == maxRetries - 1) {
          throw Exception('请求失败: $e');
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
    
    throw Exception('获取数据失败');
  }
}