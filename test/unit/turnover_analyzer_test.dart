import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/services/payment_analyzer.dart';

void main() {
  group('PaymentModel', () {
    test('should create instance with provided values', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '食堂午餐',
        amount: 15.50,
      );

      expect(payment.turnoverType, '消费');
      expect(payment.datetimeStr, '2023-01-01 12:00:00');
      expect(payment.resume, '食堂午餐');
      expect(payment.amount, 15.50);
    });

    test('should create instance from JSON', () {
      final json = {
        'turnoverType': '充值',
        'datetimeStr': '2023-01-01 10:00:00',
        'resume': '支付宝充值',
        'tranamt': 100,
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.turnoverType, '充值');
      expect(payment.datetimeStr, '2023-01-01 10:00:00');
      expect(payment.resume, '支付宝充值');
      expect(payment.amount, 100.0);
    });

    test('should format toString correctly', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '食堂午餐  ',
        amount: 15.50,
      );

      expect(
        payment.toString(),
        '2023-01-01 12:00:00 | 消费 | 0.15 元 | 食堂午餐',
      );
    });
  });

  group('PaymentData', () {
    test('should create instance with provided values', () {
      final payments = [
        PaymentModel(
          turnoverType: '消费',
          datetimeStr: '2023-01-01 12:00:00',
          resume: '食堂午餐',
          amount: 15.50,
        )
      ];
      final paymentData = PaymentData(payments, 100.0);

      expect(paymentData.payments, payments);
      expect(paymentData.total, 100.0);
    });

    test('should create instance from JSON', () {
      final json = {
        'records': [
          {
            'turnoverType': '消费',
            'datetimeStr': '2023-01-01 12:00:00',
            'resume': '食堂午餐',
            'tranamt': 15.50,
          }
        ],
        'total': 100.0,
      };

      final paymentData = PaymentData.fromJson(json);

      expect(paymentData.payments, isNotEmpty);
      expect(paymentData.payments.length, 1);
      expect(paymentData.payments[0].turnoverType, '消费');
      expect(paymentData.total, 100.0);
    });
  });
}