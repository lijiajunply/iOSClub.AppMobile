import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/Services/DataService.dart';
import 'package:ios_club_app/Widgets/ExamCard.dart';
import '../Models/TodoItem.dart';
import '../Services/OtherService.dart';
import '../Widgets/EmptyWidget.dart';
import '../Widgets/PageHeaderDelegate.dart';
import '../Widgets/ScheduleCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<TodoItem> _todos = [];
  List<String> _tiles = [];

  @override
  void initState() {
    super.initState();
    DataService.getTodoList().then((value) {
      setState(() {
        _todos.addAll(value);
        OtherService.getTiles().then((value) {
          _tiles = value;
        });
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
              maxHeight: 76,
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            sliver: SliverToBoxAdapter(
              child: ScheduleCard(),
            ),
          ),
          if(_tiles.isNotEmpty)
            SliverPersistentHeader(
              pinned: true, // 设置为true使其具有粘性
              delegate: PageHeaderDelegate(
                title: '磁贴',
                minHeight: 66,
                maxHeight: 76,
              ),
            ),
          if (_tiles.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              sliver: SliverToBoxAdapter(
                child: GridView.custom(
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    pattern: [
                      // 动态生成模式
                      for (int i = 0; i < (_tiles.length / 2).floor(); i++)
                        const QuiltedGridTile(1, 1),
                      // 如果是奇数个元素，添加一个占满整行的元素
                      if (_tiles.length % 2 == 1) const QuiltedGridTile(1, 2),
                    ],
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) => buildTile(_tiles[index]),
                    childCount: _tiles.length,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                ),
              ),
            ),
          // 考试列表
          SliverPersistentHeader(
            pinned: true,
            delegate: PageHeaderDelegate(
              title: '近期考试',
              minHeight: 66,
              maxHeight: 76,
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
              maxHeight: 76,
              icon: const Icon(Icons.add),
              onPressed: () async {
                TodoItem? newItem = await showAddTodoDialog(context);

                if (newItem != null) {
                  setState(() {
                    _todos.add(newItem);
                  });
                  await DataService.setTodoList(_todos);
                }
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            sliver: SliverToBoxAdapter(
                child: _todos.isEmpty
                    ? const Card(
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
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Checkbox(
                                value: todo.isCompleted,
                                onChanged: (value) {
                                  setState(() {
                                    todo.isCompleted = value!;
                                  });
                                  DataService.setTodoList(_todos);
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
                                  await DataService.setTodoList(_todos);
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

Widget buildTile(String tile) {
  late Widget? a;

  if (tile == '电费') {
    a = FutureBuilder(
        future: OtherService.getTextAfterKeyword(),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '当前电费',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${snapshot.data ?? '...'} 元',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              snapshot.data! <= 20 ? Colors.redAccent : null),
                    ),
                    SizedBox()
                  ]),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  a ??= Container();

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: a,
  );
}
