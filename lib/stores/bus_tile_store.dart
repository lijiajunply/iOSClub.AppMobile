import 'package:get/get.dart';
import 'package:ios_club_app/models/bus_model.dart';
import 'package:ios_club_app/net/edu_service.dart';
import 'package:ios_club_app/net/new_bus_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';

class BusTileStore extends GetxController {
  final RxBool isLoading = true.obs;
  final RxInt busCount = 0.obs;
  final Rx<BusModel> busData = BusModel(records: [], total: 0).obs;
  final RxBool useNewApi = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBusData();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    useNewApi.value = prefs.getBool(PrefsKeys.USE_NEW_BUS_API) ?? false;
  }

  Future<void> loadBusData() async {
    try {
      isLoading.value = true;

      // 加载API偏好设置
      await loadPreferences();

      BusModel data;
      if (useNewApi.value) {
        // 使用新API
        data = await getBusFromNewData(loc: 'ALL');
      } else {
        // 使用旧API
        data = await EduService.getBus();
      }

      busData.value = data;
      busCount.value = data.total;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBusData() async {
    await loadBusData();
  }

  Future<void> toggleUseNewApi(bool value) async {
    useNewApi.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.USE_NEW_BUS_API, useNewApi.value);
    await loadBusData(); // 切换后重新加载数据
  }
}