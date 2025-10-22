import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/system_services/notification_service.dart';
import 'package:numberpicker/numberpicker.dart';

class RemindSetting extends StatefulWidget {
  const RemindSetting({super.key});

  @override
  State<StatefulWidget> createState() => _RemindSettingState();
}

class _RemindSettingState extends State<RemindSetting> {
  final SettingsStore settingsStore = SettingsStore.to;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '课程通知',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '上课前进行提醒',
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
                      value: settingsStore.isRemind,
                      onChanged: (bool value) async {
                        await settingsStore.setIsRemind(value);
                        if (value && context.mounted) {
                          await NotificationService.set(context);
                        }
                      },
                    ))
              ],
            )),
        Obx(
          () => settingsStore.isRemind
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '提前几分钟提醒',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Text('${settingsStore.remindTime}分钟')
                          ],
                        ),
                      ),
                      onTap: () {
                        _show(context);
                      }),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _show(BuildContext context) async {
    final a = MediaQuery.of(context).size.width;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: a,
        minWidth: a,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => NumberPicker(
                        value: settingsStore.remindTime,
                        minValue: 10,
                        maxValue: 120,
                        step: 1,
                        onChanged: (value) async {
                          await settingsStore.setRemindTime(value);
                        },
                      ))
                ],
              ),
            );
          },
        );
      },
    );
  }
}