import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/system_services/notification_service.dart';

class TodoRemindSetting extends StatefulWidget {
  const TodoRemindSetting({super.key});

  @override
  State<StatefulWidget> createState() => _TodoRemindSettingState();
}

class _TodoRemindSettingState extends State<TodoRemindSetting> {
  final SettingsStore settingsStore = SettingsStore.to;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.notifications_active,
              size: 20,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '待办事务提醒',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '在待办事务截止前进行提醒',
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
                  value: settingsStore.todoRemindEnabled,
                  onChanged: (bool value) async {
                    await settingsStore.setTodoRemindEnabled(value);
                    if (value && context.mounted) {
                      await NotificationService.set(context);
                    }
                  },
                ))
          ],
        ));
  }
}
