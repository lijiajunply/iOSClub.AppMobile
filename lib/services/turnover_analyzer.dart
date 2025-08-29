import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentData {
  final List<PaymentModel> payments;
  final double total;

  PaymentData(this.payments, this.total);

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      (json['records'] as List).map((e) => PaymentModel.fromJson(e)).toList(),
      (json['total'] as num).toDouble(),
    );
  }
}

class PaymentModel {
  final String turnoverType;
  final String datetimeStr;
  final String resume;
  final double tranamt;

  PaymentModel({
    required this.turnoverType,
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
      datetimeStr: json['datetimeStr'],
      resume: json['resume'],
      tranamt: (json['tranamt'] as num).toDouble(),
    );
  }
}

class TurnoverAnalyzer {
  static Future<PaymentData> getData() async {
    final cardId = await TurnoverAnalyzer.getPayment();
    if (cardId.isEmpty) {
      return PaymentData([], 0);
    }
    final response = await http
        .get(Uri.parse('https://xauatapi.xauat.site/Payment/$cardId/turnover'));
    if (response.statusCode == 200) {
      var a = jsonDecode(response.body);
      return PaymentData.fromJson(a);
    }

    return PaymentData([], 0);
  }

  static Future<PaymentData> fetchData(String cardId) async {
    final response = await http
        .get(Uri.parse('https://xauatapi.xauat.site/Payment/$cardId/turnover'));
    if (response.statusCode == 200) {
      var a = jsonDecode(response.body);
      return PaymentData.fromJson(a);
    }

    return PaymentData([], 0);
  }

  static Future<void> setPayment(String a) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_num', a);
  }

  static Future<String> getPayment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('payment_num') ?? '';
  }
}
