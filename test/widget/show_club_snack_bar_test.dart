import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/widgets/show_club_snack_bar.dart';

void main() {
  group('showClubSnackBar', () {
    testWidgets('should show SnackBar with provided child widget', (WidgetTester tester) async {
      const testText = '测试消息';
      var snackBarShown = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showClubSnackBar(
                      context,
                      const Text(testText),
                    );
                    snackBarShown = true;
                  },
                  child: const Text('显示 SnackBar'),
                );
              },
            ),
          ),
        ),
      );

      // 点击按钮触发 SnackBar
      await tester.tap(find.text('显示 SnackBar'));
      await tester.pump();

      // 验证 SnackBar 已显示
      expect(snackBarShown, true);
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should show SnackBar with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showClubSnackBar(
                      context,
                      const Text('测试'),
                    );
                  },
                  child: const Text('显示 SnackBar'),
                );
              },
            ),
          ),
        ),
      );

      // 点击按钮触发 SnackBar
      await tester.tap(find.text('显示 SnackBar'));
      await tester.pumpAndSettle();

      // 验证 SnackBar 的行为和形状
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.duration, const Duration(seconds: 2));
      expect(snackBar.shape, isA<RoundedRectangleBorder>());
    });
  });
}