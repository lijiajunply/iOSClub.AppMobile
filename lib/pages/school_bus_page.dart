import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/controllers/bus_controller.dart';
import 'package:ios_club_app/models/bus_model.dart' show BusItem;
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/widgets/empty_widget.dart';

class SchoolBusPage extends StatelessWidget {
  const SchoolBusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BusController busController = Get.put(BusController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => CupertinoButton(
              onPressed: busController.toggleCampus,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(busController.isCaoTang.value ? '草堂校区' : '雁塔校区'),
                  Icon(Icons.arrow_forward),
                  Text(busController.isCaoTang.value ? '雁塔校区' : '草堂校区')
                ],
              ),
            )),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: busController.tabController,
            tabAlignment: TabAlignment.start,
            tabs: busController.availableDates.values
                .map((date) => Tab(text: date))
                .toList(),
            isScrollable: true,
            dividerColor: Colors.transparent,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: busController.refreshData,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettingsModalBottomSheet(busController),
          ),
        ],
      ),
      body: _buildBuses(busController),
    );
  }

  Widget _buildBuses(BusController busController) {
    return Obx(() {
      if (busController.isLoading.value) {
        return Center(
          child: ClubCard(
            margin: EdgeInsets.only(top: 40),
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (busController.errorMessage.value.isNotEmpty) {
        return Center(
          child: ClubCard(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.only(top: 40),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(busController.errorMessage.value,
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        );
      } else if (busController.busData.isNotEmpty) {
        return ListView.builder(
            itemCount: busController.busData.length,
            itemBuilder: (context, index) {
              final bus = busController.busData[index];

              var bottom =
                  index == busController.busData.length - 1 ? 12.0 : 0.0;

              return Padding(
                padding: EdgeInsets.only(
                    top: 12, left: 12, right: 12, bottom: bottom),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                      await _showModalBottomSheet(context, bus);
                    },
                  ),
                ),
              );
            });
      } else if (busController.selectedDate.value.isNotEmpty) {
        return Center(
          child: ClubCard(
              margin: EdgeInsets.all(20),
              child: EmptyWidget(
                title: '今天没有车了',
                subtitle: '明天再来吧',
                icon: Icons.directions_bus,
              )),
        );
      }

      return Container();
    });
  }

  // 新增：显示设置的底部弹窗
  Future<void> _showSettingsModalBottomSheet(
      BusController busController) async {
    await showClubModalBottomSheet(
      Get.context!,
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
              Obx(() => ListTile(
                    title: const Text('是否显示校车磁贴'),
                    trailing: CupertinoSwitch(
                      value: busController.isShowBus.value,
                      onChanged: (bool value) async {
                        busController.toggleShowBus(value);
                      },
                    ),
                  )),
              const SizedBox(height: 10),
              Obx(() => ListTile(
                    title: const Text('是否使用新API'),
                    subtitle: const Text('新的API接口只能在校园网内使用'),
                    trailing: CupertinoSwitch(
                      value: busController.useNewApi.value,
                      onChanged: (bool value) async {
                        busController.toggleUseNewApi(value);
                      },
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showModalBottomSheet(BuildContext context, BusItem bus) {
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
