import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/stores/settings_store.dart';

class ShowTomorrowSetting extends StatefulWidget {
  const ShowTomorrowSetting({super.key});

  @override
  State<StatefulWidget> createState() => _ShowTomorrowSettingState();
}

class _ShowTomorrowSettingState extends State<ShowTomorrowSetting> {
  final SettingsStore settingsStore = SettingsStore.to;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.calendar,
            size: 20,
            color: CupertinoColors.systemPurple,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '显示明日课程',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  '当今日无课时显示明日课程',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => CupertinoSwitch(
                value: settingsStore.isShowTomorrow,
                onChanged: (bool value) async {
                  await settingsStore.setIsShowTomorrow(value);
                },
              )),
        ],
      ),
    );
  }
}