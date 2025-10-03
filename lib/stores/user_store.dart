import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/models/user_data.dart';
import 'prefs_keys.dart';

class UserStore extends GetxController {
  static UserStore get to => Get.find();

  final _isLogin = false.obs;
  final _userData = Rxn<UserData>();
  final _isLoginMember = false.obs;

  bool get isLogin => _isLogin.value;

  bool get isLoginMember => _isLoginMember.value;

  UserData? get userData => _userData.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString(PrefsKeys.USER_DATA);
    final String? iosName = prefs.getString(PrefsKeys.MEMBER_DATA);

    if (userDataString != null) {
      try {
        final userDataMap =
            Map<String, dynamic>.from(jsonDecode(userDataString));
        final userData = UserData.fromJson(userDataMap);
        _userData.value = userData;
        if (userData.studentId.isEmpty ||
            userData.studentId == '/student/login') {
          prefs.remove(PrefsKeys.USER_DATA);
        } else {
          _isLogin.value = true;
        }
      } catch (e) {
        // 解析失败，清除数据
        await _clearUserData();
      }
    }

    _isLoginMember.value = iosName != null && iosName.isNotEmpty;
  }

  /// 设置用户数据
  Future<void> setUserData(UserData userData) async {
    _userData.value = userData;
    _isLogin.value = true;
  }

  Future<void> setLoginMember() async {
    _isLoginMember.value = true;
  }

  /// 清除用户数据
  Future<void> _clearUserData() async {
    _userData.value = null;
    _isLogin.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.USER_DATA);
  }

  /// 登出
  Future<void> logout() async {
    await _clearUserData();
  }

  /// 退出iMember登录
  Future<void> logoutMember() async {
    _isLoginMember.value = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.MEMBER_DATA);
    await prefs.remove(PrefsKeys.MEMBER_JWT);
    await prefs.remove(PrefsKeys.CLUB_NAME);
    await prefs.remove(PrefsKeys.CLUB_ID);
  }
}