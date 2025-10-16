import 'package:get/get.dart';
import 'package:ios_club_app/models/course_model.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/services/time_service.dart';
import 'package:ios_club_app/stores/settings_store.dart';

class ScheduleStore extends GetxController {
  static ScheduleStore get to => Get.find();

  // 课程数据
  final _allCourses = <List<CourseModel>>[].obs;
  final _isLoading = true.obs;
  final _maxWeek = 0.obs;
  final _currentWeek = 0.obs;
  final _currentPage = 0.obs;
  final _height = 55.0.obs;
  final _isYanTa = false.obs;
  final _showTomorrow = false.obs;

  List<List<CourseModel>> get allCourses => _allCourses.toList();

  bool get isLoading => _isLoading.value;

  int get maxWeek => _maxWeek.value;

  int get currentWeek => _currentWeek.value;

  int get currentPage => _currentPage.value;

  double get height => _height.value;

  bool get isYanTa => _isYanTa.value;

  // 直接使用SettingsStore的showTomorrow变量
  bool get showTomorrow => _showTomorrow.value;

  bool get isShowTomorrow => SettingsStore.to.isShowTomorrow;

  int weekNow = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  /// 初始化数据
  Future<void> _initializeData() async {
    try {
      final weekData = await DataService.getWeek();
      _handleWeekData(weekData);
      await _loadCourses();
      await _loadPreferences();

      // 不再需要监听SettingsStore，因为我们直接使用它的值
    } catch (e) {
      // 错误处理
      print('初始化课表数据出错: $e');
    }
  }

  /// 处理周数据
  void _handleWeekData(Map<String, dynamic> weekData) {
    _currentWeek.value = weekData['week']!;
    weekNow = weekData['week']!;
    _maxWeek.value = weekData['maxWeek']!;
    _currentPage.value = _currentWeek.value <= 0 ? 0 : _currentWeek.value;
  }

  /// 加载课程数据
  Future<void> _loadCourses() async {
    final courses = await DataService.getAllCourse();
    _allCourses.value = List.generate(_maxWeek.value + 1, (i) {
      return i == 0
          ? courses
          : courses.where((course) => course.weekIndexes.contains(i)).toList();
    });
    if (courses.isNotEmpty) {
      _isYanTa.value = !(courses[0].room.substring(0, 2) == "草堂");
    }
    _isLoading.value = false;
  }

  /// 加载用户偏好设置
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final courseSize = prefs.getDouble('course_size');

    if (courseSize != null && courseSize != 0) {
      _height.value = courseSize;
    }
  }

  /// 刷新课程数据
  Future<void> refreshCourses() async {
    _isLoading.value = true;
    try {
      await DataService.getAllCourse(); // 确保数据已更新
      await _loadCourses();
    } finally {
      _isLoading.value = false;
    }
  }

  /// 跳转到指定页面
  void jumpToPage(int page) {
    if (page < 0) {
      page = _maxWeek.value;
    } else if (page > _maxWeek.value) {
      page = 0;
    }
    _currentPage.value = page;
  }

  /// 设置课程高度
  Future<void> setCourseHeight(double value) async {
    _height.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('course_size', value);
  }

  /// 设置当前页面
  void setCurrentPage(int page) {
    _currentPage.value = page;
  }

  /// 切换显示明天课程
  Future<void> toggleShowTomorrow() async {
    // 直接调用SettingsStore的方法来切换showTomorrow
    SettingsStore.to.setIsShowTomorrow(!SettingsStore.to.isShowTomorrow);
  }

  /// 获取今天或明天的课程
  List<CourseModel> getTodayCourses() {
    final now = DateTime.now();
    final weekDay = now.weekday;
    var a = false;

    // 处理今天的课程，使用DataService.getCourse中相同的逻辑
    if (weekNow >= allCourses.length) {
      return [];
    }

    var filteredCourses = allCourses[weekNow]
        .where((course) =>
            course.weekIndexes.contains(weekNow) && course.weekday == weekDay)
        .toList();

    // 过滤掉已经结束的课程
    filteredCourses = filteredCourses.where((course) {
      var endTime = "";
      if (course.room.substring(0, 2) == "雁塔") {
        if (now.month >= 5 && now.month <= 10) {
          endTime = TimeService.YanTaXia[course.endUnit];
        } else {
          endTime = TimeService.YanTaDong[course.endUnit];
        }
      } else {
        endTime = TimeService.CanTangTime[course.endUnit];
      }

      final l = endTime.split(':');
      var end = DateTime(
          now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);

      return now.isBefore(end);
    }).toList();

    filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    // 只有当今天没有课程且isShowTomorrow为true时，才显示明天的课程
    if (isShowTomorrow && filteredCourses.isEmpty) {
      final tomorrow = now.add(Duration(days: 1));
      var tomorrowWeekDay = tomorrow.weekday;
      if (tomorrowWeekDay > 7) {
        tomorrowWeekDay = 1;
      }

      // 如果明天是周日，则周数需要增加
      final targetWeek = tomorrowWeekDay == 7 ? weekNow + 1 : weekNow;

      // 检查targetWeek是否超出范围
      if (targetWeek >= allCourses.length) {
        return [];
      }

      final courses = allCourses[targetWeek];
      a = true;
      filteredCourses = courses
          .where((course) => course.weekday == tomorrowWeekDay)
          .toList()
        ..sort((a, b) => a.startUnit.compareTo(b.startUnit));
    }

    _showTomorrow.value = a;

    return filteredCourses;
  }
}
