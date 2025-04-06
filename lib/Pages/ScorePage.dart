import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ios_club_app/PageModels/CourseColorManager.dart';
import 'package:ios_club_app/Services/EduService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/ScoreModel.dart';
import '../Models/UserData.dart';
import '../Services/DataService.dart';
import '../Widgets/EmptyWidget.dart';
import '../Widgets/PageHeaderDelegate.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  late List<ScoreList> scoreList = [];
  bool _isLoading = true;
  bool _isFool = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      refresh();
    });
  }

  Future<void> refresh({bool isRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('all_score_data');
    var now = DateTime.now().millisecondsSinceEpoch;

    final last = prefs.getInt('last_Score_time');
    isRefresh = isRefresh && !_isFool;
    if (last != null && !isRefresh) {
      if (now - last < 1000 * 60 * 60) {
        if (jsonString != null && jsonString.isNotEmpty) {
          scoreList.clear();
          final List<dynamic> jsonList = jsonDecode(jsonString);

          setState(() {
            _isLoading = false;
            scoreList
                .addAll(jsonList.map((value) => ScoreList.fromJson(value)));
          });

          _isFool = false;
          return;
        }
      }
    }

    UserData? cookieData = await EduService.getCookieData();
    if (cookieData == null) {
      _isFool = false;
      return;
    }

    try {
      Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final list = await DataService.getSemester();

      setState(() {
        _isLoading = true;
        scoreList.clear();
      });

      for (var item in list) {
        final response = await http.get(
            Uri.parse(
                'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${item.semester}'),
            headers: finalHeaders);

        if (response.statusCode == 200) {
          final list = jsonDecode(response.body);
          setState(() {
            _isLoading = false;
            scoreList.add(ScoreList(
              semester: item,
              list: (list as List).map((e) => ScoreModel.fromJson(e)).toList(),
            ));
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('正在导入成绩数据：${item.name}'),
              ),
            );
          }
        } else {
          await EduService.login();
          final a = await EduService.getCookieData();
          if (a == null) {
            continue;
          }
          finalHeaders = {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Cookie': a.cookie,
            'xauat': a.cookie,
          };
          final response = await http.get(
              Uri.parse(
                  'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${item.semester}'),
              headers: finalHeaders);
          if (response.statusCode == 200) {
            final list = jsonDecode(response.body);
            setState(() {
              scoreList.add(ScoreList(
                semester: item,
                list:
                    (list as List).map((e) => ScoreModel.fromJson(e)).toList(),
              ));
            });
          }
        }
      }

      await prefs.setString('all_score_data', jsonEncode(scoreList));
      await prefs.setInt('last_Score_time', now);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    _isFool = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverPersistentHeader(
          pinned: true, // 设置为true使其具有粘性
          delegate: HeaderChildDelegate(
              minHeight: 66,
              maxHeight: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '成绩与绩点',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _isFool = true;
                          setState(() {
                            for (var item in scoreList) {
                              for (var item2 in item.list) {
                                item2.grade = '100';
                                item2.gpa = '5';
                              }
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('是的，在下绩点5.0'),
                                  const Icon(Icons.mood, color: Colors.black12)
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.mood),
                      ),
                      IconButton(
                        onPressed: () {
                          refresh(isRefresh: true);
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  )
                ],
              )),
        ),
        SliverPadding(
            padding: const EdgeInsets.all(16.0),
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
                          ScoreList.getTotalGpa(scoreList).toStringAsFixed(2),
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
                          ScoreList.getTotalCourse(scoreList).toString(),
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
                      GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: const Text('说明'),
                                      content: const Text(
                                          '这里的学分是按照成绩算出来的，只要没有挂科就OK。教务系统给的一般来说要小于等于这个数'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('确定'),
                                        )
                                      ]);
                                });
                          },
                          child: Column(
                            children: [
                              const Icon(Icons.equalizer, size: 32),
                              Text(
                                ScoreList.getTotalCredit(scoreList)
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 9,
                                    color: Colors.grey,
                                  ),
                                  const Text(
                                    '总学分',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ))
                    ],
                  )),
            ))),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
              child: scoreList.isEmpty
                  ? Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            EmptyWidget(),
                            Center(
                                child: Text(
                              '没有成绩，建议刷新或退出重进',
                              style: TextStyle(fontSize: 20),
                            ))
                          ],
                        ),
                      ))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: scoreList.length,
                      itemBuilder: (context, index) {
                        final score = scoreList[index];
                        final semesterNames = score.semester.name.split('-');
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 4),
                          elevation: 4,
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(children: [
                                Text(
                                  '${semesterNames[0]}至${semesterNames[1]}年 第${semesterNames[2]}学期',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                            '${item.name}${item.isMinor ? ' (辅修)' : ''}',
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
              Expanded(
                // 添加 Expanded
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
