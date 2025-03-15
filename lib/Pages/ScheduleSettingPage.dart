import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/DataService.dart';

class ScheduleSettingPage extends StatefulWidget {
  const ScheduleSettingPage({super.key});

  @override
  State<ScheduleSettingPage> createState() => _ScheduleSettingPageState();
}

class _ScheduleSettingPageState extends State<ScheduleSettingPage> {
  List<String> totalList = [];
  List<String> ignoreList = [];
  final List<CourseIgnore> _ignores = [];

  @override
  void initState() {
    super.initState();
    final data = DataService();
    data.getIgnore().then((value) {
      setState(() {
        ignoreList = value;
        data.getCourseName().then((value) {
          totalList = value;
          for (var i in totalList) {
            _ignores.add(CourseIgnore(
                title: i,
                isCompleted: ignoreList.isNotEmpty && ignoreList.any((x) => x == i)));
          }
        });
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('课程忽略设置'),
        ),
        body: Padding(
            padding: EdgeInsets.all(16),
            child: ListView.builder(
              // 禁用 ListView 自身的滚动
              itemCount: _ignores.length,
              itemBuilder: (context, index) {
                final todo = _ignores[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (value) {
                        setState(() {
                          todo.isCompleted = value!;
                        });
                        if (value!) {
                          ignoreList.add(todo.title);
                        } else {
                          ignoreList.remove(todo.title);
                        }
                        DataService().setIgnore(ignoreList);
                      },
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            )));
  }
}

class CourseIgnore {
  String title;
  bool isCompleted;

  CourseIgnore({required this.title, this.isCompleted = false});
}
