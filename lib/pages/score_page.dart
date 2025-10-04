import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ios_club_app/models/semester_model.dart';
import 'package:ios_club_app/PageModels/course_color_manager.dart';
import 'package:ios_club_app/Services/edu_service.dart';
import 'package:ios_club_app/stores/user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/models/score_model.dart';
import 'package:ios_club_app/models/user_data.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/widgets/empty_widget.dart';
import 'package:ios_club_app/widgets/show_club_snack_bar.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage>
    with SingleTickerProviderStateMixin {
  final UserStore userStore = Get.find();
  final List<ScoreList> _scoreList = [];
  bool _isLoading = true;
  bool _isFool = false;
  String _loadingText = '正在获取数据...';
  final List<ScoreList> _yearList = [];
  bool _isYear = false;

  late PageController pageController = PageController();
  late int _currentIndex = 0;
  final List<String> _selectorList = [];

  static const yearStringList = [
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十'
  ];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh({bool isRefresh = false}) async {
    if (!isRefresh && !_isFool) {
      final cachedData = await _tryGetCachedData();
      if (cachedData != null) {
        if (mounted) {
          setState(() {
            _scoreList
              ..clear()
              ..addAll(cachedData);
            _selectorList.clear();
            for (var i = 0; i < _scoreList.length; i++) {
              var y = _scoreList.length - i + 1;
              _selectorList.add(
                  '大${yearStringList[y ~/ 2 - 1]}${y % 2 == 1 ? '下' : '上'}');
            }
            _isLoading = false;
          });
        }
        return;
      }
    }

    if (_isFool) {
      final cachedData = await _tryGetCachedData();
      if (cachedData != null) {
        if (mounted) {
          setState(() {
            _scoreList
              ..clear()
              ..addAll(cachedData);
            _isLoading = false;
            _isFool = false;
          });
        }
        return;
      }
    }

    await _fetchFreshData(isRefresh: isRefresh);
  }

  Future<List<ScoreList>?> _tryGetCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('all_score_data');
    final lastFetchTime = prefs.getInt('last_Score_time');
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastFetchTime != null &&
        now - lastFetchTime < const Duration(hours: 1).inMilliseconds &&
        jsonString != null &&
        jsonString.isNotEmpty) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList.map((value) => ScoreList.fromJson(value)).toList();
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing cached data: $e');
        }
      }
    }
    return null;
  }

  Future<void> _fetchFreshData({required bool isRefresh}) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final cookieData = await EduService.getUserData();
      if (cookieData == null) {
        if (mounted) {
          showClubSnackBar(context, Text('获取用户凭证失败，请重新登录'));
        }
        return;
      }

      final headers = _buildHeaders(cookieData);
      setState(() {
        _loadingText = '正在获取所有学期数据...';
      });
      final semesters = await DataService.getSemester(isRefresh: isRefresh);

      final freshScoreList = <ScoreList>[];
      for (final semester in semesters) {
        setState(() {
          _loadingText = '正在获取 ${semester.name} 学期数据...';
        });

        final semesterScores = await _fetchSemesterScores(
          cookieData: cookieData,
          semester: semester,
          headers: headers,
        );

        if (semesterScores != null) {
          freshScoreList.add(semesterScores);
        }
      }

      await _cacheFreshData(freshScoreList);

      if (mounted) {
        setState(() {
          _scoreList
            ..clear()
            ..addAll(freshScoreList);
          _isLoading = false;
          _selectorList.clear();
          for (var i = 0; i < _scoreList.length; i++) {
            var y = _scoreList.length - i + 1;
            _selectorList
                .add('大${yearStringList[y ~/ 2 - 1]}${y % 2 == 1 ? '下' : '上'}');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        showClubSnackBar(context, Text('获取数据失败: ${e.toString()}'));
      }
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    } finally {
      _isFool = false;
    }
  }

  Map<String, String> _buildHeaders(UserData cookieData) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookieData.cookie,
      'xauat': cookieData.cookie,
    };
  }

  Future<ScoreList?> _fetchSemesterScores({
    required UserData cookieData,
    required SemesterModel semester,
    required Map<String, String> headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${semester.semester}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return ScoreList(
          semester: semester,
          list: list.map((e) => ScoreModel.fromJson(e)).toList(),
        );
      } else {
        return await _retryWithFreshLogin(
          cookieData: cookieData,
          semester: semester,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching semester scores: $e');
      }
      return null;
    }
  }

  Future<ScoreList?> _retryWithFreshLogin({
    required UserData cookieData,
    required SemesterModel semester,
  }) async {
    await EduService.login();
    final freshCookieData = await EduService.getUserData();
    if (freshCookieData == null) return null;

    final response = await http.get(
      Uri.parse(
        'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${semester.semester}',
      ),
      headers: _buildHeaders(freshCookieData),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return ScoreList(
        semester: semester,
        list: list.map((e) => ScoreModel.fromJson(e)).toList(),
      );
    }
    return null;
  }

  Future<void> _cacheFreshData(List<ScoreList> freshData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('all_score_data', jsonEncode(freshData));
    await prefs.setInt(
        'last_Score_time', DateTime.now().millisecondsSinceEpoch);
  }

  void _handleFoolishMode() {
    setState(() {
      _isFool = true;
      for (final item in _scoreList) {
        for (final item2 in item.list) {
          item2.grade = '100';
          item2.gpa = '5';
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('是的，在下绩点5.0'),
            Icon(Icons.mood, color: Colors.black12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 检查是否为游客模式
    if (!userStore.isLogin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                '未登录',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '请先去登录即可查看成绩',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // 导航到个人页面进行登录
                  Get.toNamed('/Profile');
                },
                child: Text('前往登录'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(
              _loadingText,
              style: TextStyle(fontSize: 16),
            )
          ],
        )),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          _buildStatsCard(),
          _buildSelector(),
          Expanded(
            child: _buildScoreList(),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '成绩与绩点',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _changeScoreList,
                  icon: Icon(_isYear
                      ? Icons.calendar_today_rounded
                      : Icons.calendar_view_day_rounded),
                ),
                IconButton(
                  onPressed: _handleFoolishMode,
                  icon: const Icon(Icons.mood),
                ),
                IconButton(
                  onPressed: () => refresh(isRefresh: true),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
        ));
  }

  void _changeScoreList() {
    setState(() {
      _isYear = !_isYear;
      if (_isYear && _scoreList.isNotEmpty && _yearList.isEmpty) {
        for (var i = _scoreList.length - 1; i >= 0; i--) {
          var j = _scoreList.length - 1 - i;
          if (j % 2 == 0) {
            _yearList.add(ScoreList(
              semester: _scoreList[i].semester,
              list: _scoreList[i].list.toList(),
            ));
          } else {
            var a = _yearList.lastOrNull;
            if (a != null) {
              a.list.addAll(_scoreList[i].list.toList());
            }
          }
        }
      }

      if (_scoreList.isNotEmpty) {
        if (_isYear) {
          _selectorList.clear();
          for (var i = 0; i < _yearList.length; i++) {
            _selectorList.add('大${yearStringList[i]}');
          }
        } else {
          _selectorList.clear();
          for (var i = 0; i < _scoreList.length; i++) {
            var y = _scoreList.length - i + 1;
            _selectorList
                .add('大${yearStringList[y ~/ 2 - 1]}${y % 2 == 1 ? '下' : '上'}');
          }
        }

        if (_currentIndex >= _selectorList.length) {
          _currentIndex = _selectorList.length - 1;
        }
        pageController.jumpToPage(_currentIndex);
      }
    });
  }

  Widget _buildStatsCard() {
    if (_scoreList.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ClubCard(
        child: _buildStatsPadding(),
      ),
    );
  }

  Widget _buildStatsPadding({ScoreList? scoreList}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            icon: Icons.credit_score,
            value: scoreList == null
                ? ScoreList.getTotalGpa(_scoreList).toStringAsFixed(2)
                : scoreList.totalGpa.toStringAsFixed(2),
            label: 'GPA',
          ),
          _buildStatItem(
            icon: Icons.do_not_disturb_on_total_silence,
            value: scoreList == null
                ? ScoreList.getTotalCourse(_scoreList).toString()
                : scoreList.totalCourse.toString(),
            label: '通过课程',
          ),
          InkWell(
            onTap: _showCreditInfoDialog,
            child: _buildStatItem(
              icon: Icons.equalizer,
              value: scoreList == null
                  ? ScoreList.getTotalCredit(_scoreList).toStringAsFixed(1)
                  : scoreList.totalCredit.toStringAsFixed(1),
              label: '总学分',
              withInfo: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    bool withInfo = false,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (withInfo)
              const Icon(
                Icons.info_outline,
                size: 9,
                color: Colors.grey,
              ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreditInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('说明'),
        content: const Text('这里的学分是按照成绩算出来的，只要没有挂科就OK。教务系统给的一般来说要小于等于这个数'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    if (_selectorList.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CupertinoSlidingSegmentedControl<int>(
        proportionalWidth: true,
        groupValue: _currentIndex,
        onValueChanged: (int? value) async {
          if (value != null && value < _selectorList.length) {
            setState(() {
              pageController.jumpToPage(value);
              setState(() {
                _currentIndex = value;
              });
            });
          }
        },
        children: _selectorList
            .map(
              (x) => Text(x),
            )
            .toList()
            .asMap(),
      ),
    );
  }

  Widget _buildScoreList() {
    return _scoreList.isEmpty
        ? _buildEmptyState()
        : _isYear
            ? _buildYearList()
            : _buildSemesterList();
  }

  Widget _buildSemesterList() {
    return PageView.builder(
      controller: pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemCount: _scoreList.length,
      itemBuilder: (context, index) => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: _buildSemesterCard(_scoreList[index]),
      ),
    );
  }

  Widget _buildYearList() {
    return PageView.builder(
        controller: pageController,
        itemCount: _yearList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) => SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _buildYearCard(_yearList[index], index),
            ));
  }

  Widget _buildYearCard(ScoreList score, int index) {
    const yearStringList = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    return ClubCard(
        margin: const EdgeInsets.all(16),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(children: [
              Text('大${yearStringList[index]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
              _buildStatsPadding(scoreList: score),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: score.list.length,
                itemBuilder: (context, index) =>
                    _buildScoreItem(score.list[index]),
              )
            ])));
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          EmptyWidget(
            title: '没有成绩',
            subtitle: '建议刷新或退出重进',
            icon: Icons.school,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => refresh(isRefresh: true),
            child: const Text('刷新数据'),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(ScoreList score) {
    final semesterNames = score.semester.name.split('-');
    return ClubCard(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Text(
              '${semesterNames[0]}至${semesterNames[1]}年 第${semesterNames[2]}学期',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...score.list.map(_buildScoreItem),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(ScoreModel item) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showScoreDetails(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.name}${item.isMinor ? ' (辅修)' : ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              _buildScoreMeta(item),
                            ]),
                      ),
                      if (isTablet)
                        Expanded(
                          child: Text(
                            item.gradeDetail,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreMeta(ScoreModel item) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text('${item.credit}学分', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(width: 16),
        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text('成绩 ${item.grade}', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(width: 16),
        Icon(Icons.grade, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text('绩点 ${item.gpa}', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Future<void> _showScoreDetails(ScoreModel score) async {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final content = _buildScoreDetailsContent(score, isTablet);

    if (isTablet) {
      await showDialog<void>(
        context: context,
        builder: (context) => SimpleDialog(children: [content]),
      );
    } else {
      await showClubModalBottomSheet(context, content);
    }
  }

  Widget _buildScoreDetailsContent(ScoreModel score, bool isTablet) {
    return Container(
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
          _buildDetailRow(
              Icons.access_time, Colors.blue, '${score.credit}学分', isTablet),
          SizedBox(height: isTablet ? 10 : 18),
          _buildDetailRow(Icons.location_on, Colors.redAccent,
              '成绩 ${score.grade}', isTablet),
          SizedBox(height: isTablet ? 10 : 18),
          _buildDetailRow(
              Icons.grade, Colors.green, '绩点 ${score.gpa}', isTablet),
          SizedBox(height: isTablet ? 10 : 18),
          _buildDetailRow(
            Icons.details,
            Colors.green,
            score.gradeDetail,
            isTablet,
            expanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    Color color,
    String text,
    bool isTablet, {
    bool expanded = false,
  }) {
    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: isTablet ? 17 : 15,
        overflow: expanded ? TextOverflow.ellipsis : null,
      ),
      softWrap: true,
      maxLines: expanded ? 3 : 1,
    );

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 6),
        expanded ? Expanded(child: textWidget) : textWidget,
      ],
    );
  }
}
