import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<TodoItem> _todos = [
    TodoItem(title: '准备周五的摄影展', deadline: '2024-03-15'),
    TodoItem(title: '收集社员反馈表', deadline: '2024-03-12'),
    TodoItem(title: '整理活动照片', deadline: '2024-03-10'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 关键是添加这些属性
      shrinkWrap: true, // 让 ListView 根据内容自适应高度
      physics: const NeverScrollableScrollPhysics(), // 禁用 ListView 自身的滚动
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
              onPressed: () {
                setState(() {
                  _todos.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }
}

class TodoItem {
  String title;
  String deadline;
  bool isCompleted;

  TodoItem({
    required this.title,
    required this.deadline,
    this.isCompleted = false,
  });
}