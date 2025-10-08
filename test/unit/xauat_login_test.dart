import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/net/xauat_login.dart';

void main() {
  group('XAUATLogin', () {
    late XAUATLogin xauatLogin;

    setUp(() {
      xauatLogin = XAUATLogin();
    });

    tearDown(() {
      xauatLogin.dispose();
    });

    test('should create instance', () {
      expect(xauatLogin, isNotNull);
    });

    test('should create LoginTokenModel with default values', () {
      final token = LoginTokenModel();
      
      expect(token.eduCookie, '');
      expect(token.ssoCookie, '');
      expect(token.success, true);
      expect(token.message, '');
    });

    test('should create LoginTokenModel with provided values', () {
      final token = LoginTokenModel(
        eduCookie: 'edu_cookie',
        ssoCookie: 'sso_cookie',
        success: false,
        message: 'error message',
      );
      
      expect(token.eduCookie, 'edu_cookie');
      expect(token.ssoCookie, 'sso_cookie');
      expect(token.success, false);
      expect(token.message, 'error message');
    });

    test('should convert LoginTokenModel to JSON', () {
      final token = LoginTokenModel(
        eduCookie: 'edu_cookie',
        ssoCookie: 'sso_cookie',
        success: false,
        message: 'error message',
      );
      
      final json = token.toJson();
      
      expect(json['eduCookie'], 'edu_cookie');
      expect(json['ssoCookie'], 'sso_cookie');
      expect(json['success'], false);
      expect(json['message'], 'error message');
    });

    test('_randomString should generate string with correct length', () {
      final randomString = xauatLogin.randomStringTest(10);
      expect(randomString.length, 10);
    });

    test('_buildCookieString should build correct cookie string', () {
      final cookies = <String, String>{
        'cookie1': 'value1',
        'cookie2': 'value2',
      };
      
      final cookieString = xauatLogin.buildCookieStringTest(cookies);
      // 顺序可能不同，所以我们需要检查是否包含这些值
      expect(cookieString, contains('cookie1=value1'));
      expect(cookieString, contains('cookie2=value2'));
      expect(cookieString, contains('; '));
    });
  });
}