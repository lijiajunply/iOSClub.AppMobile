import 'package:flutter/material.dart';

import '../Services/DataService.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  final List<ScheduleItem> scheduleItems = [];

  @override
  initState() {
    super.initState();
    final dataService = DataService();
    dataService.getScore().then((value) {
      setState(() {
        scheduleItems.addAll(value.map((course) => ScheduleItem(
          title: course.lessonName,
          time: course.gradeDetail,
          location: course.grade,
          color: Colors.blue,
        )));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: scheduleItems.map((item) => _buildScheduleItem(item)).toList(),
          )),
    );
  }

  Widget _buildScheduleItem(ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(item.time, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(item.location,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleItem {
  final String title;
  final String time;
  final String location;
  final Color color;

  ScheduleItem({
    required this.title,
    required this.time,
    required this.location,
    required this.color,
  });
}
