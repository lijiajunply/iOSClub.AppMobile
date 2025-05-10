import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ios_club_app/Models/SemesterModel.dart';
import 'package:ios_club_app/PageModels/CourseColorManager.dart';
import 'package:ios_club_app/Services/edu_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/ScoreModel.dart';
import '../Models/UserData.dart';
import '../Services/data_service.dart';
import '../widgets/empty_widget.dart';
import '../widgets/page_header_delegate.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  final List<ScoreList> _scoreList = [];
  bool _isLoading = true;
  bool _isFool = false;
  late final Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = refresh();
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('获取用户凭证失败，请重新登录')),
          );
        }
        return;
      }

      final headers = _buildHeaders(cookieData);
      final semesters = await DataService.getSemester();

      final freshScoreList = <ScoreList>[];
      for (final semester in semesters) {
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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取数据失败: ${e.toString()}')),
        );
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
          'https://xauatapi.xauat.site/Score?'
          'studentId=${cookieData.studentId}&semester=${semester.semester}',
        ),
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
        'https://xauatapi.xauat.site/Score?'
        'studentId=${cookieData.studentId}&semester=${semester.semester}',
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
    return FutureBuilder(
      future: _initialLoad,
      builder: (context, snapshot) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildStatsCard(),
              _buildScoreList(),
            ],
          ),
        );
      },
    );
  }

  SliverPersistentHeader _buildAppBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: HeaderChildDelegate(
        minHeight: 66,
        maxHeight: 80,
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
        ),
      ),
    );
  }

  SliverPadding _buildStatsCard() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverToBoxAdapter(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.credit_score,
                  value: ScoreList.getTotalGpa(_scoreList).toStringAsFixed(2),
                  label: 'GPA',
                ),
                _buildStatItem(
                  icon: Icons.do_not_disturb_on_total_silence,
                  value: ScoreList.getTotalCourse(_scoreList).toString(),
                  label: '通过课程',
                ),
                InkWell(
                  onTap: _showCreditInfoDialog,
                  child: _buildStatItem(
                    icon: Icons.equalizer,
                    value: ScoreList.getTotalCredit(_scoreList)
                        .toStringAsFixed(1),
                    label: '总学分',
                    withInfo: true,
                  ),
                )
              ],
            ),
          ),
        ),
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

  SliverPadding _buildScoreList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverToBoxAdapter(
        child: _scoreList.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _scoreList.length,
                itemBuilder: (context, index) =>
                    _buildSemesterCard(_scoreList[index]),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const EmptyWidget(),
            const Center(
              child: Text(
                '没有成绩，建议刷新或退出重进',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => refresh(isRefresh: true),
              child: const Text('刷新数据'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterCard(ScoreList score) {
    final semesterNames = score.semester.name.split('-');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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

    return GestureDetector(
      onTap: () => _showScoreDetails(item),
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
      await showModalBottomSheet<void>(
        context: context,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(10),
          child: content,
        ),
      );
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
