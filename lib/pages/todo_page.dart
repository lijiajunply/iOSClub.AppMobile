import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/TodoItem.dart';
import '../services/todo_service.dart';
import '../widgets/blur_widget.dart';
import '../widgets/empty_widget.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late List<TodoItem> _todos = [];

  @override
  void initState() {
    super.initState();

    TodoService.getTodoList().then((value) {
      setState(() {
        _todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('待办事务'),
          flexibleSpace: BlurWidget(child: SizedBox.expand()),
        ),
        body: Padding(
            padding: EdgeInsets.all(16),
            child: _todos.isEmpty
                ? SizedBox(
                    height: 240,
                    child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              EmptyWidget(),
                              Center(
                                  child: Text(
                                    '当前没有待办事务',
                                    style: TextStyle(fontSize: 20),
                                  ))
                            ],
                          ),
                        )),
                  )
                : ListView.builder(
                    // 禁用 ListView 自身的滚动
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
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
                          subtitle: Text('截止日期: ${todo.deadline}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              setState(() {
                                _todos.removeAt(index);
                              });

                              await TodoService.setTodoList(_todos);
                            },
                          ),
                        ),
                      );
                    },
                  )),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            TodoItem? newItem = await showAddTodoDialog(context);

            if (newItem != null) {
              setState(() {
                _todos.add(newItem);
              });

              await TodoService.setTodoList(_todos);
            }
          },
          tooltip: '添加待办',
          child: const Icon(Icons.add),
        ));
  }

  Future<TodoItem?> showAddTodoDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();

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
              child: const Text('添加',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
