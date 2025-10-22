import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/models/course_model.dart';
import 'package:ios_club_app/pageModels/schedule_item.dart';
import 'package:ios_club_app/services/time_service.dart';
import 'package:ios_club_app/stores/schedule_store.dart';
import 'package:ios_club_app/system_services/universal_notification_service.dart';
import 'package:ios_club_app/widgets/empty_widget.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/pageModels/course_color_manager.dart';

import '../club_card.dart';

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  final List<ScheduleItem> scheduleItems = [];
  final List<CourseModel> courses = [];
  late bool isRemind = false;
  late ScheduleStore scheduleStore;

  @override
  void initState() {
    super.initState();
    // 使用 Get.find 获取已经在其他地方初始化的 ScheduleStore 实例
    scheduleStore = Get.find<ScheduleStore>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      courses.addAll(scheduleStore.getTodayCourses());

      if (!mounted) return;

      setState(() {
        // 使用SettingsStore中的isRemind值
        isRemind = SettingsStore.to.isRemind;
        changeScheduleItems(courses);
      });
    } catch (e) {
      debugPrint('初始化失败: $e');
      // 可添加错误处理逻辑（如显示错误提示）
    }
  }

  void changeScheduleItems(List<CourseModel> a) {
    final weekdayName = ['日', '一', '二', '三', '四', '五', '六', '日'];

    scheduleItems.clear();
    scheduleItems.addAll(a.map((course) {
      var startTime = "";
      var endTime = "";
      if (course.room.substring(0, 2) == "草堂") {
        startTime = TimeService.CanTangTime[course.startUnit];
        endTime = TimeService.CanTangTime[course.endUnit];
      } else if (course.room.substring(0, 2) == "雁塔") {
        final now = DateTime.now();
        if (now.month >= 5 && now.month <= 10) {
          startTime = TimeService.YanTaXia[course.startUnit];
          endTime = TimeService.YanTaXia[course.endUnit];
        } else {
          startTime = TimeService.YanTaDong[course.startUnit];
          endTime = TimeService.YanTaDong[course.endUnit];
        }
      } else {
        startTime = TimeService.CanTangTime[course.startUnit];
        endTime = TimeService.CanTangTime[course.endUnit];
      }

      return ScheduleItem(
          title: course.courseName,
          time:
          '第${course.startUnit}节 ~ 第${course
              .endUnit}节 | $startTime~$endTime',
          location: course.room,
          teacher: course.teachers.join(','),
          description: '${course.weekIndexes.first}-${course.weekIndexes
              .last}周 每周${weekdayName[course.weekday]} 第${course.startUnit}节 ~ 第${course
              .endUnit}节',
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
            Obx(() =>
                Text(
                  '${scheduleStore.showTomorrow ? '明' : '今'}日课表',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (alertContext) =>
                          StatefulBuilder(
                            // 使用 StatefulBuilder 包装 AlertDialog
                              builder: (context, setStateDialog) =>
                                  AlertDialog(
                                      title: const Text('设置'),
                                      content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                                title: const Text(
                                                    '显示明天的课表'),
                                                trailing: Obx(() =>
                                                    CupertinoSwitch(
                                                        value: scheduleStore
                                                            .isShowTomorrow,
                                                        onChanged: (
                                                            value) async {
                                                          await scheduleStore
                                                              .toggleShowTomorrow();
                                                          _initializeData(); // 重新加载数据
                                                        }))),
                                            Obx(() =>
                                                ListTile(
                                                  title: const Text('课程通知'),
                                                  trailing: CupertinoSwitch(
                                                    value: SettingsStore.to
                                                        .isRemind,
                                                    onChanged: (
                                                        bool value) async {
                                                      await SettingsStore.to
                                                          .setIsRemind(value);
                                                      if (value &&
                                                          context.mounted) {
                                                        await UniversalNotificationService
                                                            .set(
                                                            context);
                                                      }
                                                    },
                                                  ),
                                                ))
                                          ]))));
                })
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: ClubCard(
            child: Obx(() {
              // 使用 Obx 监听 ScheduleStore 中的变化
              final todayCourses = scheduleStore.getTodayCourses();
              // 创建临时列表而不是直接修改状态
              final tempScheduleItems = _generateScheduleItems(todayCourses);

              return tempScheduleItems.isEmpty
                  ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: EmptyWidget(
                      title:
                      '${scheduleStore.showTomorrow ? '明' : '今'}天没有课了',
                      icon: Icons.school,
                      subtitle: '好好休息会儿吧，学一天累死个人'))
                  : Column(
                children: tempScheduleItems.map(_buildScheduleItem).toList(),
              );
            }),
          ),
        ),
      ],
    );
  }

  List<ScheduleItem> _generateScheduleItems(List<CourseModel> courses) {
    final weekdayName = ['日', '一', '二', '三', '四', '五', '六', '日'];
    final items = <ScheduleItem>[];

    for (var course in courses) {
      var startTime = "";
      var endTime = "";
      if (course.room.substring(0, 2) == "草堂") {
        startTime = TimeService.CanTangTime[course.startUnit];
        endTime = TimeService.CanTangTime[course.endUnit];
      } else if (course.room.substring(0, 2) == "雁塔") {
        final now = DateTime.now();
        if (now.month >= 5 && now.month <= 10) {
          startTime = TimeService.YanTaXia[course.startUnit];
          endTime = TimeService.YanTaXia[course.endUnit];
        } else {
          startTime = TimeService.YanTaDong[course.startUnit];
          endTime = TimeService.YanTaDong[course.endUnit];
        }
      } else {
        startTime = TimeService.CanTangTime[course.startUnit];
        endTime = TimeService.CanTangTime[course.endUnit];
      }

      items.add(ScheduleItem(
          title: course.courseName,
          time:
          '第${course.startUnit}节 ~ 第${course
              .endUnit}节 | $startTime~$endTime',
          location: course.room,
          teacher: course.teachers.join(','),
          description: '${course.weekIndexes.first}-${course.weekIndexes
              .last}周 每周${weekdayName[course.weekday]} 第${course.startUnit}节 ~ 第${course
              .endUnit}节',
      ));
    }
    return items;
  }

  Widget _buildScheduleItem(ScheduleItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // 对于这种简单的信息展示对话框，我们保留原来的 Material 风格
          showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: Text(item.title),
                    content: buildCourse(item),
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item.time,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
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
      ),
    );
  }

  Widget buildCourse(ScheduleItem course) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.blue,
            ),
            const SizedBox(width: 4),
            Text(
              course.location,
              style: TextStyle(
                fontSize: isTablet ? 17 : 15,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
            ),
          ],
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Row(children: [
          const Icon(
            Icons.people,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 4),
          Text(
            course.teacher,
            style: TextStyle(
              fontSize: isTablet ? 17 : 15,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 2,
          )
        ]),
        SizedBox(height: isTablet ? 10 : 8),
        Row(children: [
          const Icon(
            Icons.calendar_today,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            course.description,
            style: TextStyle(
              fontSize: isTablet ? 17 : 15,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ]),
      ],
    );
  }
}