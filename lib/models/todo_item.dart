class TodoItem {
  String title;
  String deadline;
  bool isCompleted;
  String? description;
  String? key;

  TodoItem({
    required this.title,
    required this.deadline,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'deadline': deadline,
        'isCompleted': isCompleted,
        'description': description,
        'key': key,
      };

  // 从 Map 创建对象（反序列化）
  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        title: json['title'],
        deadline: json['deadline'],
        isCompleted: json['isCompleted'] ?? false, // 默认值处理
      );
}
