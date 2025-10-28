import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:ios_club_app/models/todo_item.dart';

import 'package:ios_club_app/services/todo_service.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/system_services/notification_service.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/empty_widget.dart';
import 'package:timezone/timezone.dart' as tz;

class TodoWidget extends StatefulWidget {
  const TodoWidget({super.key});

  @override
  State<StatefulWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  final List<TodoItem> _todos = [];
  final SettingsStore settingsStore = Get.find();

  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  Future<void> getTodoList() async {
    // final prefs = await SharedPreferences.getInstance();

    // final isUpdateToClub = prefs.getBool('is_update_club') ?? false;
    List<TodoItem> list = [];
    _todos.clear();
    list = await TodoService.getLocalTodoList();
    setState(() {
      _todos.addAll(list);
    });

    /*if (isUpdateToClub) {
      list = await TodoService.getClubTodoList();
      setState(() {
        _todos.addAll(list);
      });
    }*/
  }

  Future<void> scheduleTodoNotification(TodoItem todo) async {
    // 如果提醒功能未启用，直接返回
    if (!settingsStore.todoRemindEnabled) return;

    // 如果待办事项已完成，取消提醒
    if (todo.isCompleted) {
      await NotificationService.instance.notifications.cancel(todo.id.hashCode);
      return;
    }

    // 解析截止日期
    DateTime? deadline;
    try {
      deadline = DateFormat('yyyy-MM-dd HH:mm').parse(todo.deadline);
    } catch (e) {
      try {
        deadline = DateFormat('yyyy-MM-dd').parse(todo.deadline);
      } catch (e) {
        try {
          deadline = DateTime.parse(todo.deadline);
        } catch (e) {
          // 如果解析失败，不设置提醒
          return;
        }
      }
    }

    // 如果没有截止日期或已经过期，不设置提醒
    if (deadline.isBefore(DateTime.now())) {
      return;
    }

    // 设置提醒 - 提前1小时提醒
    final notificationTime = deadline.subtract(Duration(hours: 1));

    // 如果计算出的提醒时间已经过去，不设置提醒
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

    try {
      await NotificationService.instance.notifications.zonedSchedule(
        todo.id.hashCode, // 使用唯一ID作为通知ID
        '待办事项提醒',
        '您的待办事项 "${todo.title}" 将于${DateFormat('yyyy-MM-dd HH:mm').format(deadline)}到期',
        tzNotificationTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'ios_club_app_todo_reminders',
            '待办事项提醒',
            channelDescription: '待办事项截止前提醒',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'ios_club_app_todo_reminders',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling todo notification: $e');
    }
  }

  Future<void> updateTodoNotification(TodoItem todo) async {
    // 先取消之前的通知
    await NotificationService.instance.notifications.cancel(todo.id.hashCode);
    // 再根据新状态决定是否重新安排通知
    await scheduleTodoNotification(todo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '待办事务',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      TodoItem? newItem = await showAddTodoDialog(context);

                      if (newItem != null) {
                        setState(() {
                          _todos.add(newItem);
                        });
                        await TodoService.setTodoList(_todos);
                        // 添加新待办时安排提醒
                        await scheduleTodoNotification(newItem);
                      }
                    },
                    icon: const Icon(Icons.add))
              ],
            )),
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: _todos.isEmpty
                ? const ClubCard(
                    child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: EmptyWidget(
                        title: '当前没有待办事务',
                        icon: Icons.done_all,
                        subtitle: '点击右上角添加待办事项'),
                  ))
                : ListView.builder(
                    // 关键是添加这些属性
                    shrinkWrap: true,
                    // 让 ListView 根据内容自适应高度
                    physics: const NeverScrollableScrollPhysics(),
                    // 禁用 ListView 自身的滚动
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      DateTime? deadline;
                      try {
                        deadline =
                            DateFormat('yyyy-MM-dd HH:mm').parse(todo.deadline);
                      } catch (e) {
                        try {
                          deadline =
                              DateFormat('yyyy-MM-dd').parse(todo.deadline);
                        } catch (e) {
                          try {
                            deadline = DateTime.parse(todo.deadline);
                          } catch (e) {
                            deadline = null;
                          }
                        }
                      }

                      final now = DateTime.now();
                      final isBefore = deadline?.isBefore(now) ?? false;

                      return Column(
                        children: [
                          ListTile(
                            leading: Checkbox(
                              value: todo.isCompleted,
                              onChanged: (value) {
                                setState(() {
                                  todo.isCompleted = value!;
                                });
                                TodoService.setTodoList(_todos);
                                // 更新提醒状态
                                updateTodoNotification(todo);
                              },
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                '截止日期: ${deadline == null ? '无' : DateFormat('yyyy-MM-dd HH:mm').format(deadline)}',
                                style: TextStyle(
                                  decoration: isBefore
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                )),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                setState(() {
                                  _todos.removeAt(index);
                                });
                                // 删除时取消提醒
                                await NotificationService.instance.notifications
                                    .cancel(todo.id.hashCode);
                                await TodoService.setTodoList(_todos);
                              },
                            ),
                            onTap: () async {
                              var result =
                                  await showAddTodoDialog(context, todo: todo);
                              if (result != null) {
                                setState(() {
                                  _todos[index] = result;
                                });
                                await TodoService.setTodoList(_todos);
                                // 编辑时更新提醒
                                await updateTodoNotification(result);
                              }
                            },
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ))
      ],
    );
  }

  Future<TodoItem?> showAddTodoDialog(BuildContext context,
      {TodoItem? todo}) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();

    titleController.text = todo?.title ?? '';
    deadlineController.text = todo?.deadline ?? '';

    // 由于 PlatformDialog.showInputDialog 只返回字符串，我们需要使用自定义对话框
    return showDialog<TodoItem?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('添加待办', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: '标题',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '标题是必须项';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: deadlineController,
                  decoration: InputDecoration(
                    labelText: '截止日期',
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null && context.mounted) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null && context.mounted) {
                            final dateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            deadlineController.text =
                                DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                          }
                        }
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '截至日期是必须项';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('取消',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: Text(todo == null ? '添加' : '更改',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final todoItem = TodoItem(
                    title: titleController.text,
                    deadline: deadlineController.text,
                    // 如果是新的待办事项，生成唯一ID；如果是编辑现有待办事项，保留原有ID
                    id: todo?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    isCompleted: todo?.isCompleted ?? false,
                  );
                  Navigator.of(context).pop(todoItem);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
