import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/edu_service.dart';

import '../PageModels/CourseColorManager.dart';

import 'package:flutter/cupertino.dart';

class ProgramPage extends StatelessWidget {
  const ProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取当前主题模式
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;
    final accentColor = const Color(0xFF007AFF); // iOS主色调

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          '培养方案',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: FutureBuilder(
          future: EduService.getPrograms(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
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
                      ? semesterNames.length - 1
                      : int.parse(program.term) - 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 学期标题
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              semesterNames[term],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),

                        // 课程列表
                        ...program.courses.asMap().entries.map((entry) {
                          final course = entry.value;
                          final courseColor =
                              CourseColorManager.generateSoftColor(
                                  course.courseTypeName);

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                child: Row(
                                  children: [
                                    // 课程类型指示器
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: courseColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // 课程信息
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            course.courseTypeName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 学分展示
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: courseColor.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Text(
                                        "${course.credits} 学分",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: courseColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 添加分隔线，最后一项不添加
                            ],
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.exclamationmark_circle,
                        size: 50, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 17,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // 加载状态
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('正在加载培养方案...'),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
