import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/edu_service.dart';

import '../PageModels/CourseColorManager.dart';

class ProgramPage extends StatelessWidget {
  const ProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('培养方案'),
      ),
      body: FutureBuilder(
          future: EduService.getPrograms(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final program = snapshot.data![index];
                  final semesterNames = [
                    "大一上",
                    "大一下",
                    "大二上",
                    "大二下",
                    "大三上",
                    "大三下",
                    "大四上",
                    "大四下",
                    "大五上",
                    "大五下",
                    "特殊分组"
                  ];
                  final term = program.term == "特殊分组"
                      ? semesterNames.length
                      : int.parse(program.term);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 4),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              semesterNames[term - 1],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...program.courses.map((course) {
                              return ListTile(
                                leading: Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: CourseColorManager.generateSoftColor(course.courseTypeName),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                title: Text(course.name),
                                subtitle: Text(course.courseTypeName),
                                trailing: Text(
                                  "${course.credits} 学分",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
