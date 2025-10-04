import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/Services/data_service.dart';
import 'package:ios_club_app/stores/course_store.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ios_club_app/widgets/club_app_bar.dart';
import 'package:ios_club_app/widgets/page_header_delegate.dart';
import 'package:ios_club_app/widgets/platform_dialog.dart';

class ScheduleSettingPage extends StatefulWidget {
  const ScheduleSettingPage({super.key});

  @override
  State<ScheduleSettingPage> createState() => _ScheduleSettingPageState();
}

class _ScheduleSettingPageState extends State<ScheduleSettingPage>
    with AutomaticKeepAliveClientMixin {
  final CourseStore courseStore = CourseStore.to;
  List<String> totalList = [];
  List<String> ignoreList = [];
  late List<CourseIgnore> _ignores = [];
  String url = "";
  final ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadCredentials();
    await _loadCourseData();
  }

  Future<void> _loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final password = prefs.getString('password');

      if (username != null && password != null) {
        setState(() {
          url =
              '://schedule.xauat.site/class?school=xauat&username=$username&password=$password';
        });
      }
    } catch (e) {
      debugPrint('Failed to load credentials: $e');
    }
  }

  Future<void> _loadCourseData() async {
    try {
      await courseStore.loadIgnoreCourses();
      final courseNames = await DataService.getCourseName();

      final ignores = courseNames
          .map((i) => CourseIgnore(
                title: i,
                isCompleted:
                    courseStore.ignoreCourses.isNotEmpty && courseStore.ignoreCourses.any((x) => x == i),
              ))
          .toList();

      setState(() {
        ignoreList = courseStore.ignoreCourses;
        totalList = courseNames;
        _ignores = ignores;
      });
    } catch (e) {
      debugPrint('Failed to load course data: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    super.build(context);
    return Scaffold(
      appBar: ClubAppBar(
        title: ('课程设置'),
      ),
      body: CustomScrollView(
        cacheExtent: 500,
        slivers: [
          if (!isDesktop)
            SliverPersistentHeader(
              pinned: true,
              delegate: PageHeaderDelegate(
                title: '将课程录入到日历',
                minHeight: 66,
                maxHeight: 80,
                icon: Icon(Icons.open_in_new),
                onPressed: () async {
                  if (url == '') {
                    return;
                  }
                  // 尝试启动系统日历

                  if (Platform.isAndroid) {
                    final intent = AndroidIntent(
                      action: 'android.intent.action.VIEW',
                      data: 'webcal$url',
                      type: 'text/calendar',
                    );
                    var result = await intent.canResolveActivity();
                    if (result != null && result) {
                      await intent.launch();
                    } else {
                      // 如果没有找到可以处理该 Intent 的应用，则显示错误消息
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('没有找到日历应用，请手动导入'),
                          ),
                        );
                      }
                    }
                    return;
                  }

                  final Uri uri = Uri.parse('webcal$url');

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    throw '无法打开日历应用';
                  }
                },
              ),
            ),
          if (!isDesktop)
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '没有用？试试手动录入',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: 'https$url'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800] // 暗色模式下的背景
                                : Colors.grey[100], // 亮色模式下的背景,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.copy,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[300] // 暗色模式下的图标颜色
                                  : Colors.grey[700] // 亮色模式下的图标颜色
                              ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: 'webcal$url'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('复制成功!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => showCalendarGuidanceDialog(context),
                      label: Text('我不会导入'),
                      icon: Icon(Icons.help),
                    )
                  ],
                ),
              ),
            ),
          SliverPersistentHeader(
            pinned: true,
            delegate: PageHeaderDelegate(
              title: '忽略课程',
              minHeight: 66,
              maxHeight: 80,
            ),
          ),
          SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: ClubCard(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _ignores.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _CourseIgnoreItem(
                      ignore: _ignores[index],
                      onChanged: _handleIgnoreChange,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _handleIgnoreChange(CourseIgnore ignore, bool value) async {
    setState(() => ignore.isCompleted = value);
    await Future.microtask(() {
      if (value) {
        ignoreList.add(ignore.title);
      } else {
        ignoreList.remove(ignore.title);
      }
      
      // 使用CourseStore更新忽略的课程
      courseStore.setIgnoreCourses(ignoreList);
      return DataService.setIgnore(ignoreList);
    });
  }

  void showCalendarGuidanceDialog(BuildContext context) {
    final httpsUrl = 'webcal$url';

    // 对于这种复杂的说明性对话框，我们保留原来的 Material 风格
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加日历订阅'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('您的设备似乎没有应用可以直接处理日历订阅。请按照以下步骤手动添加:'),
              const SizedBox(height: 16),
              const Text('1. 打开您的日历应用'),
              const Text('2. 找到"添加日历"或"订阅"选项'),
              const Text('3. 选择"通过URL添加"或类似选项'),
              const Text('4. 粘贴以下链接:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        httpsUrl,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: httpsUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('链接已复制到剪贴板')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('注意: 不同的日历应用可能有不同的添加步骤。如果您遇到困难，请查阅您的日历应用帮助文档。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('明白了'),
          ),
        ],
      ),
    );
  }
}

class _CourseIgnoreItem extends StatelessWidget {
  final CourseIgnore ignore;
  final Function(CourseIgnore, bool) onChanged;

  const _CourseIgnoreItem({
    required this.ignore,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Checkbox(
                  value: ignore.isCompleted,
                  onChanged: (v) => onChanged(ignore, v!),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ignore.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )),
        onTap: () => onChanged(ignore, !ignore.isCompleted),
      ),
    );
  }
}

class CourseIgnore {
  String title;
  bool isCompleted;

  CourseIgnore({required this.title, this.isCompleted = false});
}
