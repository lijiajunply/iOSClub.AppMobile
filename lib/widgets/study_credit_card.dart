import 'package:flutter/material.dart';
import 'package:ios_club_app/Models/InfoModel.dart';

class StudyCreditCard extends StatelessWidget {
  final InfoModel data;

  const StudyCreditCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题部分
            Text(
              data.type,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // 总学分部分
            _buildCreditSection(
              title: data.total.name,
              actual: data.total.actual,
              full: data.total.full,
            ),

            const SizedBox(height: 20),

            // 分项列表
            Text(
              "分项学分",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),

            ...data.other.map((item) => _buildCreditSection(
                  title: item.name,
                  actual: item.actual,
                  full: item.full,
                )),
          ],
        ),
      ),
    );
  }

  // 学分卡片构建器
  Widget _buildCreditSection({
    required String title,
    required double actual,
    required double full,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          Text(
            "${actual.toStringAsFixed(1)} / ${full.toStringAsFixed(1)}",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
