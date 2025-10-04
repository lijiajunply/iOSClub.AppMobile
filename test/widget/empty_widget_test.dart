import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/widgets/empty_widget.dart';

void main() {
  group('EmptyWidget', () {
    testWidgets('should display title and subtitle', (WidgetTester tester) async {
      const title = '暂无数据';
      const subtitle = '这里什么都没有';
      const icon = Icons.inbox;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyWidget(
              title: title,
              subtitle: subtitle,
              icon: icon,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('should display icon with circle background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyWidget(
              title: '测试',
              subtitle: '测试副标题',
              icon: Icons.home,
            ),
          ),
        ),
      );

      // 查找包含图标的容器
      final iconContainer = find.byWidgetPredicate((Widget widget) {
        return widget is Container && 
               widget.decoration is BoxDecoration &&
               (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
               widget.child is Icon;
      });

      expect(iconContainer, findsOneWidget);
    });

    testWidgets('should not display subtitle when it is empty', (WidgetTester tester) async {
      const emptySubtitle = '';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyWidget(
              title: '测试标题',
              subtitle: emptySubtitle,
              icon: Icons.home,
            ),
          ),
        ),
      );

      // 确保副标题小部件不存在
      expect(find.byWidgetPredicate((Widget widget) {
        return widget is Text && widget.data == emptySubtitle;
      }), findsNothing);
    });
  });
}