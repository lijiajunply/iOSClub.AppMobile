import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/CourseModel.dart';
import '../../PageModels/CourseColorManager.dart';
import '../../PageModels/ScheduleItem.dart';
import '../../Services/data_service.dart';
import '../../Services/notification_service.dart';
import '../../Services/time_service.dart';
import '../empty_widget.dart';

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  final List<ScheduleItem> scheduleItems = [];
  bool _isShowingTomorrow = false;
  bool _isShowTomorrow = false;
  late bool isRemind = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final (isShowingTomorrow, courses) = await DataService.getCourse(
          isTomorrow: prefs.getBool('is_show_tomorrow') ?? false);

      if (!mounted) return;

      setState(() {
        isRemind = prefs.getBool('is_remind') ?? false;
        _isShowTomorrow = prefs.getBool('is_show_tomorrow') ?? false;
        _isShowingTomorrow = isShowingTomorrow;
        changeScheduleItems(courses);
      });
    } catch (e) {
      debugPrint('初始化失败: $e');
      // 可添加错误处理逻辑（如显示错误提示）
    }
  }

  void changeScheduleItems(List<CourseModel> a) {
    scheduleItems.clear();
    scheduleItems.addAll(a.map((course) {
      var startTime = "";
      var endTime = "";
      if (course.room.substring(0, 2) == "草堂") {
        startTime = TimeService.CanTangTime[course.startUnit];
        endTime = TimeService.CanTangTime[course.endUnit];
      } else {
        final now = DateTime.now();
        if (now.month >= 5 && now.month <= 10) {
          startTime = TimeService.YanTaXia[course.startUnit];
          endTime = TimeService.YanTaXia[course.endUnit];
        } else {
          startTime = TimeService.YanTaDong[course.startUnit];
          endTime = TimeService.YanTaDong[course.endUnit];
        }
      }

      return ScheduleItem(
        title: course.courseName,
        time:
            '第${course.startUnit}节 ~ 第${course.endUnit}节 | $startTime~$endTime',
        location: course.room,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              '${_isShowingTomorrow ? '明' : '今'}日课表',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (alertContext) => StatefulBuilder(
                          // 使用 StatefulBuilder 包装 AlertDialog
                          builder: (context, setStateDialog) => AlertDialog(
                              title: const Text('设置'),
                              content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                        title: const Text('显示明天的课表'),
                                        trailing: CupertinoSwitch(
                                            value: _isShowTomorrow,
                                            onChanged: (value) async {
                                              setStateDialog(() {
                                                _isShowTomorrow = value;
                                              });
                                              setState(() {
                                                SharedPreferences.getInstance()
                                                    .then((prefs) {
                                                  prefs.setBool(
                                                      'is_show_tomorrow',
                                                      value);
                                                  DataService.getCourse(
                                                          isTomorrow: value)
                                                      .then((value) {
                                                    _isShowingTomorrow =
                                                        value.$1;
                                                    changeScheduleItems(
                                                        value.$2);
                                                  });
                                                });
                                              });
                                            })),
                                    ListTile(
                                      title: const Text('课程通知'),
                                      trailing: CupertinoSwitch(
                                        value: isRemind,
                                        onChanged: (bool value) async {
                                          setStateDialog(() {
                                            isRemind = value;
                                          });
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          prefs.setBool('is_remind', value);
                                          if (value && context.mounted) {
                                            await NotificationService.set(
                                                context);
                                          }
                                        },
                                      ),
                                    )
                                  ]))));
                })
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Card(
            elevation: 4,
            child: scheduleItems.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(16.0),
                    child: EmptyWidget(
                        title: '${_isShowingTomorrow ? '明' : '今'}天没有课了',
                        icon: Icons.school,
                        subtitle: '好好休息会儿吧，学一天累死个人'))
                : Column(
                    children: scheduleItems.map(_buildScheduleItem).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(ScheduleItem item) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(item.title),
                  content: Wrap(
                    children: [buildCourse(item)],
                  ),
                ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: CourseColorManager.generateSoftColor(item.location),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(item.time,
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(item.location,
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCourse(ScheduleItem item) {
    return FutureBuilder(
        future: getCourse(item),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final course = snapshot.data!;
            return _buildCourseContainer(course);
          }
        });
  }

  Future<CourseModel> getCourse(ScheduleItem item) async {
    final (_, courses) =
        await DataService.getCourse(isTomorrow: _isShowTomorrow);

    return courses.firstWhere((course) {
      return course.startUnit.toString() == item.time[1];
    });
  }

  Widget _buildCourseContainer(CourseModel course) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;
    final weekdayName = ['日', '一', '二', '三', '四', '五', '六', '日'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              maxLines: 2,
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
            maxLines: 2,
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
            maxLines: 2,
          ),
        ]),
      ],
    );
  }
}
