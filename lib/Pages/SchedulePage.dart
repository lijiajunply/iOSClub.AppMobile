import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/CourseColorManager.dart';
import '../Models/CourseModel.dart';
import '../Services/DataService.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<CourseModel> courses = [];
  int week = 0;
  int maxWeek = 0;
  int weekNow = 0;

  Future<void> fetchData(int weekChange) async {
    if (weekChange < 0 || weekChange > maxWeek) {
      return;
    }
    final dataService = DataService();
    final allCourse = await dataService.getCourseByWeek(week: weekChange);

    setState(() {
      week = weekChange;
      courses.clear();
      courses.addAll(allCourse);
    });
  }

  @override
  void initState() {
    super.initState();
    final dataService = DataService();
    dataService.getCourseByWeek().then((value) {
      setState(() {
        courses.addAll(value);
      });
    });
    dataService.getWeek().then((value) {
      setState(() {
        week = value['week']!;
        weekNow = value['week']!;
        maxWeek = value['maxWeek']!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  await fetchData(week - 1);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: Text(week == 0 ? '' : '上一周'),
              ),
              Text(
                week == 0
                    ? '全部课表'
                    : '第 $week 周 ${week == weekNow ? "(本周)" : ""}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () async {
                  await fetchData(week + 1);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: Text(week >= maxWeek ? '' : '下一周'),
              ),
            ],
          ),
          _buildWeekHeader(),
          Expanded(
            child: SingleChildScrollView(
              // 添加垂直方向的滚动
              scrollDirection: Axis.vertical,
              child: SizedBox(
                // 设置固定高度确保内容可以完整显示
                height: 60.0 * 12, // 12节课的总高度
                child: _buildScheduleGrid(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
    final weekDays = [];
    final a = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    final now = DateTime.now();
    final w = now.subtract(Duration(days: now.weekday + (weekNow - week) * 7));
    for (int i = 0; i < 7; i++) {
      weekDays.add(
          '${a[i]} ${DateFormat('MM/dd').format(w.add(Duration(days: i)))}');
    }
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          _buildTimeCell(''),
          ...weekDays.map((day) => Expanded(
                child: Center(child: Text(day)),
              )),
        ],
      ),
    );
  }

  Widget _buildScheduleGrid() {
    return Row(
      children: [
        _buildTimeLine(),
        ...List.generate(7, (index) => _buildDayColumn(index)),
      ],
    );
  }

  Widget _buildTimeLine() {
    return Column(
      children: List.generate(
        12,
        (index) => SizedBox(
          height: 60,
          width: 50,
          child: Center(child: Text('${index + 1}')),
        ),
      ),
    );
  }

  Widget _buildDayColumn(int weekDay) {
    return Expanded(
      child: Stack(
        children: [
          Column(
            children: List.generate(
              12,
              (index) => Container(
                height: 60,
              ),
            ),
          ),
          ...courses
              .where((course) => course.weekday == weekDay)
              .map((course) => _buildCourseCard(course)),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;
    return Positioned(
        top: (course.startUnit - 1) * 60.0,
        left: 0,
        right: 0,
        height: (course.endUnit - course.startUnit + 1) * 60.0,
        child: GestureDetector(
          onTap: () async {
            await _showModalBottomSheet(course);
          },
          child: Card(
            margin: const EdgeInsets.all(2),
            color: CourseColorManager.generateSoftColor(course.courseName),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 8 : 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    course.room,
                    style: const TextStyle(
                      fontSize: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    course.teachers.join(', '),
                    style: const TextStyle(
                      fontSize: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildTimeCell(String text) {
    return SizedBox(
      width: 50,
      child: Center(child: Text(text)),
    );
  }

  Future<void> _showModalBottomSheet(CourseModel course) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    var content = Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.courseName,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox.fromSize(size: const Size(double.infinity, 10)),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  course.room,
                  style: const TextStyle(
                    fontSize: 17,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox.fromSize(size: const Size(double.infinity, 10)),
            Row(children: [
              const Icon(
                Icons.person,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 4),
              Text(
                course.teachers.join(', '),
                style: const TextStyle(
                  fontSize: 17,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
            SizedBox.fromSize(size: const Size(double.infinity, 10)),
            Row(children: [
              const Icon(
                Icons.calendar_today,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                '${course.weekIndexes.first}-${course.weekIndexes.last}周 每周${course.weekday} 第${course.startUnit}节~第${course.endUnit}节',
                style: const TextStyle(
                  fontSize: 17,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],
        ));

    if (isTablet) {
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[content],
            );
          });
    }

    final a = MediaQuery.of(context).size.width;

    return showModalBottomSheet<void>(
        context: context,
        constraints: BoxConstraints(maxWidth: a, minWidth: a),
        builder: (BuildContext context) {
          return content;
        });
  }
}
