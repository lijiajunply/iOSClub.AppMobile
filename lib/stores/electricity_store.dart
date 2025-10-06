import 'package:get/get.dart';
import 'package:ios_club_app/services/tile_service.dart';
import 'package:ios_club_app/pageModels/electric_data.dart';

class ElectricityStore extends GetxController {
  // 响应式状态变量
  final RxBool isLoading = true.obs;
  final RxBool hasData = false.obs;
  final RxDouble electricity = 0.0.obs;
  final RxList<String> tiles = <String>[].obs;
  final RxList<ElectricData> weeklyData = <ElectricData>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadElectricityData();
  }

  Future<void> loadElectricityData() async {
    try {
      isLoading.value = true;
      
      final value = await TileService.getTextAfterKeyword();
      final tilesList = await TileService.getTiles();
      final weekly = await TileService.getElectricityWeeklyData();

      if (value != null) {
        electricity.value = value;
        hasData.value = true;
      }
      
      tiles.assignAll(tilesList);
      weeklyData.assignAll(weekly);
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshElectricityData() async {
    try {
      isLoading.value = true;
      
      final value = await TileService.getTextAfterKeyword();
      final weekly = await TileService.getElectricityWeeklyData();

      if (value != null) {
        electricity.value = value;
        hasData.value = true;
      }
      
      weeklyData.assignAll(weekly);
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setTiles(List<String> newTiles) async {
    tiles.assignAll(newTiles);
    await TileService.setTiles(newTiles);
  }

  void toggleTile(String tileName, bool value) {
    if (value) {
      if (!tiles.contains(tileName)) {
        tiles.add(tileName);
      }
    } else {
      tiles.remove(tileName);
    }
  }
}