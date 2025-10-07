import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prefs_keys.dart';

class SettingsStore extends GetxController {
  static SettingsStore get to => Get.find();

  // 课程通知设置
  final _isRemind = false.obs;
  final _remindTime = 15.obs;

  // 明日课程显示设置
  final _isShowTomorrow = false.obs;

  // 待办事项同步设置
  final _isUpdateToClub = false.obs;

  // 主页设置
  final _pageIndex = 0.obs;

  // 触觉反馈设置
  final _enableHapticFeedback = false.obs;
  
  // 忽略更新设置
  final _updateIgnored = false.obs;

  bool get isRemind => _isRemind.value;

  int get remindTime => _remindTime.value;

  bool get isShowTomorrow => _isShowTomorrow.value;

  bool get isUpdateToClub => _isUpdateToClub.value;

  int get pageIndex => _pageIndex.value;

  bool get enableHapticFeedback => _enableHapticFeedback.value;
  
  bool get updateIgnored => _updateIgnored.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// 加载所有设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isRemind.value = prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
    _remindTime.value = prefs.getInt(PrefsKeys.NOTIFICATION_TIME) ?? 15;
    _isShowTomorrow.value = prefs.getBool(PrefsKeys.IS_SHOW_TOMORROW) ?? false;
    _isUpdateToClub.value = prefs.getBool(PrefsKeys.IS_UPDATE_CLUB) ?? false;
    _pageIndex.value = prefs.getInt(PrefsKeys.PAGE_DATA) ?? 0;
    _enableHapticFeedback.value = prefs.getBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK) ?? false;
    _updateIgnored.value = prefs.getBool(PrefsKeys.UPDATE_IGNORED) ?? false;
  }

  /// 设置课程通知开关
  Future<void> setIsRemind(bool value) async {
    _isRemind.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.IS_REMIND, value);
  }

  /// 设置提醒时间
  Future<void> setRemindTime(int value) async {
    _remindTime.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.NOTIFICATION_TIME, value);
  }

  /// 设置是否显示明日课程
  Future<void> setIsShowTomorrow(bool value) async {
    _isShowTomorrow.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.IS_SHOW_TOMORROW, value);
  }

  /// 设置是否同步待办事项到社团
  Future<void> setIsUpdateToClub(bool value) async {
    _isUpdateToClub.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.IS_UPDATE_CLUB, value);
  }

  /// 设置主页索引
  Future<void> setPageIndex(int value) async {
    _pageIndex.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.PAGE_DATA, value);
  }

  /// 设置是否启用触觉反馈
  Future<void> setEnableHapticFeedback(bool value) async {
    _enableHapticFeedback.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK, value);
  }
  
  /// 设置是否忽略更新
  Future<void> setUpdateIgnored(bool value) async {
    _updateIgnored.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.UPDATE_IGNORED, value);
  }
}