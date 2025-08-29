import 'package:flutter/material.dart';

import '../widgets/homePages/exam_card.dart';
import '../widgets/homePages/schedule_widget.dart';
import '../widgets/homePages/tiles_widget.dart';
import '../widgets/homePages/todo_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 250;
    final list = <Widget>[
      ScheduleWidget(),
      TilesWidget(),
      // 考试列表
      ExamCard(),
      // 待办事项
      TodoWidget()
    ];
    return Scaffold(
        body: SingleChildScrollView(
            child: (width < 600)
                ? Column(children: list)
                : Wrap(
                children: List.generate(
                    list.length,
                        (index) => SizedBox(
                        width: width > 750
                            ? (((width) /
                            ((index + 1) % 4 < 2 ? 3 : (1.5))))
                            : ((width) / 2),
                        child: list[index])))));
  }
}
