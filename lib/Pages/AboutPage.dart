import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: Center(
          child: Padding(
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
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(
                    height: 16,
                  ),
                  const Card(
                    child: ListTile(
                      title: Text(
                        '版本',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: Text('1.1.0',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Card(
                    child: ListTile(
                      title: Text('制作团队',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
              ))),
    );
  }

  Future<void> _showClubDescription(BuildContext context) {
    final a = MediaQuery.of(context).size.width;

    return showModalBottomSheet<void>(
        context: context,
        constraints: BoxConstraints(maxWidth: a, minWidth: a),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
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
