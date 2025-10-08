import 'dart:math';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:encrypt/encrypt.dart';

/// 登录令牌模型
class LoginTokenModel {
  final String eduCookie;
  final String ssoCookie;
  final bool success;
  final String message;

  LoginTokenModel({
    this.eduCookie = '',
    this.ssoCookie = '',
    this.success = true,
    this.message = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'eduCookie': eduCookie,
      'ssoCookie': ssoCookie,
      'success': success,
      'message': message,
    };
  }
}

/// 西安建筑科技大学登录客户端
class XAUATLogin {
  late final Dio _dio;
  final String loginUrl = "http://authserver.xauat.edu.cn/authserver/login";
  final String serviceUrl = "https://swjw.xauat.edu.cn/student/sso/login";

  String? _encryptSalt;
  final Map<String, String> _cookies = {};

  // AES加密字符集
  static const String aesChars = "ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678";

  XAUATLogin() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  /// 生成随机字符串
  String _randomString(int length) {
    final random = Random();
    return List.generate(
      length,
          (index) => aesChars[random.nextInt(aesChars.length)],
    ).join();
  }

  /// AES加密方法
  String _encryptAes(String plaintext, String keyString) {
    try {
      final key = Key.fromUtf8(keyString);
      final iv = IV.fromUtf8(_randomString(16));

      // 添加64位随机前缀
      final message = _randomString(64) + plaintext;

      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(message, iv: iv);

      return encrypted.base64;
    } catch (e) {
      print('加密失败: $e');
      return plaintext;
    }
  }

  /// 加密密码
  String _encryptPassword(String password) {
    if (_encryptSalt == null || _encryptSalt!.isEmpty) {
      return password;
    }

    try {
      return _encryptAes(password, _encryptSalt!);
    } catch (e) {
      print('密码加密失败，使用明文密码: $e');
      return password;
    }
  }

  /// 更新Cookie
  void _updateCookies(Map<String, String> newCookies) {
    _cookies.addAll(newCookies);
  }

  /// 从响应头提取Cookie
  Map<String, String> _extractCookies(Map<String, List<String>> headers) {
    final cookies = <String, String>{};
    final cookieHeaders = headers['set-cookie'];

    if (cookieHeaders != null) {
      for (final cookie in cookieHeaders) {
        final parts = cookie.split(';')[0].split('=');
        if (parts.length >= 2) {
          cookies[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    return cookies;
  }

  /// 构建Cookie字符串
  String _buildCookieString(Map<String, String> cookies) {
    return cookies.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('; ');
  }

  /// 获取登录参数
  Future<Map<String, String>> _getLoginParams() async {
    try {
      print('正在获取登录参数...');

      final uri = Uri.parse(loginUrl).replace(
        queryParameters: {'service': serviceUrl},
      );

      final response = await _dio.get(
        uri.toString(),
        options: Options(
          headers: {'Cookie': _buildCookieString(_cookies)},
        ),
      );

      // 更新Cookies
      _updateCookies(_extractCookies(response.headers.map));

      // 解析HTML
      final document = html_parser.parse(response.data);

      final params = <String, String>{};

      // 获取 lt (login ticket)
      final ltInput = document.querySelector('input[name="lt"]');
      if (ltInput != null) {
        params['lt'] = ltInput.attributes['value'] ?? '';
      }

      // 获取 execution
      final executionInput = document.querySelector('input[name="execution"]');
      if (executionInput != null) {
        params['execution'] = executionInput.attributes['value'] ?? '';
      }

      // 获取 _eventId
      final eventInput = document.querySelector('input[name="_eventId"]');
      params['_eventId'] = eventInput?.attributes['value'] ?? 'submit';

      // 获取加密salt
      final saltInput = document.querySelector('input#pwdEncryptSalt');
      _encryptSalt = saltInput?.attributes['value'] ?? 'rjBFAaHsNkKAhpoi';

      // 设置其他参数
      params['captcha'] = '';
      params['cllt'] = 'userNameLogin';
      params['dllt'] = 'generalLogin';

      return params;
    } catch (e) {
      throw Exception('获取登录参数失败: $e');
    }
  }

  /// 执行登录
  Future<LoginTokenModel> login(String username, String password) async {
    try {
      // 获取登录参数
      final params = await _getLoginParams();

      // 加密密码
      final encryptedPassword = _encryptPassword(password);

      // 构建登录数据
      final loginData = {
        'username': username,
        'password': encryptedPassword,
        'lt': params['lt'] ?? '',
        'execution': params['execution'] ?? '',
        '_eventId': params['_eventId'] ?? 'submit',
        'captcha': params['captcha'] ?? '',
        'cllt': params['cllt'] ?? 'userNameLogin',
        'dllt': params['dllt'] ?? 'generalLogin',
        'rememberMe': 'true',
      };

      print('正在发送登录请求...');

      final uri = Uri.parse(loginUrl).replace(
        queryParameters: {'service': serviceUrl},
      );

      // 发送登录请求
      final response = await _dio.post(
        uri.toString(),
        data: loginData,
        options: Options(
          headers: {
            'Cookie': _buildCookieString(_cookies),
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      // 处理登录响应
      if (response.statusCode == 302 || response.statusCode == 200) {
        print('正在处理登录重定向...');

        // 提取SSO Cookies
        final ssoCookies = _extractCookies(response.headers.map);
        _updateCookies(ssoCookies);

        // 如果有重定向，跟随重定向获取edu cookies
        String eduCookieString = '';
        final location = response.headers.value('location');
        if (location != null) {
          final redirectUri = Uri.parse(location);
          final redirectResponse = await _dio.get(
            redirectUri.toString(),
            options: Options(
              headers: {'Cookie': _buildCookieString(_cookies)},
            ),
          );

          final eduCookies = _extractCookies(redirectResponse.headers.map);
          if (eduCookies.isNotEmpty) {
            _updateCookies(eduCookies);
            eduCookieString = _buildCookieString(eduCookies);
          }
        }

        return LoginTokenModel(
          eduCookie: eduCookieString,
          ssoCookie: _buildCookieString(ssoCookies),
          success: true,
          message: '登录成功',
        );
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        return LoginTokenModel(
          success: false,
          message: '登录失败：账号或密码错误',
        );
      } else {
        // 解析错误信息
        final document = html_parser.parse(response.data);
        final errorMsg = document.querySelector('span#msg');

        if (errorMsg != null) {
          return LoginTokenModel(
            success: false,
            message: '登录失败：${errorMsg.text}',
          );
        } else {
          return LoginTokenModel(
            success: false,
            message: '登录失败：未知错误',
          );
        }
      }
    } catch (e) {
      return LoginTokenModel(
        success: false,
        message: '登录出错：$e',
      );
    }
  }

  /// 从SSO登录
  Future<LoginTokenModel> loginFromSSO(String ssoKey) async {
    try {
      final uri = Uri.parse(loginUrl).replace(
        queryParameters: {'service': serviceUrl},
      );

      final response = await _dio.get(
        uri.toString(),
        options: Options(
          headers: {'Cookie': ssoKey},
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode != 200) {
        return LoginTokenModel(
          success: false,
          message: 'SSO登录失败：${response.statusMessage}',
        );
      }

      // 获取edu cookie
      final eduCookies = _extractCookies(response.headers.map);
      if (eduCookies.isNotEmpty) {
        _updateCookies(eduCookies);
      }

      final eduCookieString = _buildCookieString(eduCookies);
      print('SSO登录成功，获取eduCookie');

      return LoginTokenModel(
        eduCookie: eduCookieString,
        ssoCookie: ssoKey,
        success: true,
        message: '登录成功',
      );
    } catch (e) {
      return LoginTokenModel(
        success: false,
        message: 'SSO登录出错：$e',
      );
    }
  }

  /// 清理资源
  void dispose() {
    _dio.close();
  }

  // 测试辅助方法 - 仅为测试目的暴露私有方法
  String randomStringTest(int length) => _randomString(length);
  String buildCookieStringTest(Map<String, String> cookies) => _buildCookieString(cookies);
}

// 使用示例
void main() async {
  final loginClient = XAUATLogin();

  // 示例1：使用账号密码登录
  final result = await loginClient.login('2211030217', 'LIjiajun123456');

  if (result.success) {
    print('登录成功！');
    print('EDU Cookie: ${result.eduCookie}');
    print('SSO Cookie: ${result.ssoCookie}');
  } else {
    print('登录失败: ${result.message}');
  }

  // 示例2：使用SSO Cookie登录
  // final ssoResult = await loginClient.loginFromSSO('已有的SSO Cookie字符串');

  // 清理资源
  loginClient.dispose();
}