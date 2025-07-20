import 'dart:convert' show jsonEncode, utf8, jsonDecode;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class LoginService {
  final http.Client httpClient;

  LoginService(this.httpClient);

  Future<Map<String, dynamic>> loginAsync(
      String username, String password) async {
    var saltResponse = await httpClient.get(
      Uri.parse('https://xauatlogin.zeabur.app/login/$username/$password'),
    );

    var result = jsonDecode(saltResponse.body);

    String studentId = await getCode(result['cookies']);
    if (studentId.isEmpty) {
      return {'success': false};
    }
    return {'success': true, 'studentId': studentId, 'cookie': result['cookies']};
  }

  Future<Map<String, dynamic>> oldLoginAsync(String username, String password) async {
    // 获取 salt

    var saltResponse = await httpClient.get(
      Uri.parse('https://swjw.xauat.edu.cn/student/login-salt'),
    );

    if (saltResponse.statusCode != 200) {
      throw Exception('Failed to get salt');
    }

    String salt = saltResponse.body;
    String cookies = parseCookie(saltResponse.headers['set-cookie']);

    // 准备登录参数
    var loginParams = {
      'salt': salt,
      'username': username,
      'password': password
    };

    var encodedParams = CodeService.encode(loginParams); // 需要实现对应的加密方法

    // 发送登录请求
    var loginResponse = await httpClient.post(
      Uri.parse('https://swjw.xauat.edu.cn/student/login'),
      headers: {
        'Cookie': cookies,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(encodedParams),
    );

    if (loginResponse.statusCode != 200) {
      throw Exception('Login failed');
    }

    String studentId = await getCode(cookies);
    if (studentId.isEmpty) {
      return {'success': false};
    }
    return {'success': true, 'studentId': studentId, 'cookie': cookies};
  }

  Future<String> getCode(String cookies) async {
    final dio = Dio();

    try {
      final response = await dio.get(
        'https://swjw.xauat.edu.cn/student/for-std/precaution',
        options: Options(
          headers: {'Cookie': cookies},
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      if (response.statusCode != 200) {
        return '';
      }

      // Dio会跟踪重定向并在response.realUri中保存最终URL
      final finalUrl = response.realUri.path;
      final result = finalUrl
          .replaceAll('/student/precaution/index/', '');

      if (result == '/student/for-std/precaution') {
        var content = response.data;
        var regex = RegExp(r'value="(.*?)">');
        var match = regex.allMatches(content);
        return match.map((x) => x.group(1)).join(',');
      }

      return result;
    } catch (e) {
      return '';
    } finally {
      dio.close();
    }
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
