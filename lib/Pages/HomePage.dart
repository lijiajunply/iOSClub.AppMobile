import 'package:flutter/material.dart';
import 'package:ios_club_app/Widgets/ExamCard.dart';
import '../Widgets/ScheduleCard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 课表部分
          SliverPersistentHeader(
            pinned: true, // 设置为true使其具有粘性
            delegate: _SliverHeaderDelegate(
              title: '今日课表',
              minHeight: 66,
              maxHeight: 80,
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: ScheduleCard(),
            ),
          ),
          // 考试列表
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              title: '近期考试',
              minHeight: 66,
              maxHeight: 80,
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: ExamCard(),
            ),
          ),
        ],
      ),
    );
  }
}

// 自定义 SliverPersistentHeaderDelegate
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({
    required this.title,
    required this.minHeight,
    required this.maxHeight,
  });

  final String title;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return title != oldDelegate.title ||
        minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight;
  }
}
