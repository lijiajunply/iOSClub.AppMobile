import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/widgets/club_modal_bottom_sheet.dart';

class HomePageSetting extends StatefulWidget {
  const HomePageSetting({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageSettingState();
}

class _HomePageSettingState extends State<HomePageSetting> {
  final SettingsStore settingsStore = SettingsStore.to;
  final List<String> _pageNames = [
    '首页',
    '课程页',
    '成绩页',
    '个人页',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Icon(
                  Icons.pageview,
                  size: 20,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '打开应用的第一个页面',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Obx(() => Text(_pageNames[settingsStore.pageIndex])),
                const SizedBox(width: 4),
              ],
            )),
        onTap: () => showClubModalBottomSheet(
          context,
          SizedBox(
            height: 200, // 给 CupertinoPicker 固定高度
            child: Obx(() => CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                      initialItem: settingsStore.pageIndex),
                  onSelectedItemChanged: (int selectedItem) {
                    settingsStore.setPageIndex(selectedItem);
                  },
                  children: List.generate(_pageNames.length, (int index) {
                    return Center(child: Text(_pageNames[index]));
                  }),
                )),
          ),
        ),
      ),
    );
  }
}