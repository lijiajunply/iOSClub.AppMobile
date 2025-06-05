import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/edu_service.dart';
import 'package:ios_club_app/services/todo_service.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/git_service.dart';
import '../Services/notification_service.dart';
import '../services/download_service.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置/关于'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              const Image(
                image: AssetImage('assets/icon.png'),
                width: 100,
                height: 100,
              ),
              const SizedBox(
                height: 8,
              ),
              const Center(
                  child: Text(
                'iOS Club App',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              )),
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text('基本设置',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Card(
                child: ListTile(
                  title: const Text(
                    '刷新数据',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: Icon(Icons.refresh),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('正在刷新数据...')),
                    );
                    final re = await EduService.refresh();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('刷新数据${re ? '成功' : '失败'}')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ShowTomorrowSetting(),
              const SizedBox(
                height: 8,
              ),
              RemindSetting(),
              const SizedBox(
                height: 8,
              ),
              TodoListSetting(),
              const SizedBox(
                height: 8,
              ),
              HomePageSetting(),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text('版本',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              VersionSetting(),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text('关于我们',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Card(
                child: ListTile(
                  title: Text('制作团队',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(
                    'LuckyFish & zealous',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                  trailing: Icon(Icons.people_rounded),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Card(
                child: ListTile(
                  title: Text('开源协议',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(
                    'MIT License',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                  trailing: Icon(Icons.abc),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Card(
                child: ListTile(
                  title: Text('关于社团',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  trailing: Icon(Icons.apple),
                  subtitle: Text(
                    'iOS Club of XAUAT',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    _showClubDescription(context);
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          )),
    );
  }

  Future<void> _showClubDescription(BuildContext context) {
    final a = MediaQuery.of(context).size.width;

    return showModalBottomSheet<void>(
        context: context,
        constraints: BoxConstraints(
            maxWidth: a,
            minWidth: a,
            maxHeight: MediaQuery.of(context).size.height * 0.9),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    const Text('关于社团',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Image(
                      image: AssetImage('assets/iOS_Club_Logo.png'),
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(height: 10),
                    const Text('iOS Club of XAUAT',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text(
                        '西建大iOS众创空间俱乐部（别称为西建大iOS Club），是苹果公司和学校共同创办的创新创业类社团。成立于2019年9月。目前是全校较大和较为知名的科技类社团。',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    const Text(
                        '西建大iOS众创空间俱乐部没有设备要求，或者说没有任何限制 —— 只要你喜欢数码，热爱编程，或者想要学习编程开发搞项目，就可以加入到西建大iOS众创空间俱乐部。',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                  ])));
        });
  }
}

class ShowTomorrowSetting extends StatefulWidget {
  const ShowTomorrowSetting({super.key});

  @override
  State<StatefulWidget> createState() => _ShowTomorrowSettingState();
}

class _ShowTomorrowSettingState extends State<ShowTomorrowSetting> {
  late bool isShowTomorrow = false;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isShowTomorrow = prefs.getBool('is_show_tomorrow') ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: const Text('显示明日课程',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: const Text(
        '当今日无课时显示明日课程',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
      ),
      trailing: CupertinoSwitch(
        value: isShowTomorrow,
        onChanged: (bool value) async {
          setState(() {
            isShowTomorrow = value;
          });
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('is_show_tomorrow', value);
        },
      ),
    ));
  }
}

class RemindSetting extends StatefulWidget {
  const RemindSetting({super.key});

  @override
  State<StatefulWidget> createState() => _RemindSettingState();
}

class _RemindSettingState extends State<RemindSetting> {
  late bool isRemind = false;
  late int remindTime = 15;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isRemind = prefs.getBool('is_remind') ?? false;
        remindTime = prefs.getInt('notification_time') ?? 15;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: [
        ListTile(
          title: const Text('课程通知',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(
            '上课前进行提醒',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
          ),
          trailing: CupertinoSwitch(
            value: isRemind,
            onChanged: (bool value) async {
              setState(() {
                isRemind = value;
              });
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('is_remind', value);
              if (value && context.mounted) {
                await NotificationService.set(context);
              }
            },
          ),
        ),
        if (isRemind)
          ListTile(
              title: const Text('提前几分钟提醒',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onTap: () {
                _show(context);
              },
              trailing: Text('$remindTime分钟'))
      ],
    ));
  }

  Future<void> _show(BuildContext context) async {
    final a = MediaQuery.of(context).size.width;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: a,
        minWidth: a,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumberPicker(
                    value: remindTime,
                    minValue: 10,
                    maxValue: 120,
                    step: 1,
                    onChanged: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('notification_time', value);
                      setStateBottomSheet(() {
                        remindTime = value;
                      });
                      // 可选：更新主页面的 remindTime
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class VersionSetting extends StatefulWidget {
  const VersionSetting({super.key});

  @override
  State<StatefulWidget> createState() => _VersionSettingState();
}

class _VersionSettingState extends State<VersionSetting> {
  late bool updateIgnored = false;
  late bool isNeedUpdate = false;
  late String version = '';

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        version = packageInfo.version;
        SharedPreferences.getInstance().then((prefs) {
          updateIgnored = prefs.getBool('update_ignored') ?? false;
        });
        GiteeService.getReleases().then((release) {
          isNeedUpdate = release.name != version;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text(
              '版本',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(version,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey)),
            trailing: isNeedUpdate
                ? Badge(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.update),
                  )
                : Icon(Icons.verified),
            onTap: () {
              if (isNeedUpdate) {
                showDialog(
                    context: context,
                    builder: (b) {
                      return AlertDialog(
                        title: const Text('是否更新新版本'),
                        actions: [
                          TextButton(
                            child: const Text('是的'),
                            onPressed: () async {
                              Navigator.of(b).pop();
                              final a = await GiteeService.getReleases();
                              if (context.mounted) {
                                UpdateManager.showUpdateWithProgress(
                                    context, a.name);
                              }
                            },
                          ),
                          TextButton(
                            child: const Text('不要'),
                            onPressed: () {
                              Navigator.of(b).pop();
                            },
                          ),
                        ],
                      );
                    });
              }
            },
          ),
          ListTile(
            title: const Text('更新日志',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: const Text(
              '忽略版本更新',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey),
            ),
            trailing: CupertinoSwitch(
              value: updateIgnored,
              onChanged: (bool value) async {
                setState(() {
                  updateIgnored = value;
                });
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool('update_ignored', value);
              },
            ),
          )
        ],
      ),
    );
  }
}

class TodoListSetting extends StatefulWidget {
  const TodoListSetting({super.key});

  @override
  State<StatefulWidget> createState() => _TodoListSettingState();
}

class _TodoListSettingState extends State<TodoListSetting> {
  late bool isUpdateToClub = false;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isUpdateToClub = prefs.getBool('is_update_club') ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: const Text('是否将待办保存至云端',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: const Text(
        '将待办事务保存至社团官网',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
      ),
      trailing: CupertinoSwitch(
        value: isUpdateToClub,
        onChanged: (bool value) async {
          setState(() {
            isUpdateToClub = value;
          });
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('is_update_club', value);
          if (value) {
            await TodoService.nowToUpdate();
          }
        },
      ),
    ));
  }
}

class HomePageSetting extends StatefulWidget {
  const HomePageSetting({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageSettingState();
}

class _HomePageSettingState extends State<HomePageSetting> {
  int _pageIndex = 0;
  final List<String> _pageNames = [
    '首页',
    '课程页',
    '成绩页',
    '个人页',
  ];

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _pageIndex = prefs.getInt('page_index') ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('打开应用的第一个页面',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: Text(_pageNames[_pageIndex]),
        onTap: () => _showDialog(CupertinoPicker(
          magnification: 1.22,
          squeeze: 1.2,
          useMagnifier: true,
          itemExtent: 32.0,
          // This sets the initial item.
          scrollController:
              FixedExtentScrollController(initialItem: _pageIndex),
          // This is called when selected item is changed.
          onSelectedItemChanged: (int selectedItem) {
            setState(() {
              _pageIndex = selectedItem;
            });
            SharedPreferences.getInstance().then((prefs) {
              prefs.setInt('page_index', selectedItem);
            });
          },
          children: List.generate(_pageNames.length, (int index) {
            return Center(child: Text(_pageNames[index]));
          }),
        )),
      ),
    );
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(top: false, child: child),
      ),
    );
  }
}
