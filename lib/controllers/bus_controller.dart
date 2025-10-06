import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/models/bus_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/net/edu_service.dart';
import 'package:ios_club_app/net/new_bus_api.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';

class BusController extends GetxController with GetSingleTickerProviderStateMixin {
  // Observable variables
  var selectedDate = ''.obs;
  var busData = <BusItem>[].obs;
  var todayBusData = <BusItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isCaoTang = true.obs;
  var isShowBus = false.obs;
  var useNewApi = false.obs;
  var tiles = <String>[].obs;

  late TabController tabController;
  final Map<String, String> availableDates = {};

  @override
  void onInit() {
    super.onInit();
    _generateWeeklyDates();
    tabController = TabController(length: 7, vsync: this);
    tabController.addListener(_handleTabSelection);
    selectedDate.value = availableDates.isNotEmpty ? availableDates.keys.first : '';
    if (selectedDate.isNotEmpty) _fetchBusData(isInit: true);
    _loadTiles();
  }

  void _generateWeeklyDates() {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      availableDates[DateFormat('yyyy-MM-dd').format(date)] =
          DateFormat('M月d日').format(date);
    }
  }

  void _handleTabSelection() async {
    if (tabController.indexIsChanging) {
      selectedDate.value = availableDates.keys.elementAt(tabController.index);
      await _fetchBusData();
    }
  }

  Future<void> _loadTiles() async {
    final prefs = await SharedPreferences.getInstance();
    tiles.assignAll(prefs.getStringList(PrefsKeys.TILES) ?? []);
    isShowBus.value = tiles.contains('校车');
  }

  Future<void> _fetchBusData({bool isInit = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (isInit) {
        final prefs = await SharedPreferences.getInstance();
        useNewApi.value = prefs.getBool(PrefsKeys.USE_NEW_BUS_API) ?? false;
      }

      BusModel data = BusModel(records: [], total: 0);
      if (useNewApi.value) {
        data = await getBusFromNewData(time: selectedDate.value, loc: 'ALL');
      } else {
        data = await EduService.getBus(dayDate: selectedDate.value);
      }

      todayBusData.assignAll(data.records);
      if (isCaoTang.value) {
        busData.assignAll(
            todayBusData.where((bus) => bus.lineName.startsWith('草堂')).toList());
      } else {
        busData.assignAll(
            todayBusData.where((bus) => bus.lineName.startsWith('雁塔')).toList());
      }
    } catch (e) {
      errorMessage.value = '获取校车数据时出错: $e';
      busData.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleCampus() {
    isCaoTang.toggle();
    if (isCaoTang.value) {
      busData.assignAll(
          todayBusData.where((bus) => bus.lineName.startsWith("草堂")).toList());
    } else {
      busData.assignAll(
          todayBusData.where((bus) => bus.lineName.startsWith("雁塔")).toList());
    }
  }

  void refreshData() {
    _fetchBusData();
  }

  void toggleShowBus(bool value) async {
    isShowBus.value = value;
    if (isShowBus.value) {
      if (!tiles.contains("校车")) {
        tiles.add("校车");
      }
    } else {
      tiles.remove("校车");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(PrefsKeys.TILES, tiles);
  }

  void toggleUseNewApi(bool value) async {
    useNewApi.value = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.USE_NEW_BUS_API, useNewApi.value);

    // 切换API后重新获取数据
    _fetchBusData();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}