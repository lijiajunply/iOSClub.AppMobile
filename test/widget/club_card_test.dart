import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/widgets/club_card.dart';

void main() {
  group('ClubCard', () {
    testWidgets('should display child widget', (WidgetTester tester) async {
      const childText = '测试内容';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubCard(
              child: Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('should apply custom margin', (WidgetTester tester) async {
      const margin = EdgeInsets.all(16.0);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubCard(
              margin: margin,
              child: Text('测试'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((Widget widget) {
        return widget is Container && widget.margin == margin;
      });

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should apply custom padding', (WidgetTester tester) async {
      const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubCard(
              padding: padding,
              child: Text('测试'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((Widget widget) {
        return widget is Container && widget.padding == padding;
      });

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should have rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubCard(
              child: Text('测试'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((Widget widget) {
        return widget is Container && 
               widget.decoration is BoxDecoration &&
               (widget.decoration as BoxDecoration).borderRadius != null;
      });

      expect(containerFinder, findsOneWidget);
    });
  });
}