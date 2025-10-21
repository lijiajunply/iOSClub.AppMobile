import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:ios_club_app/stores/user_store.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modern_sidebar.dart';

Sidebar macosUISidebar({
  required List<SidebarDestination> items,
  required int selectedIndex,
  required Function(int) onItemSelected,
  double width = 200,
}) {
  final searchFieldController = TextEditingController();

  return Sidebar(
    snapToStartBuffer: width * 0.05,
    minWidth: width * 0.9,
    maxWidth: width * 1.1,
    top: MacosSearchField(
      placeholder: '搜索',
      controller: searchFieldController,
      onResultSelected: (result) {
        // 根据搜索结果导航到对应页面
        final routeMap = {
          '首页': '/',
          '课表': '/Schedule',
          '成绩': '/Score',
          '我的': '/Profile',
          '电费': '/Electricity',
          '校车': '/SchoolBus',
          '饭卡': '/Payment',
          '网络': '/Net',
          '成员': '/iMember',
          '链接': '/Link',
          '关于': '/About',
        };

        if (routeMap.containsKey(result.searchKey)) {
          Get.toNamed(routeMap[result.searchKey]!);
          // 清空搜索框
          searchFieldController.clear();
        }
      },
      results: const [
        SearchResultItem('首页'),
        SearchResultItem('课表'),
        SearchResultItem('成绩'),
        SearchResultItem('我的'),
        SearchResultItem('电费'),
        SearchResultItem('校车'),
        SearchResultItem('饭卡'),
        SearchResultItem('网络'),
        SearchResultItem('链接'),
        SearchResultItem('关于'),
      ],
    ),
    builder: (context, scrollController) {
      return SidebarItems(
        currentIndex: selectedIndex,
        scrollController: scrollController,
        itemSize: SidebarItemSize.large,
        onChanged: (index) {
          onItemSelected(index);
        },
        items: items.map((destination) {
          return SidebarItem(
            label: Text(destination.label),
            leading: MacosIcon(
              selectedIndex == items.indexOf(destination)
                  ? destination.selectedIcon
                  : destination.icon,
            ),
          );
        }).toList(),
      );
    },
    bottom: Obx(() {
      final UserStore userStore = UserStore.to;

      return MacosListTile(
        onClick: () {
          Get.toNamed('/Profile');
        },
        leading: MacosIcon(
          CupertinoIcons.profile_circled,
          size: 28,
        ),
        title: FutureBuilder(
            future: _getUsername(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }
              return Text('');
            }),
        subtitle: Text(
          userStore.isLogin && userStore.isLoginMember
              ? '教务系统账号 & iMember账号'
              : userStore.isLogin
                  ? '教务系统账号'
                  : userStore.isLoginMember
                      ? 'iMember账号'
                      : '未登录',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }),
  );
}

Future<String> _getUsername() async {
  final UserStore userStore = UserStore.to;
  final prefs = await SharedPreferences.getInstance();
  var name = '未登录';

  if (userStore.isLogin) {
    final iosName = prefs.getString(PrefsKeys.USERNAME);
    if (iosName != null) {
      name = iosName;
    }
  }

  if (userStore.isLoginMember) {
    final iosName = prefs.getString(PrefsKeys.CLUB_NAME);
    if (iosName != null) {
      name = iosName;
    }
  }

  return name;
}
