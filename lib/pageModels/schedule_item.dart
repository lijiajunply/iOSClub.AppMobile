class ScheduleItem {
  final String title;
  final String time;
  final String location;
  final String teacher;
  final String description;

  ScheduleItem({
    required this.title,
    required this.time,
    required this.location,
    required this.teacher,
    this.description = '',
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      title: json['title'],
      time: json['time'],
      location: json['location'],
      teacher: json['teacher'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'time': time,
      'location': location,
      'teacher': teacher,
    };
  }
}