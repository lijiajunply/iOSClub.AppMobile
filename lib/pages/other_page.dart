import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/tile_service.dart';
import '../widgets/blur_widget.dart';

class OtherPage extends StatefulWidget {
  const OtherPage({super.key});

  @override
  State<OtherPage> createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  /// 是否有电费数据
  bool isHasData = false;
  double electricity = 0;
  final TextEditingController _urlController = TextEditingController();
  List<String> _tiles = [];

  @override
  void initState() {
    super.initState();
    TileService.getTextAfterKeyword().then((value) {
      setState(() {
        if (value != null) {
          electricity = value;
          isHasData = true;
        }
        TileService.getTiles().then((t) {
          _tiles = t;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('其他'),
        flexibleSpace: BlurWidget(child: SizedBox.expand()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Text('查看电费',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Card(
              child: ListTile(
                title: Text(
                  isHasData ? '刷新/更换房间' : '获取电费',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle:
                    isHasData ? Text('当前电费：$electricity 元') : Text('点击开始获取电费'),
                trailing: Icon(Icons.refresh),
                onTap: () async {
                  if (isHasData) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(title: Text('刷新/更换房间'), actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('取消')),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showInputDialog();
                                },
                                child: Text('更换房间')),
                            TextButton(
                                onPressed: () async {
                                  final value =
                                      await TileService.getTextAfterKeyword();
                                  if (value != null) {
                                    setState(() {
                                      electricity = value;
                                      isHasData = true;
                                    });
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text('刷新数据'))
                          ]);
                        });
                  } else {
                    _showInputDialog();
                  }
                },
              ),
            ),
            if (isHasData)
              Card(
                child: ListTile(
                  title: Text('添加到首页',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text('将电费添加到首页磁贴'),
                  trailing: CupertinoSwitch(
                    onChanged: (bool value) async {
                      setState(() {
                        if (value) {
                          _tiles = [..._tiles, '电费'];
                        } else {
                          _tiles =
                              _tiles.where((tile) => tile != '电费').toList();
                        }
                      });

                      await TileService.setTiles(_tiles);
                    },
                    value: _tiles.contains('电费'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showInputDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('获取电费'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('获取电费需要手动操作,请按照以下步骤操作:'),
                  const SizedBox(height: 8),
                  Text('第一步: 打开建大财务处的电费详情页面;'),
                  Text('第二步: 点击右上角的三个点,复制此页面的Url'),
                  Text('第三步: 将Url粘贴到输入框中,点击确定即可获取到电费'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Url'),
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      _urlController.clear();
                      if (isHasData) {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.remove('electricity_url');
                        setState(() {
                          electricity = 0;
                          isHasData = false;
                        });
                      }
                    },
                    child: Text('取消')),
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      final value = await TileService.getTextAfterKeyword(
                          url: _urlController.text);
                      if (value != null) {
                        _urlController.clear();
                        setState(() {
                          electricity = value;
                          isHasData = true;
                        });
                      }
                    },
                    child: Text('确定')),
              ]);
        });
  }
}
