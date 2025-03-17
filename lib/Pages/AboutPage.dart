import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/GiteeService.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late bool updateIgnored = false;
  late bool isNeedUpdate = false;
  late String version = '';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        updateIgnored = prefs.getBool('update_ignored') ?? false;
      });
      GiteeService.getReleases().then((value) {
        setState(() {
          isNeedUpdate = value.name != version;
        });
      });
      PackageInfo.fromPlatform().then((value) {
        setState(() {
          version = value.version;
        });
      });
    });
  }

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
                height: 16,
              ),
              Card(
                child: ListTile(
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('正在下载更新...可以继续使用')),
                                    );

                                    GiteeService.updateApp(a.name);
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
              ),
              const SizedBox(
                height: 8,
              ),
              Card(
                  child: ListTile(
                title: const Text('更新日志',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Text(
                  '忽略版本更新',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey),
                ),
                trailing: Switch(
                  value: updateIgnored,
                  onChanged: (bool value) async {
                    setState(() {
                      updateIgnored = value;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('update_ignored', value);
                  },
                ),
              )),
              const SizedBox(
                height: 8,
              ),
              const Card(
                child: ListTile(
                  title: Text('制作团队',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(
                    'LuckyFish & 西建大iOS Club',
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
