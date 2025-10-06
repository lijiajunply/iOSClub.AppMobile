import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/models/bus_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/net/edu_service.dart';
import 'package:ios_club_app/system_services/tile_service.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/widgets/empty_widget.dart';

import '../net/new_bus_api.dart';

class SchoolBusPage extends StatefulWidget {
  const SchoolBusPage({super.key});

  @override
  State<SchoolBusPage> createState() => _SchoolBusPageState();
}

class _SchoolBusPageState extends State<SchoolBusPage>
    with SingleTickerProviderStateMixin {
  String? selectedDate;
  List<BusItem> busData = [];
  List<BusItem> todayBusData = [];
  bool isLoading = false;
  String? errorMessage;
  late TabController _tabController;
  final Map<String, String> availableDates = {};
  bool isCaoTang = true;

  bool isShowBus = false;
  List<String> _tiles = [];

  // 新增：是否使用新API的标志
  bool useNewApi = false;

  @override
  void initState() {
    super.initState();
    _generateWeeklyDates();

    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() async {
      if (_tabController.indexIsChanging) {
        selectedDate = availableDates.keys.elementAt(_tabController.index);
        await _fetchBusData();
      }
    });
    selectedDate = availableDates.isNotEmpty ? availableDates.keys.first : null;
    if (selectedDate != null) _fetchBusData(isInit: true);

    TileService.getTextAfterKeyword().then((value) {
      setState(() {
        TileService.getTiles().then((t) {
          _tiles = t;
          isShowBus = t.any((s) => s == '校车');
        });
      });
    });
  }

  void _generateWeeklyDates() {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      availableDates[DateFormat('yyyy-MM-dd').format(date)] =
          DateFormat('M月d日').format(date);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBusData({bool isInit = false}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      if (isInit) {
        final prefs = await SharedPreferences.getInstance();
        useNewApi = prefs.getBool(PrefsKeys.USE_NEW_BUS_API) ?? false;
      }
      BusModel data = BusModel(records: [], total: 0);
      if (useNewApi) {
        data = await getBusFromNewData(time: selectedDate, loc: 'ALL');
      } else {
        data = await EduService.getBus(dayDate: selectedDate);
      }

      todayBusData = data.records;
      if (isCaoTang) {
        data.records =
            todayBusData.where((bus) => bus.lineName.startsWith('草堂')).toList();
      } else {
        data.records =
            todayBusData.where((bus) => bus.lineName.startsWith('雁塔')).toList();
      }
      setState(() {
        busData = data.records;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '获取校车数据时出错: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: CupertinoButton(
            onPressed: () {
              setState(() {
                isCaoTang = !isCaoTang;
                if (isCaoTang) {
                  busData = todayBusData
                      .where((bus) => bus.lineName.startsWith("草堂"))
                      .toList();
                } else {
                  busData = todayBusData
                      .where((bus) => bus.lineName.startsWith("雁塔"))
                      .toList();
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isCaoTang ? '草堂校区' : '雁塔校区'),
                Icon(Icons.arrow_forward),
                Text(isCaoTang ? '雁塔校区' : '草堂校区')
              ],
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabAlignment: TabAlignment.start,
            tabs: availableDates.values.map((date) => Tab(text: date)).toList(),
            isScrollable: true,
            dividerColor: Colors.transparent,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _fetchBusData();
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                _showSettingsModalBottomSheet();
              },
            ),
          ],
        ),
        body: _buildBuses());
  }

  Widget _buildBuses() {
    if (isLoading) {
      return Center(
        child: ClubCard(
          margin: EdgeInsets.only(top: 40),
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (errorMessage != null) {
      return Center(
        child: ClubCard(
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.only(top: 40),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child:
                Text(errorMessage!, style: TextStyle(color: Colors.redAccent)),
          ),
        ),
      );
    } else if (busData.isNotEmpty) {
      return ListView.builder(
          itemCount: busData.length,
          itemBuilder: (context, index) {
            final bus = busData[index];

            var bottom = index == busData.length - 1 ? 12.0 : 0.0;

            return Padding(
              padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: bottom),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  child: ClubCard(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bus.departureStation,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  bus.runTime,
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                Text(bus.description,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold)),
                                Divider(
                                  thickness: 1,
                                ),
                                Text(bus.arrivalStationTime,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold))
                              ])),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                Text(
                                  bus.arrivalStation,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  bus.totalTime,
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold),
                                ),
                              ]))
                        ],
                      ),
                    ),
                  ),
                  onTap: () async {
                    await _showModalBottomSheet(bus);
                  },
                ),
              ),
            );
          });
    } else if (selectedDate != null) {
      return ClubCard(
          margin: EdgeInsets.all(20),
          child: EmptyWidget(
            title: '今天没有车了',
            subtitle: '明天再来吧',
            icon: Icons.directions_bus,
          ));
    }

    return Container();
  }

  // 新增：显示设置的底部弹窗
  Future<void> _showSettingsModalBottomSheet() async {
    await showClubModalBottomSheet(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '校车页面设置',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('是否显示校车磁贴'),
                trailing: CupertinoSwitch(
                  value: isShowBus,
                  onChanged: (bool value) async {
                    setState(() {
                      isShowBus = value;
                    });
                    if (isShowBus) {
                      _tiles.add("校车");
                    } else {
                      _tiles.remove("校车");
                    }

                    TileService.setTiles(_tiles);
                  },
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('是否使用新API'),
                subtitle: const Text('新的API接口只能在校园网内使用'),
                trailing: CupertinoSwitch(
                  value: useNewApi,
                  onChanged: (bool value) async {
                    setState(() {
                      useNewApi = value;
                    });

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(PrefsKeys.USE_NEW_BUS_API, useNewApi);

                    // 切换API后重新获取数据
                    _fetchBusData();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showModalBottomSheet(BusItem bus) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    var content = Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bus.lineName,
              style: const TextStyle(
                fontSize: 20,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 10 : 18),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.blue,
                ),
                const SizedBox(width: 6),
                Text(
                  '出发时间: ${bus.runTime}',
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 10 : 18),
            Row(children: [
              const Icon(
                Icons.location_on,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 6),
              Text(
                '终点: ${bus.arrivalStation}',
                style: TextStyle(
                  fontSize: isTablet ? 17 : 15,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
            SizedBox(height: isTablet ? 10 : 18),
            Row(children: [
              const Icon(
                Icons.grade,
                color: Colors.green,
              ),
              const SizedBox(width: 6),
              Text(
                '预计时间: ${bus.arrivalStationTime}',
                style: TextStyle(
                  fontSize: isTablet ? 17 : 15,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            SizedBox(height: isTablet ? 10 : 18),
            Row(children: [
              const Icon(
                Icons.details,
                color: Colors.green,
              ),
              const SizedBox(width: 6),
              Expanded(
                // 添加 Expanded
                child: Text(
                  '校车信息: ${bus.description}',
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis, // 添加省略号
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 15,
                  ),
                ),
              ),
            ]),
          ],
        ));

    if (isTablet) {
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[content],
            );
          });
    }

    return showClubModalBottomSheet(context, content);
  }
}
