import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/UserData.dart';
import 'prefs_keys.dart';

class UserStore extends GetxController {
  static UserStore get to => Get.find();

  final _isLogin = false.obs;
  final _userData = Rxn<UserData>();

  bool get isLogin => _isLogin.value;
  UserData? get userData => _userData.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  /// 加载用户数据
  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString(PrefsKeys.USER_DATA);
    
    if (userDataString != null) {
      try {
        final userDataMap = Map<String, dynamic>.from(
            jsonDecode(userDataString));
        final userData = UserData.fromJson(userDataMap);
        _userData.value = userData;
        _isLogin.value = true;
      } catch (e) {
        // 解析失败，清除数据
        await _clearUserData();
      }
    }
  }

  /// 设置用户数据
  Future<void> setUserData(UserData userData) async {
    _userData.value = userData;
    _isLogin.value = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.USER_DATA, jsonEncode({
      'studentId': userData.studentId,
      'cookie': userData.cookie,
    }));
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
}