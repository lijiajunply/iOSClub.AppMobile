import 'package:get/get.dart';
import 'user_store.dart';
import 'course_store.dart';
import 'schedule_store.dart';
import 'settings_store.dart';

/// 初始化所有 Store
void initStores() {
  Get.put(UserStore());
  Get.put(CourseStore());
  Get.put(ScheduleStore());
  Get.put(SettingsStore());
}

/// 释放所有 Store
void disposeStores() {
  Get.delete<UserStore>();
  Get.delete<CourseStore>();
  Get.delete<ScheduleStore>();
  Get.delete<SettingsStore>();
}
