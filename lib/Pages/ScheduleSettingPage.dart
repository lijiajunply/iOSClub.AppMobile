import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/Services/DataService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/PageHeaderDelegate.dart';

class ScheduleSettingPage extends StatefulWidget {
  const ScheduleSettingPage({super.key});

  @override
  State<ScheduleSettingPage> createState() => _ScheduleSettingPageState();
}

class _ScheduleSettingPageState extends State<ScheduleSettingPage> {
  List<String> totalList = [];
  List<String> ignoreList = [];
  final List<CourseIgnore> _ignores = [];
  String url = "";
  final ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final String? username = prefs.getString('username');
      final String? password = prefs.getString('password');
      if (username == null || password == null) {
        return;
      }
      setState(() {
        url =
            '://schedule-backend.borry.org/class?school=xauat&username=$username&password=$password';
      });
    });

    DataService.getIgnore().then((value) {
      setState(() {
        ignoreList = value;
        DataService.getCourseName().then((value) {
          totalList = value;
          for (var i in totalList) {
            _ignores.add(CourseIgnore(
                title: i,
                isCompleted:
                    ignoreList.isNotEmpty && ignoreList.any((x) => x == i)));
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('课程设置'),
        ),
        body: CustomScrollView(slivers: [
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
                    controller: TextEditingController(text: 'webcal$url'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800] // 暗色模式下的背景
                          : Colors.grey[100], // 亮色模式下的背景,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.copy,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[300] // 暗色模式下的图标颜色
                                    : Colors.grey[700] // 亮色模式下的图标颜色
                            ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: 'webcal$url'));
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
            pinned: true, // 设置为true使其具有粘性
            delegate: PageHeaderDelegate(
              title: '忽略课程',
              minHeight: 66,
              maxHeight: 80,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
                child: ListView.builder(
              // 禁用 ListView 自身的滚动
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                        DataService.setIgnore(ignoreList);
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
            )),
          ),
        ]));
  }

  void showCalendarGuidanceDialog(BuildContext context) {
    final httpsUrl = 'webcal$url';

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

class CourseIgnore {
  String title;
  bool isCompleted;

  CourseIgnore({required this.title, this.isCompleted = false});
}
