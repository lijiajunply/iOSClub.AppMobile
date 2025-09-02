import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/Services/edu_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../PageModels/CourseColorManager.dart';
import '../Models/CourseModel.dart';
import '../Services/data_service.dart';
import '../widgets/ClubModalBottomSheet.dart';
import '../widgets/showClubSnackBar.dart';

class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({super.key});

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  late List<List<CourseModel>> allCourse = [];
  late int maxWeek = 0;
  late int weekNow = 0;
  late PageController pageController = PageController();
  double height = 55.0;
  int currentPage = 0;
  CourseStyle courseStyle = CourseStyle.normal;
  bool isStyle = false;
  bool isLoading = true;

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
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final weekData = await DataService.getWeek();
      await _handleWeekData(weekData);
      await _loadCourses();
      await _loadPreferences();
    } catch (e) {
      debugPrint('初始化数据出错: $e');
      // 可以考虑在这里显示错误提示给用户
    }
  }

  Future<void> _handleWeekData(Map<String, dynamic> weekData) async {
    setState(() {
      weekNow = weekData['week']!;
      maxWeek = weekData['maxWeek']!;
      currentPage = weekNow <= 0 ? 0 : weekNow;

      pageController = PageController(initialPage: currentPage);
    });
  }

  Future<void> _loadCourses() async {
    final courses = await DataService.getAllCourse();
    setState(() {
      allCourse = List.generate(maxWeek + 1, (i) {
        return i == 0
            ? courses
            : courses
                .where((course) => course.weekIndexes.contains(i))
                .toList();
      });
      isLoading = false;
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final courseSize = prefs.getDouble('course_size');

    if (courseSize != null && courseSize != 0) {
      setState(() {
        height = courseSize;
        courseStyle = _determineCourseStyle(courseSize);
      });
    }
  }

  CourseStyle _determineCourseStyle(double size) {
    if (size == 50) return CourseStyle.small;
    if (size == 55) return CourseStyle.normal;
    return CourseStyle.large;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    final setting = Row(
      children: [
        IconButton(
            onPressed: () {
              setState(() {
                isStyle = !isStyle;
              });
            },
            icon: const Icon(Icons.style)),
        IconButton(
            onPressed: () async {
              showClubSnackBar(context, Text('正在进行更新，请稍后'));
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
                          .where((course) => course.weekIndexes.contains(i))
                          .toList());
                    }
                    jumpToPage(weekNow);
                  });
                });
              });
              if (context.mounted) {
                showClubSnackBar(context, Text('更新完成'));
              }
            },
            icon: const Icon(Icons.refresh)),
        IconButton(
            onPressed: () {
              Get.toNamed('/ScheduleSetting');
            },
            icon: const Icon(Icons.more_vert))
      ],
    );
    final animatedSlide = AnimatedSlide(
        duration: const Duration(milliseconds: 300), // 动画持续时间，可以根据需要调整
        curve: Curves.easeInOut,
        offset: Offset(0, isStyle ? 0 : -0.1),
        child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            opacity: isStyle ? 1.0 : 0.0,
            child: isStyle
                ? Padding(
                    padding: EdgeInsets.all(4),
                    child: CupertinoSlidingSegmentedControl<CourseStyle>(
                      groupValue: courseStyle,
                      // Callback that sets the selected segmented control.
                      onValueChanged: (CourseStyle? value) async {
                        if (value != null) {
                          setState(() {
                            courseStyle = value;
                            if (value == CourseStyle.small) {
                              height = 50;
                            } else if (value == CourseStyle.normal) {
                              height = 55;
                            } else if (value == CourseStyle.large) {
                              height = 60;
                            } else if (value == CourseStyle.fool) {
                              allCourse.clear();
                              allCourse.add([]);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('是的，我没有课了'),
                                ),
                              );
                            }
                          });
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setDouble('course_size', height);
                        }
                      },
                      children: {
                        CourseStyle.small: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('较小'),
                        ),
                        CourseStyle.normal: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('默认'),
                        ),
                        CourseStyle.large: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('较大'),
                        ),
                        CourseStyle.fool: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('愚人节'),
                        ),
                      },
                    ),
                  )
                : Container()));

    final weekText = weekNow <= 0 ? '距离开学还有${-weekNow + 1}周' : '当前为第$weekNow周';

    return Scaffold(
        body: Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: isDesktop
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: TextButton(
                                  onPressed: () =>
                                      jumpToPage((currentPage - 1).ceil()),
                                  child: const Text('上一周'))),
                          Expanded(
                              child: Center(
                            child: Text(
                              currentPage <= 0
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
                                  onPressed: () => jumpToPage(
                                      (pageController.page! + 1).ceil()),
                                  child: const Text('下一周'))),
                        ],
                      ),
                      Row(children: [
                        Expanded(child: const SizedBox()),
                        Expanded(child: animatedSlide),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [setting],
                        ))
                      ])
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
                                  fontSize: 18,
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    jumpToPage(weekNow);
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        currentPage <= 0 ||
                                                currentPage == weekNow
                                            ? '全部课表 $weekText'
                                            : currentPage <= 0
                                                ? '全部课表 $weekText'
                                                : '第$currentPage周 $weekText',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      )))
                            ],
                          )
                        ]),
                      ),
                      setting
                    ],
                  )),
        if (!isDesktop) animatedSlide,
        isLoading
            ? const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Expanded(
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
                height: height,
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
        child: InkWell(
          onTap: () async {
            await _showModalBottomSheet(course);
          },
          child: Card(
            margin: const EdgeInsets.all(2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: CourseColorManager.generateSoftColor(course.courseName),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 8 : 4),
              child: SingleChildScrollView(
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
                      maxLines: 3,
                    ),
                    Text(
                      course.room,
                      style: TextStyle(
                        fontSize: isTablet ? 10 : 9,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
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

    return showClubModalBottomSheet(context, content);
  }
}

enum CourseStyle {
  normal,
  small,
  large,
  fool,
}
