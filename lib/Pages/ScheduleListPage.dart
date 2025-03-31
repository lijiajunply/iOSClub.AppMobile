import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/Services/EduService.dart';

import '../PageModels/CourseColorManager.dart';
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
  double height = 60.0;
  int currentPage = 0; // 添加到 State 类中

  void jumpToPage(int page) {
    if (page < 0) {
      page = maxWeek;
    } else if (page > maxWeek) {
      page = 0;
    }
    setState(() {
      currentPage = page;
    });
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

    DataService.getWeek().then((value) {
      setState(() {
        weekNow = value['week']!;
        maxWeek = value['maxWeek']!;
        pageController.jumpToPage(weekNow);
        currentPage = weekNow;
      });
      DataService.getAllCourse().then((value) {
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
        body: Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(
                          child: TextButton(
                              onPressed: () =>
                                  jumpToPage((currentPage - 1).ceil()),
                              child: const Text('上一周'))),
                      Expanded(
                          child: Center(
                        child: Text(
                          currentPage == 0
                              ? '全部课表'
                              : '第 $currentPage 周 ${currentPage == weekNow ? "(本周)" : ""}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      )),
                      Expanded(
                          child: TextButton(
                              onPressed: () =>
                                  jumpToPage((pageController.page! + 1).ceil()),
                              child: const Text('下一周'))),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('yyyy年M月d日').format(DateTime.now()),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              InkWell(
                                  onTap: () {},
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        currentPage == weekNow
                                            ? '第$currentPage周'
                                            : currentPage == 0
                                                ? '全部课表 当前为第$weekNow周'
                                                : '第$currentPage周 当前为第$weekNow周',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      )))
                            ],
                          )
                        ]),
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  allCourse.clear();
                                  allCourse.add([]);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('是的，我没有课了'),
                                        const Icon(Icons.mood,
                                            color: Colors.black12)
                                      ],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.mood)),
                          IconButton(
                              onPressed: () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('正在进行更新，请稍后'),
                                  ),
                                );
                                await EduService.getCourse(isRefresh: true);
                                setState(() {
                                  allCourse.clear();
                                  DataService.getAllCourse().then((value) {
                                    setState(() {
                                      for (var i = 0; i <= maxWeek; i++) {
                                        if (i == 0) {
                                          allCourse.add(value);
                                          continue;
                                        }
                                        allCourse.add(value
                                            .where((course) =>
                                                course.weekIndexes.contains(i))
                                            .toList());
                                      }
                                    });
                                  });
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('更新完成'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.refresh)),
                          IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/ScheduleSetting');
                              },
                              icon: const Icon(Icons.more_vert))
                        ],
                      )
                    ],
                  )),
        Expanded(
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemCount: allCourse.length,
            itemBuilder: (BuildContext context, int i) {
              final courses = allCourse[i];
              return Column(
                children: [
                  _buildWeekHeader(i),
                  Expanded(
                    child: SingleChildScrollView(
                      // 添加垂直方向的滚动
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        // 设置固定高度确保内容可以完整显示
                        height: height * 12, // 12节课的总高度
                        child: _buildScheduleGrid(courses),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ],
    ));
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
      return SizedBox(
        height: 50,
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(
              a[i1],
              style: TextStyle(
                fontWeight: i1 == weekday && weekNow - i == 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            Text(DateFormat('M/d').format(w.add(Duration(days: i1))),
                style: TextStyle(
                  fontWeight: i1 == weekday && weekNow - i == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ))
          ]),
        ),
      );
    }
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          _buildTimeCell('${w.month}月',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ...weekDays,
        ],
      ),
    );
  }

  Widget _buildScheduleGrid(List<CourseModel> courses) {
    return Row(
      children: [
        _buildTimeLine(),
        ...List.generate(7, (index) {
          if (index == 0) index = 7;
          return _buildDayColumn(index, courses);
        }),
      ],
    );
  }

  Widget _buildTimeLine() {
    return Column(
      children: List.generate(
        12,
        (index) => SizedBox(
          height: height,
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
        top: (course.startUnit - 1) * height,
        left: 0,
        right: 0,
        height: (course.endUnit - course.startUnit + 1) * height,
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
                      color: Colors.white70,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 4,
                  ),
                  Text(
                    course.room,
                    style: TextStyle(
                      fontSize: isTablet ? 10 : 9,
                      overflow: TextOverflow.ellipsis,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    course.teachers.join(', '),
                    style: TextStyle(
                      fontSize: isTablet ? 10 : 8,
                      overflow: TextOverflow.ellipsis,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildTimeCell(
    String text, {
    TextStyle style = const TextStyle(),
  }) {
    return SizedBox(
      width: 50,
      child: Center(
          child: Text(
        text,
        style: style,
      )),
    );
  }

  Future<void> _showModalBottomSheet(CourseModel course) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;
    final weekdayName = ['日', '一', '二', '三', '四', '五', '六', '日'];

    var content = Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.courseName,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
            SizedBox(height: isTablet ? 10 : 18),
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
                    fontSize: isTablet ? 17 : 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 10 : 18),
            Row(children: [
              const Icon(
                Icons.person,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 4),
              Text(
                course.teachers.join(', '),
                style: TextStyle(
                  fontSize: isTablet ? 17 : 15,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
            SizedBox(height: isTablet ? 10 : 18),
            Row(children: [
              const Icon(
                Icons.calendar_today,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                '${course.weekIndexes.first}-${course.weekIndexes.last}周 每周${weekdayName[course.weekday]} 第${course.startUnit}节~第${course.endUnit}节',
                style: TextStyle(
                  fontSize: isTablet ? 17 : 15,
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
          return Padding(padding: const EdgeInsets.all(10), child: content);
        });
  }
}
