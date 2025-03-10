import 'package:flutter/material.dart';
import 'package:ios_club_app/Models/CourseColorManager.dart';
import 'package:ios_club_app/Services/TimeService.dart';

import '../Services/DataService.dart';

class ScheduleCard extends StatefulWidget {
  const ScheduleCard({super.key});

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  final List<ScheduleItem> scheduleItems = [];

  @override
  initState() {
    super.initState();
    final dataService = DataService();
    dataService.getCourse().then((value) {
      setState(() {
        scheduleItems.addAll(value.map((course) {
          var startTime = "";
          var endTime = "";
          if (course.room.substring(0, 2) == "草堂") {
            startTime = TimeService.CanTangTime[course.startUnit];
            endTime = TimeService.CanTangTime[course.endUnit];
          } else {
            final now = DateTime.now();
            if (now.month >= 5 && now.month <= 10) {
              startTime = TimeService.YanTaXia[course.startUnit];
              endTime = TimeService.YanTaXia[course.endUnit];
            } else {
              startTime = TimeService.YanTaDong[course.startUnit];
              endTime = TimeService.YanTaDong[course.endUnit];
            }
          }
          return ScheduleItem(
            title: course.courseName,
            time:
                '第${course.startUnit}节 ~ 第${course.endUnit}节 | $startTime~$endTime',
            location: course.room,
          );
        }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: scheduleItems.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                  child: Text(
                '今天没有课了',
                style: TextStyle(fontSize: 20),
              )),
            )
          : Column(
              children: scheduleItems.map(_buildScheduleItem).toList(),
            ),
    );
  }

  Widget _buildScheduleItem(ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: CourseColorManager.generateSoftColor(item.location),
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
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(item.time,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(item.location,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
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

  ScheduleItem({
    required this.title,
    required this.time,
    required this.location,
  });
}
