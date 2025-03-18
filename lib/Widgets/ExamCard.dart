import 'package:flutter/material.dart';
import 'package:ios_club_app/PageModels/CourseColorManager.dart';

import '../Services/DataService.dart';

class ExamCard extends StatefulWidget {
  const ExamCard({super.key});

  @override
  State<ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  final List<ExamItem> examItems = [];

  @override
  initState() {
    super.initState();

    DataService.getExam().then((value) {
      setState(() {
        examItems.addAll(value.map((course) => ExamItem(
              title: course.name,
              time: course.examTime,
              location: course.room,
              color: CourseColorManager.generateSoftColor(course),
              seat: course.seatNo,
            )));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return examItems.isEmpty
        ? const Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                  child: Text(
                '最近没有考试',
                style: TextStyle(fontSize: 20),
              )),
            ))
        : ListView.builder(
            shrinkWrap: true,
            // 让 ListView 根据内容自适应高度
            physics: const NeverScrollableScrollPhysics(),
            itemCount: examItems.length,
            itemBuilder: (context, index) {
              final exam = examItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: exam.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  title: Text(
                    exam.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Wrap(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(exam.time,
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(exam.location,
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Icon(Icons.event_seat,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('座位号 ${exam.seat}',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class ExamItem {
  final String title;
  final String time;
  final String location;
  final Color color;
  final String seat;

  ExamItem({
    required this.title,
    required this.time,
    required this.location,
    required this.color,
    required this.seat,
  });
}
