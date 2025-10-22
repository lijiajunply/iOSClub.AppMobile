import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/services/todo_service.dart';
import 'package:ios_club_app/stores/settings_store.dart';

class TodoListSetting extends StatefulWidget {
  const TodoListSetting({super.key});

  @override
  State<StatefulWidget> createState() => _TodoListSettingState();
}

class _TodoListSettingState extends State<TodoListSetting> {
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
              CupertinoIcons.cloud_upload_fill,
              size: 20,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '是否将待办保存至云端',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '将待办事务保存至社团官网',
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
                  value: settingsStore.isUpdateToClub,
                  onChanged: (bool value) async {
                    await settingsStore.setIsUpdateToClub(value);
                    if (value) {
                      await TodoService.nowToUpdate();
                    }
                  },
                ))
          ],
        ));
  }
}