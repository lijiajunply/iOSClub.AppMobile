import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/pageModels/course_color_manager.dart';
import 'package:ios_club_app/models/course_model.dart';
import 'package:ios_club_app/services/time_service.dart';
import 'package:ios_club_app/stores/schedule_store.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/widgets/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/widgets/dashed_separator.dart';
import 'package:ios_club_app/widgets/show_club_snack_bar.dart';

class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({super.key});

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  late PageController pageController = PageController();
  CourseStyle courseStyle = CourseStyle.normal;
  bool isStyle = false;
  bool isYanTa = false;

  final ScheduleStore scheduleStore = ScheduleStore.to;
  final SettingsStore settingsStore = SettingsStore.to;

  void jumpToPage(int page) {
    scheduleStore.jumpToPage(page);
    pageController.jumpToPage(scheduleStore.currentPage);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: scheduleStore.currentPage);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final courseSize = prefs.getDouble('course_size');

    if (courseSize != null && courseSize != 0) {
      setState(() {
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
        !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

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
              await scheduleStore.refreshCourses();
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
                ? Container(
                    padding: EdgeInsets.all(4),
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<CourseStyle>(
                      groupValue: courseStyle,
                      // Callback that sets the selected segmented control.
                      onValueChanged: (CourseStyle? value) async {
                        if (value != null) {
                          final a = courseStyle;
                          setState(() {
                            courseStyle = value;
                          });
                          double height = 55;
                          if (value == CourseStyle.small) {
                            if (a == CourseStyle.fool) {
                              await scheduleStore.refreshCourses();
                            }
                            height = 50;
                          } else if (value == CourseStyle.normal) {
                            if (a == CourseStyle.fool) {
                              await scheduleStore.refreshCourses();
                            }
                            height = 55;
                          } else if (value == CourseStyle.large) {
                            if (a == CourseStyle.fool) {
                              await scheduleStore.refreshCourses();
                            }
                            height = 60;
                          } else if (value == CourseStyle.fool) {
                            scheduleStore.clean();
                            showClubSnackBar(context, Text('是的，我没有课了'));
                            return;
                          }
                          await scheduleStore.setCourseHeight(height);
                        }
                      },
                      children: {
                        CourseStyle.small: Text('较小'),
                        CourseStyle.normal: Text('默认'),
                        CourseStyle.large: Text('较大'),
                        CourseStyle.fool: Text('愚人节'),
                      },
                    ),
                  )
                : Container()));

    final weekText = scheduleStore.currentWeek <= 0
        ? '距离开学还有${-scheduleStore.currentWeek + 1}周'
        : '当前为第${scheduleStore.currentWeek}周';

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
                                  onPressed: () => jumpToPage(
                                      (scheduleStore.currentPage - 1).ceil()),
                                  child: const Text('上一周'))),
                          Expanded(
                              child: Center(
                            child: Obx(() => Text(
                                  scheduleStore.currentPage <= 0
                                      ? '全部课表'
                                      : '第 ${scheduleStore.currentPage} 周 ${scheduleStore.currentPage == scheduleStore.currentWeek ? "(本周)" : ""}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                )),
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
                              Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: InkWell(
                                      onTap: () {
                                        jumpToPage(scheduleStore.currentWeek);
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Obx(
                                        () {
                                          return Text(
                                            scheduleStore.currentPage ==
                                                    scheduleStore.currentWeek
                                                ? weekText
                                                : scheduleStore.currentPage <= 0
                                                    ? '全部课表 $weekText'
                                                    : '第${scheduleStore.currentPage}周 $weekText',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          );
                                        },
                                      ))),
                            ],
                          )
                        ]),
                      ),
                      setting
                    ],
                  )),
        if (!isDesktop) animatedSlide,
        Obx(() => scheduleStore.isLoading
            ? const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    scheduleStore.setCurrentPage(index);
                  },
                  itemCount: scheduleStore.allCourses.length,
                  itemBuilder: (BuildContext context, int i) {
                    final courses = scheduleStore.allCourses[i];
                    return Column(
                      children: [
                        _buildWeekHeader(i),
                        Expanded(
                          child: SingleChildScrollView(
                            // 添加垂直方向的滚动
                            scrollDirection: Axis.vertical,
                            child: SizedBox(
                              // 设置固定高度确保内容可以完整显示
                              height: scheduleStore.height * 12, // 12节课的总高度
                              child: _buildScheduleGrid(courses),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ))
      ],
    ));
  }

  Widget _buildWeekHeader(int i) {
    final a = ['日', '一', '二', '三', '四', '五', '六'];
    final weekDays = [];
    if (i == 0) {
      for (int i1 = 0; i1 < 7; i1++) {
        weekDays.add(Expanded(
          child: Stack(
            children: [
              // 添加网格线
              if (settingsStore.showCourseGrid)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: DashedSeparator(
                      axis: Axis.horizontal,
                      thickness: 0.5,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              Center(
                child: Text(
                  a[i1],
                ),
              ),
            ],
          ),
        ));
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
    final w = now.subtract(Duration(
        days: weekday + (scheduleStore.currentWeek - i) * 7)); // 每周第一天（周日）
    for (int i1 = 0; i1 < 7; i1++) {
      weekDays.add(
        Expanded(
          child: Stack(
            children: [
              // 添加网格线
              if (settingsStore.showCourseGrid)
                Positioned.fill(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: DashedSeparator(
                          axis: Axis.horizontal,
                          thickness: 0.5,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DashedSeparator(
                          axis: Axis.vertical,
                          thickness: 0.5,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(width: double.infinity,child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    a[i1],
                    style: TextStyle(
                      fontWeight:
                      i1 == weekday && scheduleStore.currentWeek - i == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    DateFormat('M/d').format(w.add(Duration(days: i1))),
                    style: TextStyle(
                      fontWeight:
                      i1 == weekday && scheduleStore.currentWeek - i == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  )
                ],
              ),),
            ],
          ),
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
          height: scheduleStore.height,
          width: 50,
          child: Stack(
            children: [
              // 添加网格线
              if (settingsStore.showCourseGrid)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: DashedSeparator(
                      axis: Axis.horizontal,
                      thickness: 0.5,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              Center(
                child: _buildTimeCellForPeriod(index + 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCellForPeriod(int period) {
    final index = period - 1;
    String startTime = "";
    String endTime = "";

    // 根据当前日期和季节选择时间表
    final now = DateTime.now();
    final isSummer = now.month >= 5 && now.month < 10;

    // 确保索引在有效范围内
    if (index + 1 < TimeService.CanTangTimeStart.length) {
      // 默认使用草堂时间
      startTime = TimeService.CanTangTimeStart[index + 1];
      endTime = TimeService.CanTangTimeEnd[index + 1];

      // 根据季节选择雁塔时间
      if (scheduleStore.isYanTa) {
        if (isSummer) {
          if (index + 1 < TimeService.YanTaXiaStart.length) {
            startTime = TimeService.YanTaXiaStart[index + 1];
            endTime = TimeService.YanTaXiaEnd[index + 1];
          }
        } else {
          if (index + 1 < TimeService.YanTaDongStart.length) {
            startTime = TimeService.YanTaDongStart[index + 1];
            endTime = TimeService.YanTaDongEnd[index + 1];
          }
        }
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$period',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            )),
        Text(
          startTime,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 8,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          endTime,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDayColumn(int weekDay, List<CourseModel> courses) {
    return Expanded(
      child: Stack(
        children: [
          // 添加网格线
          if (settingsStore.showCourseGrid) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: DashedSeparator(
                axis: Axis.vertical,
                thickness: 0.5,
                color: Theme.of(context).dividerColor,
              ),
            ),
            ...List.generate(
              12,
              (index) => Positioned(
                top: (index + 1) * scheduleStore.height,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: DashedSeparator(
                    axis: Axis.horizontal,
                    thickness: 0.5,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
            ),
          ],
          Column(
            children: List.generate(
              12,
              (index) => Container(
                height: scheduleStore.height,
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
        top: (course.startUnit - 1) * scheduleStore.height,
        left: 0,
        right: 0,
        height: (course.endUnit - course.startUnit + 1) * scheduleStore.height,
        child: Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: CourseColorManager.generateSoftColor(course.courseName),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              await _showModalBottomSheet(course);
            },
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
      child: Stack(
        children: [
          // 添加网格线
          if (settingsStore.showCourseGrid)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: DashedSeparator(
                  axis: Axis.horizontal,
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          Center(
            child: Text(
              text,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showModalBottomSheet(CourseModel course) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;
    final weekdayName = ['日', '一', '二', '三', '四', '五', '六', '日'];

    var content = Container(
        padding:
            EdgeInsets.symmetric(vertical: isTablet ? 16 : 0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.courseName,
              style: TextStyle(
                fontSize: isTablet ? 18 : 20,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
            SizedBox(height: isTablet ? 10 : 18),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
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
                '${course.weekIndexes.first}-${course.weekIndexes.last}周 每周${weekdayName[course.weekday]} 第${course.startUnit}-${course.endUnit}节',
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
