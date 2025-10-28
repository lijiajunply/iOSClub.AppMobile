import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/net/git_service.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/system_services/android/download_service.dart';
import 'package:ios_club_app/widgets/platform_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:ios_club_app/system_services/check_update_manager.dart';

class VersionSetting extends StatefulWidget {
  const VersionSetting({super.key});

  @override
  State<StatefulWidget> createState() => _VersionSettingState();
}

class _VersionSettingState extends State<VersionSetting> {
  final SettingsStore settingsStore = SettingsStore.to;
  late bool isNeedUpdate = false;
  late String version = '';
  late String newVersion = '';
  int tapCount = 0;
  DateTime? lastTapTime;

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        version = packageInfo.version;
        if (!kIsWeb && Platform.isAndroid) {
          CheckUpdateManager.checkForUpdates().then((res) {
            isNeedUpdate = res.$1;
            if (res.$1) {
              newVersion = res.$2.name;
            }
          });
        }
      });
    });
  }

  void _handleTap() {
    final now = DateTime.now();
    if (lastTapTime == null || now.difference(lastTapTime!) > const Duration(seconds: 1)) {
      // 重置计数器
      tapCount = 0;
    }
    
    tapCount++;
    lastTapTime = now;
    
    if (tapCount >= 5) {
      // 显示彩蛋页面
      Get.toNamed('/Egg');
      
      // 重置计数器
      tapCount = 0;
      lastTapTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    isNeedUpdate
                        ? Badge(
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.update,
                              size: 20,
                            ),
                          )
                        : Icon(Icons.verified, size: 20, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '版本',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(version,
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                _handleTap(); // 处理点击事件
                
                if (isNeedUpdate) {
                  final result = await PlatformDialog.showConfirmDialog(
                    context,
                    title: '是否更新最新版本: $newVersion',
                    content: '发现新版本可用，是否立即更新？',
                    confirmText: '是的',
                    cancelText: '不要',
                  );

                  if (result == true) {
                    final a = await GiteeService.getReleases();
                    if (context.mounted) {
                      UpdateManager.showUpdateWithProgress(context, a.name);
                    }
                  }
                }
              }),
        ),
        if (CheckUpdateManager.shouldCheckForUpdates())
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.update,
                  size: 20,
                  color: Colors.amber,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '更新日志',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '忽略版本更新',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Obx(() => CupertinoSwitch(
                      value: settingsStore.updateIgnored,
                      onChanged: (bool value) async {
                        await settingsStore.setUpdateIgnored(value);
                      },
                    ))
              ],
            ),
          ),
      ],
    );
  }
}