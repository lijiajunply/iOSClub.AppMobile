import 'package:get/get.dart';
import 'package:ios_club_app/system_services/tile_service.dart';
import 'package:ios_club_app/services/turnover_analyzer.dart';

class PaymentStore extends GetxController {
  // 响应式状态变量
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<PaymentModel> records = <PaymentModel>[].obs;
  final RxList<String> tiles = <String>[].obs;
  final RxDouble totalRecharge = 0.0.obs;
  final RxString num = ''.obs;
  final RxBool isShowTile = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      num.value = await TurnoverAnalyzer.getPayment();

      if (num.value.isEmpty) {
        errorMessage.value = '请先绑定饭卡';
        return;
      }

      final recordsResult = await TurnoverAnalyzer.fetchData(num.value);
      final newTiles = await TileService.getTiles();

      if (recordsResult.payments.isNotEmpty) {
        records.assignAll(recordsResult.payments);
        totalRecharge.value = recordsResult.total;
        tiles.assignAll(newTiles);
        isShowTile.value = tiles.contains("饭卡");
      } else {
        errorMessage.value = '数据加载失败';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setPayment(String cardNumber) async {
    await TurnoverAnalyzer.setPayment(cardNumber);
    await loadData();
  }

  void toggleTileShow(bool value) {
    isShowTile.value = value;
    if (value) {
      tiles.add("饭卡");
    } else {
      tiles.remove("饭卡");
    }
    TileService.setTiles(tiles);
  }
}