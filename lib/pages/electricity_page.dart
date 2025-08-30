import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import '../Services/tile_service.dart';
import '../pageModels/ElectricData.dart';
import '../widgets/ClubAppBar.dart';
import '../widgets/ClubCard.dart';
import '../widgets/empty_widget.dart';

class ElectricityPage extends StatefulWidget {
  const ElectricityPage({super.key});

  @override
  State<ElectricityPage> createState() => _ElectricityPageState();
}

class _ElectricityPageState extends State<ElectricityPage> {
  bool isHasData = false;
  double electricity = 0;
  final TextEditingController _urlController = TextEditingController();
  List<String> _tiles = [];

  @override
  void initState() {
    super.initState();
    _loadElectricityData();
  }

  Future<void> _loadElectricityData() async {
    try {
      final value = await TileService.getTextAfterKeyword();
      final tiles = await TileService.getTiles();

      setState(() {
        if (value != null) {
          electricity = value;
          isHasData = true;
        }
        _tiles = tiles;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ClubAppBar(
          title: '电费管理',
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 当前电费卡片
              _buildCurrentElectricityCard(),

              SizedBox(height: 20),

              // 电费图表卡片
              if (isHasData) _buildChartCard(),

              if (isHasData) SizedBox(height: 20),

              // 设置选项
              _buildSettingsSection(),
            ],
          ),
        ));
  }

  Widget _buildCurrentElectricityCard() {
    return ClubCard(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.bolt_fill,
                    color: CupertinoColors.systemBlue,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '当前电费',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _handleElectricityAction,
                  child: Icon(
                    isHasData ? CupertinoIcons.refresh : CupertinoIcons.add,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (isHasData) ...[
              Text(
                '¥${electricity.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '余额充足',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Text(
                '暂无数据',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '点击右上角添加电费数据',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return ClubCard(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '用电趋势',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Text(
                  '今日',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: FutureBuilder(
                future: TileService.getElectricityWeeklyData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '加载失败',
                      ),
                    );
                  }
                  return _buildChart(snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<ElectricData> data) {
    if (data.isEmpty) {
      return Center(
        child: EmptyWidget(
          title: '没有数据',
          subtitle: '',
          icon: Icons.hourglass_empty,
        ),
      );
    }
    double dataMaxValue = data.map((e) => e.value).reduce(max);
    final calculatedMaxY = dataMaxValue.ceilToDouble() * 1.2;

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) =>
                CupertinoColors.systemBlue.withOpacity(0.8),
            tooltipPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)}元',
                TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                );
                final hour = data[value.toInt()].timestamp.hour;
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text('${hour}h', style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data
            .asMap()
            .map((index, electricData) {
              return MapEntry(
                index,
                BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: electricData.value,
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemBlue.withOpacity(0.3),
                          CupertinoColors.systemBlue,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            })
            .values
            .toList(),
        gridData: FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: calculatedMaxY,
      ),
    );
  }

  Widget _buildSettingsSection() {
    return ClubCard(
      child: Column(
        children: [
          if (isHasData) ...[
            ListTile(
              leading: Icon(Icons.home),
              title: Text('添加到首页'),
              subtitle: Text('在首页显示电费磁贴'),
              trailing: CupertinoSwitch(
                value: _tiles.contains('电费'),
                onChanged: (value) async {
                  setState(() {
                    if (value) {
                      _tiles = [..._tiles, '电费'];
                    } else {
                      _tiles = _tiles.where((tile) => tile != '电费').toList();
                    }
                  });
                  await TileService.setTiles(_tiles);
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.monetization_on_outlined),
              title: Text('电费充值'),
              subtitle: Text('跳转至浏览器进行电费充值'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                var url = prefs.getString('electricity_url') ?? '';
                url = url.replaceAll('wxAccount', 'wxCharge');
                await TileService.openInWeChat(url);
              },
            )
          ],
        ],
      ),
    );
  }

  void _handleElectricityAction() {
    if (isHasData) {
      _showRefreshDialog();
    } else {
      _showInputDialog();
    }
  }

  void _showRefreshDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('电费管理'),
        content: Text('选择要执行的操作'),
        actions: [
          CupertinoDialogAction(
            child: Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: Text('更换房间'),
            onPressed: () {
              Navigator.of(context).pop();
              _showInputDialog();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              final value = await TileService.getTextAfterKeyword();
              if (value != null) {
                setState(() {
                  electricity = value;
                  isHasData = true;
                });
              }
            },
            child: Text('刷新数据'),
          ),
        ],
      ),
    );
  }

  void _showInputDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('获取电费'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              '请按照以下步骤操作：\n\n1. 打开建大财务处电费详情页面\n2. 复制页面URL\n3. 粘贴到下方输入框',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            CupertinoTextField(
              controller: _urlController,
              placeholder: '请输入URL',
              padding: EdgeInsets.all(12),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
              _urlController.clear();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              final value = await TileService.getTextAfterKeyword(
                url: _urlController.text,
              );
              if (value != null) {
                _urlController.clear();
                setState(() {
                  electricity = value;
                  isHasData = true;
                });
              }
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
