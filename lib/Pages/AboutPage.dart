import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: const Center(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  Image(
                    image: AssetImage('assets/icon.png'),
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Center(
                      child: Text(
                    'iOS Club App',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  )),
                  SizedBox(
                    height: 16,
                  ),
                  Card(
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
                  SizedBox(
                    height: 8,
                  ),
                  Card(
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
                  SizedBox(
                    height: 8,
                  ),
                  Card(
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
                ],
              ))),
    );
  }
}
