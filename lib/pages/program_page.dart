import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/edu_service.dart';
import 'package:ios_club_app/widgets/club_card.dart';

import '../PageModels/course_color_manager.dart';

import 'package:flutter/cupertino.dart';

import '../widgets/club_app_bar.dart';

class ProgramPage extends StatefulWidget {
  const ProgramPage({super.key});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late PageController _pageController;
  List<String> semesterNames = [
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前主题模式
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accentColor = const Color(0xFF007AFF); // iOS主色调

    return Scaffold(
      appBar: ClubAppBar(
        title: '培养方案',
      ),
      body: FutureBuilder(
        future: EduService.getPrograms(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // 延迟初始化 TabController，确保使用实际数据数量
            if (snapshot.data!.isNotEmpty &&
                (_tabController == null ||
                    _tabController!.length != snapshot.data!.length)) {
              _tabController =
                  TabController(length: snapshot.data!.length, vsync: this);

              // 同步 TabController 和 PageController
              _tabController!.addListener(() {
                if (!_tabController!.indexIsChanging) {
                  _pageController.animateToPage(
                    _tabController!.index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              });
            }

            return Column(
              children: [
                SizedBox(
                  height: 48,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    tabs: snapshot.data!.asMap().entries.map((entry) {
                      final program = entry.value;
                      final term = program.term == "特殊分组"
                          ? semesterNames.length - 1
                          : int.parse(program.term) - 1;

                      return Tab(
                        child: Text(
                          semesterNames[term],
                        ),
                      );
                    }).toList(),
                    indicatorColor: accentColor,
                    indicatorWeight: 2.5,
                    dividerColor: Colors.transparent,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(height: 8),
                // 页面内容
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: snapshot.data!.length,
                    onPageChanged: (index) {
                      if (_tabController != null &&
                          _tabController!.index != index) {
                        _tabController!.animateTo(index);
                      }
                    },
                    itemBuilder: (context, index) {
                      final program = snapshot.data![index];

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClubCard(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 5.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: courseColor.withValues(
                                                    alpha: 0.15),
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
                                }).toList(),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
    );
  }
}
