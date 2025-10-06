import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../Services/edu_service.dart';
import '../models/bus_model.dart';

/// 新数据平台
///
/// [loc] All,雁塔,草堂
Future<BusModel> getBusFromNewData({
  String? time,
  String loc = '雁塔',
}) async {
  final dio = Dio();

  // 配置dio实例
  dio.options = BaseOptions(
    baseUrl: 'https://bcdd.xauat.edu.cn',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  try {
    // 设置默认时间
    time ??=
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

    // 发起POST请求
    final response = await dio.post(
      '/api/openapi/getDayBusPlans',
      data: {
        'type': loc,
        'nowDay': time,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('请求失败: ${response.statusCode}');
    }

    final jsonData = response.data;
    // 添加空值检查
    if (jsonData == null || jsonData['data'] == null) {
      return BusModel(records: [], total: 0);
    }
    
    final data = jsonData['data'];
    final dfBusPlans = data['dfBusPlans'] as List<dynamic>?;

    // 如果没有数据，调用旧数据接口
    if (dfBusPlans == null || dfBusPlans.isEmpty) {
      return await EduService.getBus(dayDate: time);
    }

    // 处理数据
    final records = <BusItem>[];

    for (final j in dfBusPlans) {
      // 处理包含frcamp的数据 - 这表示途径站点
      String departure = '${j['fscamp']}校区';
      // 添加空值检查，确保frcamp字段存在且不为空
      if (j['frcamp'] != null && (j['frcamp'] as String).isNotEmpty) {
        departure = '${j['frcamp']}校区';
      }

      // 添加空值检查
      final fecamp = j['fecamp'];
      if (fecamp == null) {
        continue; // 跳过当前循环，避免空值错误
      }
      final arrival = '$fecamp校区';
      
      // 添加fstime字段的空值检查
      final fstime = j['fstime'];
      if (fstime == null) {
        continue; // 跳过当前循环，避免空值错误
      }
      
      final timestamp = int.parse(fstime.toString()) * 10000;

      // 计算时间（考虑时区）
      final tricks1970 =
          DateTime(1970, 1, 1, 8, 0, 0).millisecondsSinceEpoch * 10000;
      final timeTricks = tricks1970 + timestamp;

      final runTime = DateTime.fromMillisecondsSinceEpoch(timeTricks ~/ 10000);
      final formattedTime = '${runTime.hour.toString().padLeft(2, '0')}:${runTime.minute.toString().padLeft(2, '0')}';

      // 添加fbusNo字段的空值检查
      final fbusNo = j['fbusNo'];
      final busNo = fbusNo?.toString() ?? '';

      records.add(BusItem(
        lineName: '$departure→$arrival',
        description: busNo,
        departureStation: departure,
        arrivalStation: arrival,
        runTime: formattedTime,
        arrivalStationTime: '01:30',
      ));
    }

    return BusModel(records: records, total: records.length);
  } catch (e) {
    // 发生错误时返回空数据或调用备用接口
    debugPrint('获取班车数据失败: $e');
    return BusModel(records: [], total: 0);
  }
}