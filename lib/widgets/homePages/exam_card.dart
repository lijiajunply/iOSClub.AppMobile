import 'package:flutter/material.dart';
import 'package:ios_club_app/PageModels/CourseColorManager.dart';

import '../../models/ExamModel.dart';
import '../../services/exam_service.dart';
import '../empty_widget.dart';

class ExamCard extends StatefulWidget {
  const ExamCard({super.key});

  @override
  State<StatefulWidget> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  List<ExamData> examItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    ExamService.getExam().then((result) => setExam(result));
  }

  void setExam(List<ExamItem> result) {
    setState(() {
      examItems = result
          .map((course) => ExamData(
        title: course.name,
        time: course.examTime,
        location: course.room,
        color: CourseColorManager.generateSoftColor(course),
        seat: course.seatNo,
      ))
          .toList();
      isLoading = false;
    });
  }

  Future<void> getExam() async {
    setState(() {
        isLoading = true;
      });
    final result = await ExamService.getExam(isRefresh: true);
    setExam(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '近期考试',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      await getExam();
                    },
                    icon: const Icon(Icons.refresh))
              ],
            )),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: examCard(),
        ),
      ],
    );
  }

  Widget examWrap(ExamData exam) {
    return Wrap(
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(exam.time, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        if (exam.location.isNotEmpty) const SizedBox(width: 16),
        if (exam.location.isNotEmpty)
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(exam.location, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        if (exam.location.isNotEmpty) const SizedBox(width: 16),
        if (exam.location.isNotEmpty)
          Row(
            children: [
              Icon(Icons.event_seat, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('座位号 ${exam.seat}',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
      ],
    );
  }

  Widget examCard() {
    if (isLoading) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 16),
              Text('正在加载考试信息...'),
            ],
          ),
        ),
      );
    }

    return examItems.isEmpty
        ? const Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  EmptyWidget(),
                  Center(
                      child: Text(
                    '最近没有考试',
                    style: TextStyle(fontSize: 20),
                  ))
                ],
              ),
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
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                            title: Text(exam.title), content: examWrap(exam)));
                  },
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
                  subtitle: examWrap(exam),
                ),
              );
            },
          );
  }
}

class ExamData {
  final String title;
  final String time;
  final String location;
  final Color color;
  final String seat;

  ExamData({
    required this.title,
    required this.time,
    required this.location,
    required this.color,
    required this.seat,
  });
}
