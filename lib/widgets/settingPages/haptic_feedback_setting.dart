import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/stores/settings_store.dart';

// 添加触觉反馈设置组件
class HapticFeedbackSetting extends StatefulWidget {
  const HapticFeedbackSetting({super.key});

  @override
  State<HapticFeedbackSetting> createState() => _HapticFeedbackSettingState();
}

class _HapticFeedbackSettingState extends State<HapticFeedbackSetting> {
  final SettingsStore settingsStore = SettingsStore.to;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.vibration,
            size: 20,
            color: Colors.deepPurple,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '触觉反馈',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  '底部导航栏点击时震动',
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
                value: settingsStore.enableHapticFeedback,
                onChanged: (bool value) async {
                  await settingsStore.setEnableHapticFeedback(value);
                },
              ))
        ],
      ),
    );
  }
}