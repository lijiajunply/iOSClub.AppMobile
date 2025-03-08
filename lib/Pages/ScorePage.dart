import 'package:flutter/material.dart';
import 'package:ios_club_app/Models/CourseColorManager.dart';

import '../Models/ScoreModel.dart';
import '../Services/DataService.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  final List<ScoreList> scoreList = [];

  @override
  initState() {
    super.initState();
    final dataService = DataService();
    dataService.getScore().then((value) {
      setState(() {
        scoreList.clear();
        scoreList.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: scoreList.length,
        itemBuilder: (context, index) {
          final score = scoreList[index];
          final semesterNames = score.semester.name.split('-');
          return Card(
            margin:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            elevation: 4,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Text(
                      '${semesterNames[0]}至${semesterNames[1]}年 第${semesterNames[2]}学期',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  ...score.list.map((item) => _buildScheduleItem(item))
                ])),
          );
        });
  }

  Widget _buildScheduleItem(ScoreModel item) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: CourseColorManager.generateSoftColor(item.name),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Column(
                  // 添加居中对齐 ,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // 添加左对齐
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // 为课程名也添加省略
                      maxLines: 1, // 限制为单行
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${item.credit}学分',
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 16),
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('成绩 ${item.grade}',
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 16),
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('绩点 ${item.gpa}',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                )),
                if (isTablet)
                  Expanded(
                    // 用 Expanded 包裹以限制宽度
                    child: Text(
                      item.gradeDetail,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1, // 限制为单行
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
