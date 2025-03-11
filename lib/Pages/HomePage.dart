import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/Services/DataService.dart';
import 'package:ios_club_app/Widgets/ExamCard.dart';
import '../Models/TodoItem.dart';
import '../Widgets/PageHeaderDelegate.dart';
import '../Widgets/ScheduleCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<TodoItem> _todos = [];

  @override
  void initState() {
    super.initState();
    final data = DataService();
    data.getTodoList().then((value) {
      setState(() {
        _todos.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 课表部分
          SliverPersistentHeader(
            pinned: true, // 设置为true使其具有粘性
            delegate: PageHeaderDelegate(
              title: '今日课表',
              minHeight: 66,
              maxHeight: 80,
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: ScheduleCard(),
            ),
          ),
          // 考试列表
          SliverPersistentHeader(
            pinned: true,
            delegate: PageHeaderDelegate(
              title: '近期考试',
              minHeight: 66,
              maxHeight: 80,
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: ExamCard(),
            ),
          ),
          //
          SliverPersistentHeader(
            pinned: true,
            delegate: PageHeaderDelegate(
              title: '待办事务',
              minHeight: 66,
              maxHeight: 80,
              icon: const Icon(Icons.add),
              onPressed: () async {
                TodoItem? newItem = await showAddTodoDialog(context);

                if (newItem != null) {
                  setState(() {
                    _todos.add(newItem);
                  });
                  final data = DataService();
                  await data.setTodoList(_todos);
                }
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
                child: ListView.builder(
              // 关键是添加这些属性
              shrinkWrap: true,
              // 让 ListView 根据内容自适应高度
              physics: const NeverScrollableScrollPhysics(),
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
                      },
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text('截止日期: ${todo.deadline}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        setState(() {
                          _todos.removeAt(index);
                        });
                        final data = DataService();
                        await data.setTodoList(_todos);
                      },
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  Future<TodoItem?> showAddTodoDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();

    return showDialog<TodoItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加待办',style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '标题'),
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
              child: const Text('取消',style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('添加',style: TextStyle(fontWeight: FontWeight.bold)),
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