import 'package:flutter/material.dart';
import 'package:ios_club_app/Models/CourseColorManager.dart';
import 'package:ios_club_app/Services/EduService.dart';

import '../Models/ScoreModel.dart';
import '../Widgets/PageHeaderDelegate.dart';

class ScorePage extends StatelessWidget {
  const ScorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = EduService();
    return FutureBuilder(
        future: dataService.getAllScoreFromLocal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // 请求失败，显示错误
              return Text("Error: ${snapshot.error}");
            } else {
              // 请求成功，显示数据
              return ScoreBuilder(
                scoreList: snapshot.data!,
              );
            }
          } else {
            // 请求未结束，显示loading
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class ScoreBuilder extends StatefulWidget {
  final List<ScoreList> scoreList;

  const ScoreBuilder({super.key, required this.scoreList});

  @override
  State<ScoreBuilder> createState() => _ScoreBuilderState();
}

class _ScoreBuilderState extends State<ScoreBuilder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverPersistentHeader(
          pinned: true, // 设置为true使其具有粘性
          delegate: PageHeaderDelegate(
            title: '成绩与绩点',
            minHeight: 66,
            maxHeight: 80,
          ),
        ),
        SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverToBoxAdapter(
                child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        const Icon(Icons.credit_score, size: 32),
                        Text(
                          ScoreList.getTotalGpa(widget.scoreList)
                              .toStringAsFixed(2),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'GPA',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ]),
                      Column(children: [
                        const Icon(Icons.do_not_disturb_on_total_silence,
                            size: 32),
                        Text(
                          ScoreList.getTotalCourse(widget.scoreList).toString(),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          '通过课程',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ]),
                      Column(
                        children: [
                          const Icon(Icons.equalizer, size: 32),
                          Text(
                            ScoreList.getTotalCredit(widget.scoreList)
                                .toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            '总学分',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  )),
            ))),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.scoreList.length,
                  itemBuilder: (context, index) {
                    final score = widget.scoreList[index];
                    final semesterNames = score.semester.name.split('-');
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      elevation: 4,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(children: [
                            Text(
                              '${semesterNames[0]}至${semesterNames[1]}年 第${semesterNames[2]}学期',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ...score.list
                                .map((item) => _buildScheduleItem(item))
                          ])),
                    );
                  })),
        ),
      ]),
    );
  }

  Widget _buildScheduleItem(ScoreModel item) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return GestureDetector(
        onTap: () async {
          await _showModalBottomSheet(item);
        },
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CourseColorManager.generateSoftColor(item.name),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Column(
                        // 添加居中对齐 ,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // 添加左对齐
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // 为课程名也添加省略
                            maxLines: 1, // 限制为单行
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('${item.credit}学分',
                                  style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(width: 16),
                              Icon(Icons.location_on,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('成绩 ${item.grade}',
                                  style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(width: 16),
                              Icon(Icons.grade,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('绩点 ${item.gpa}',
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      )),
                      if (isTablet)
                        Expanded(
                          // 用 Expanded 包裹以限制宽度
                          child: Text(
                            item.gradeDetail,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1, // 限制为单行
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<void> _showModalBottomSheet(ScoreModel score) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    var content = Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              score.name,
              style: const TextStyle(
                fontSize: 20,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 10 : 18),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.blue,
                ),
                const SizedBox(width: 6),
                Text(
                  '${score.credit}学分',
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 10 : 18),
            Row(children: [
              const Icon(
                Icons.location_on,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 6),
              Text(
                '成绩 ${score.grade}',
                style: TextStyle(
                  fontSize: isTablet ? 17 : 15,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
            SizedBox(height: isTablet ? 10 : 18),
            Row(children: [
              const Icon(
                Icons.grade,
                color: Colors.green,
              ),
              const SizedBox(width: 6),
              Text(
                '绩点 ${score.gpa}',
                style: TextStyle(
                  fontSize: isTablet ? 17 : 15,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            SizedBox(height: isTablet ? 10 : 18),
            Row(children: [
              const Icon(
                Icons.details,
                color: Colors.green,
              ),
              const SizedBox(width: 6),
              Expanded( // 添加 Expanded
                child: Text(
                  score.gradeDetail,
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis, // 添加省略号
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 15,
                  ),
                ),
              ),
            ]),
          ],
        ));

    if (isTablet) {
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[content],
            );
          });
    }

    final a = MediaQuery.of(context).size.width;

    return showModalBottomSheet<void>(
        context: context,
        constraints: BoxConstraints(maxWidth: a, minWidth: a),
        builder: (BuildContext context) {
          return Padding(padding: const EdgeInsets.all(10), child: content);
        });
  }
}
