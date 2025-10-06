import 'package:get/get.dart';
import 'bus_tile_store.dart';
import 'payment_store.dart';
import 'user_store.dart';
import 'course_store.dart';
import 'schedule_store.dart';
import 'settings_store.dart';
import 'electricity_store.dart';

/// 初始化所有 Store
void initStores() {
  Get.put(UserStore());
  Get.put(CourseStore());
  Get.put(ScheduleStore());
  Get.put(SettingsStore());
  Get.put(ElectricityStore());
  Get.put(PaymentStore());
  Get.put(BusTileStore());
}

/// 释放所有 Store
void disposeStores() {
  Get.delete<UserStore>();
  Get.delete<CourseStore>();
  Get.delete<ScheduleStore>();
  Get.delete<SettingsStore>();
  Get.delete<ElectricityStore>();
  Get.delete<PaymentStore>();
  Get.delete<BusTileStore>();
}
