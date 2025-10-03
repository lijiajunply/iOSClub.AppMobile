import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/models/todo_item.dart';

import 'package:ios_club_app/services/todo_service.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/empty_widget.dart';

class TodoWidget extends StatefulWidget {
  const TodoWidget({super.key});

  @override
  State<StatefulWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  final List<TodoItem> _todos = [];

  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  Future<void> getTodoList() async {
    final prefs = await SharedPreferences.getInstance();

    final isUpdateToClub = prefs.getBool('is_update_club') ?? false;
    List<TodoItem> list = [];
    _todos.clear();
    list = await TodoService.getLocalTodoList();
    setState(() {
      _todos.addAll(list);
    });

    if (isUpdateToClub) {
      list = await TodoService.getClubTodoList();
      setState(() {
        _todos.addAll(list);
      });
    }
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
                      final deadline =
                          DateFormat('yyyy-MM-dd').parse(todo.deadline);
                      final now = DateTime.now();
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
                            subtitle: Text('截止日期: ${todo.deadline}',
                                style: TextStyle(
                                  decoration: deadline.isBefore(now)
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                )),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                setState(() {
                                  _todos.removeAt(index);
                                });
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

  Future<TodoItem?> showAddTodoDialog(BuildContext context, {TodoItem? todo}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();

    titleController.text = todo?.title ?? '';
    deadlineController.text = todo?.deadline ?? '';

    return showDialog<TodoItem>(
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
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          deadlineController.text =
                              DateFormat('yyyy-M-d').format(picked);
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(todo == null ? '添加' : '更改',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final todo = TodoItem(
                    title: titleController.text,
                    deadline: deadlineController.text,
                  );
                  Navigator.of(context).pop(todo);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
