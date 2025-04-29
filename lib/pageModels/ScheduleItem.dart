class ScheduleItem {
  final String title;
  final String time;
  final String location;

  ScheduleItem({
    required this.title,
    required this.time,
    required this.location,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      title: json['title'],
      time: json['time'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'time': time,
      'location': location,
    };
  }
}