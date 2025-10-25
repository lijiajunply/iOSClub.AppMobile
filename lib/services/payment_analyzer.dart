import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';

/// 支付数据模型类
/// 包含支付记录列表和总金额
class PaymentData {
  /// 支付记录列表
  final List<PaymentModel> payments;
  
  /// 总金额
  final double total;

  /// 构造函数
  PaymentData(this.payments, this.total);

  /// 从JSON数据创建PaymentData实例
  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      (json['records'] as List).map((e) => PaymentModel.fromJson(e)).toList(),
      (json['total'] as num).toDouble(),
    );
  }
}

/// 单条支付记录模型类
///
/// 表示一条具体的支付记录信息
class PaymentModel {
  /// 交易类型
  final String turnoverType;
  
  /// 交易日期时间字符串
  final String datetimeStr;
  
  /// 交易摘要
  final String resume;
  
  /// 交易金额（分为单位）
  final double amount;

  /// 构造函数
  PaymentModel({
    required this.turnoverType,
    required this.datetimeStr,
    required this.resume,
    required this.amount,
  });

  /// 重写toString方法，格式化输出支付记录信息
  ///
  /// 格式：日期时间 | 交易类型 | 金额(元) | 摘要
  @override
  String toString() {
    return '$datetimeStr | $turnoverType | ${(amount / 100).toStringAsFixed(2)} 元 | ${resume.trim()}';
  }

  /// 从JSON数据创建PaymentModel实例
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      turnoverType: json['turnoverType'],
      datetimeStr: json['datetimeStr'],
      resume: json['resume'],
      amount: (json['tranamt'] as num).toDouble(),
    );
  }
}

/// 支付数据分析器类
///
/// 负责获取、存储和处理用户的支付数据
class PaymentAnalyzer {
  /// 获取支付数据
  /// 如果本地没有存储卡号，则返回空数据
  /// 否则从服务器获取该卡号对应的交易记录
  static Future<PaymentData> getData() async {
    final cardId = await PaymentAnalyzer.getPayment();
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

  /// 根据指定卡号获取支付数据
  ///
  /// [cardId] 卡号
  static Future<PaymentData> fetchData(String cardId) async {
    final response = await http
        .get(Uri.parse('https://xauatapi.xauat.site/Payment/$cardId/turnover'));
    if (response.statusCode == 200) {
      var a = jsonDecode(response.body);
      return PaymentData.fromJson(a);
    }

    return PaymentData([], 0);
  }

  /// 存储支付卡号到本地
  ///
  /// [a] 卡号
  static Future<void> setPayment(String a) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.PAYMENT_NUM, a);
  }

  /// 从本地获取已存储的支付卡号
  ///
  /// 返回存储的卡号，如果未存储则返回空字符串
  static Future<String> getPayment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefsKeys.PAYMENT_NUM) ?? '';
  }
}