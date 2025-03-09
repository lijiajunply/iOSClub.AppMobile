import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/CourseColorManager.dart';
import '../Models/CourseModel.dart';
import '../Services/DataService.dart';

class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({super.key});

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  final List<List<CourseModel>> allCourse = [];
  late int maxWeek = 0;
  late int weekNow = 0;
  late PageController pageController = PageController();

  void jumpToPage(int page) {
    if (page < 0) {
      page = maxWeek - 1;
    } else if (page > maxWeek) {
      page = 0;
    }
    pageController.jumpToPage(page);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    final dataService = DataService();
    dataService.getWeek().then((value) {
      setState(() {
        weekNow = value['week']!;
        maxWeek = value['maxWeek']!;
        pageController.jumpToPage(weekNow);
      });
      dataService.getAllCourse().then((value) {
        setState(() {
          for (var i = 0; i <= maxWeek; i++) {
            if (i == 0) {
              allCourse.add(value);
              continue;
            }
            allCourse.add(value
                .where((course) => course.weekIndexes.contains(i))
                .toList());
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        itemCount: allCourse.length,
        itemBuilder: (BuildContext context, int i) {
          final courses = allCourse[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(
                              child: TextButton(
                                  onPressed: () => jumpToPage(
                                      (pageController.page! - 1).ceil()),
                                  child: const Text('上一周'))),
                          Expanded(
                              child: Center(
                            child: Text(
                              i == 0
                                  ? '全部课表'
                                  : '第 $i 周 ${i == weekNow ? "(本周)" : ""}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          )),
                          Expanded(
                              child: TextButton(
                                  onPressed: () => jumpToPage(
                                      (pageController.page! + 1).ceil()),
                                  child: const Text('下一周'))),
                        ],
                      )
                    : Center(
                        child: Text(
                        i == 0
                            ? '全部课表'
                            : '第 $i 周 ${i == weekNow ? "(本周)" : ""}',
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
              ),
              _buildWeekHeader(i),
              Expanded(
                child: SingleChildScrollView(
                  // 添加垂直方向的滚动
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    // 设置固定高度确保内容可以完整显示
                    height: 60.0 * 12, // 12节课的总高度
                    child: _buildScheduleGrid(courses),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeekHeader(int i) {
    final a = ['日', '一', '二', '三', '四', '五', '六'];
    final weekDays = [];
    if (i == 0) {
      for (int i1 = 0; i1 < 7; i1++) {
        weekDays.add(Expanded(
            child: Center(
          child: Text(
            a[i1],
          ),
        )));
      }
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            _buildTimeCell(''),
            ...weekDays,
          ],
        ),
      );
    }

    final now = DateTime.now();
    int weekday = now.weekday;
    if (weekday == 7) weekday = 0;
    final w =
        now.subtract(Duration(days: weekday + (weekNow - i) * 7)); // 每周第一天（周日）
    for (int i1 = 0; i1 < 7; i1++) {
      weekDays.add(
        Expanded(
          child: Center(
              child: Text(
                  '${a[i1]}\n${DateFormat('M/d').format(w.add(Duration(days: i1)))}',
                  style: TextStyle(
                    fontWeight: i1 == weekday && weekNow - i == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ))),
        ),
      );
    }
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          _buildTimeCell('${w.month}月'),
          ...weekDays,
        ],
      ),
    );
  }

  Widget _buildScheduleGrid(List<CourseModel> courses) {
    return Row(
      children: [
        _buildTimeLine(),
        ...List.generate(7, (index) => _buildDayColumn(index, courses)),
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
          child: Center(
              child: Text('${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ))),
        ),
      ),
    );
  }

  Widget _buildDayColumn(int weekDay, List<CourseModel> courses) {
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
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    course.room,
                    style: TextStyle(
                      fontSize: isTablet ? 10 : 9,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    course.teachers.join(', '),
                    style: TextStyle(
                      fontSize: isTablet ? 10 : 8,
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
    final weekdayName = ['日','一', '二', '三', '四', '五', '六', '日'];

    var content = Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.courseName,
              style: TextStyle(
                fontSize: isTablet ? 18 : 14,
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
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 12,
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
                style: TextStyle(
                  fontSize: isTablet ? 17 : 12,
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
                '${course.weekIndexes.first}-${course.weekIndexes.last}周 每周${weekdayName[course.weekday]} 第${course.startUnit}节~第${course.endUnit}节',
                style: TextStyle(
                  fontSize: isTablet ? 17 : 12,
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
