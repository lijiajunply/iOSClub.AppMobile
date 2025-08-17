import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PaymentModel {
  final String turnoverType;
  final int datetime;
  final String datetimeStr;
  final String resume;
  final int tranamt;

  PaymentModel({
    required this.turnoverType,
    required this.datetime,
    required this.datetimeStr,
    required this.resume,
    required this.tranamt,
  });

  @override
  String toString() {
    return '$datetimeStr | $turnoverType | ${(tranamt / 100).toStringAsFixed(2)} 元 | ${resume.trim()}';
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      turnoverType: json['turnoverType'],
      datetime: int.parse(json['datetime'] ?? '0'),
      datetimeStr: json['jndatetimeStr'],
      resume: json['resume'],
      tranamt: json['tranamt'],
    );
  }
}

class TurnoverAnalyzer {
  final String url =
      'http://ydfwpt.xauat.edu.cn/berserker-search/search/personal/turnover';
  final Map<String, String> params = {
    'size': '8',
    'current': '1',
    'synAccessSource': 'wechat-work'
  };
  Map<String, String> headers = {'synAccessSource': 'wechat-work'};

  late List<PaymentModel> records;

  TurnoverAnalyzer(String token) {
    headers.addAll({'synjones-auth': token});
  }

  Future<bool> fetchData() async {
    final uri = Uri.parse(url).replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final dataPart = data['data'] as Map<String, dynamic>?;
      final a =
          (dataPart?['records'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      records = a.map((record) => PaymentModel.fromJson(record)).toList();
      return true;
    } else {
      if (kDebugMode) {
        print('请求失败，状态码: ${response.statusCode}');
      }
      return false;
    }
  }
}
