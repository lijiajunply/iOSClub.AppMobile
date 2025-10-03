import 'dart:convert' show utf8, jsonDecode, jsonEncode;

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final http.Client httpClient;

  LoginService(this.httpClient);

  Future<Map<String, dynamic>> loginAsync(
      String username, String password) async {
    final Map<String, String> finalHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    };

    var saltResponse =
        await httpClient.post(Uri.parse('https://xauatapi.xauat.site/Login'),
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
            headers: finalHeaders);

    var a = jsonDecode(saltResponse.body);
    return a;
  }

  String parseCookie(String? cookiesHeader) {
    if (cookiesHeader == null) return '';

    StringBuffer result = StringBuffer();
    List<String> cookies = cookiesHeader.split(',');

    for (var cookie in cookies) {
      if (cookie.contains('__pstsid__')) {
        result.write(cookie);
        result.write(';');
      } else if (cookie.contains('SESSION')) {
        var sessionValue = cookie.split('=')[1].split(';')[0];
        result.write('SESSION=');
        result.write(sessionValue);
        result.write(';');
      }
    }

    return result.toString();
  }
}

class CodeService {
  static dynamic encode(Map<String, dynamic>? loginParams) {
    if (loginParams == null) {
      throw ArgumentError.notNull('loginParams');
    }

    // 验证必要的参数是否存在
    if (!loginParams.containsKey('salt') ||
        !loginParams.containsKey('password') ||
        !loginParams.containsKey('username')) {
      throw ArgumentError('Invalid login parameters', 'loginParams');
    }

    // 计算 SHA1
    String encPassword =
        calculateSHA1('${loginParams['salt']}-${loginParams['password']}');

    // 创建返回对象
    var result = {
      'username': loginParams['username'],
      'password': encPassword,
      'captcha': ''
    };

    return result;
  }

  static String calculateSHA1(String input) {
    // 将输入字符串转换为字节
    List<int> inputBytes = utf8.encode(input);

    // 计算SHA1哈希
    Digest digest = sha1.convert(inputBytes);

    // 返回十六进制字符串
    return digest.toString();
  }
}