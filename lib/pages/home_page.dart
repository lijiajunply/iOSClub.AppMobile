import 'package:flutter/material.dart';
import 'package:ios_club_app/widgets/homePages/exam_card.dart';
import '../widgets/homePages/schedule_widget.dart';
import '../widgets/homePages/tiles_widget.dart';
import '../widgets/homePages/todo_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          // 课表部分
          ScheduleWidget(),
          TilesWidget(),
          // 考试列表
          ExamCard(),
          // 待办事项
          TodoWidget(),
        ],
      ),
    ));
  }
}
