import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:ios_club_app/stores/course_store.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/show_club_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import 'package:ios_club_app/widgets/club_app_bar.dart';
import 'package:ios_club_app/stores/settings_store.dart';

class ScheduleSettingPage extends StatefulWidget {
  const ScheduleSettingPage({super.key});

  @override
  State<ScheduleSettingPage> createState() => _ScheduleSettingPageState();
}

class _ScheduleSettingPageState extends State<ScheduleSettingPage>
    with AutomaticKeepAliveClientMixin {
  final CourseStore courseStore = CourseStore.to;
  final SettingsStore settingsStore = SettingsStore.to;
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
                isCompleted: courseStore.ignoreCourses.isNotEmpty &&
                    courseStore.ignoreCourses.any((x) => x == i),
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
    super.build(context);
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
        appBar: ClubAppBar(
          title: '课程设置',
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isDesktop)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '将课程录入到日历',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.open_in_new),
                              onPressed: () async {
                                if (url == '') {
                                  return;
                                }
                                // 尝试启动系统日历

                                if (!kIsWeb && Platform.isAndroid) {
                                  final intent = AndroidIntent(
                                    action: 'android.intent.action.VIEW',
                                    data: 'webcal$url',
                                    type: 'text/calendar',
                                  );
                                  var result =
                                      await intent.canResolveActivity();
                                  if (result != null && result) {
                                    await intent.launch();
                                  } else {
                                    // 如果没有找到可以处理该 Intent 的应用，则显示错误消息
                                    if (context.mounted) {
                                      showClubSnackBar(
                                        context,
                                        Text('没有找到日历应用，请手动导入'),
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
                          ],
                        )),
                    Text(
                      '没有用？试试手动录入',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16),
                    CupertinoTextField(
                      controller: TextEditingController(text: 'https$url'),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.copy,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: 'webcal$url'));
                            showClubSnackBar(
                              context,
                              Text('复制成功!'),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed: () => showCalendarGuidanceDialog(context),
                      child: Text('我不会导入'),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '课表显示设置',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ClubCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.grid,
                            size: 20,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : CupertinoColors.tertiaryLabel,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '显示课表网格线',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          CupertinoSwitch(
                            value: settingsStore.showCourseGrid,
                            onChanged: (value) {
                              setState(() {
                                settingsStore.setShowCourseGrid(value);
                              });
                            },
                          ),
                        ],
                      )),
                  SizedBox(height: 24),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '课表背景设置',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ClubCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioGroup<String>(
                          groupValue: settingsStore.scheduleBackground,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                settingsStore.setScheduleBackground(newValue);
                              });
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBackgroundOption('无背景', ''),
                              _buildBackgroundOption('深蓝色渐变', 'gradient1'),
                              _buildBackgroundOption('粉红色渐变', 'gradient2'),
                              _buildBackgroundOption('自定义图片', 'custom'),
                              if (settingsStore.scheduleBackground == 'custom')
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          settingsStore
                                                  .customBackgroundImage.isEmpty
                                              ? '未选择图片'
                                              : settingsStore
                                                  .customBackgroundImage,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.folder),
                                        onPressed: _pickCustomBackgroundImage,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '忽略课程',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ClubCard(
                    child: Column(
                      children: _ignores
                          .map((ignore) => CourseIgnoreItem(
                                ignore: ignore,
                                onChanged: _handleIgnoreChange,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildBackgroundOption(String title, String value) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      value: value,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Future<void> _pickCustomBackgroundImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: false, // 不直接读取数据，只获取路径
      );

      if (result != null) {
        String filePath = result.files.single.path ?? result.files.single.name;
        settingsStore.setCustomBackgroundImage(filePath);

        if (context.mounted) {
          showClubSnackBar(
            context,
            const Text('背景图片设置成功'),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showClubSnackBar(
          context,
          const Text('选择图片失败'),
        );
      }
      debugPrint('选择背景图片失败: $e');
    }
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
                        showClubSnackBar(
                          context,
                          const Text('链接已复制到剪贴板'),
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

class CourseIgnoreItem extends StatelessWidget {
  final CourseIgnore ignore;
  final Function(CourseIgnore, bool) onChanged;

  const CourseIgnoreItem({
    super.key,
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
