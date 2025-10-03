import 'package:get/get.dart';
import 'package:ios_club_app/Models/CourseModel.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleStore extends GetxController {
  static ScheduleStore get to => Get.find();

  // 课程数据
  final _allCourses = <List<CourseModel>>[].obs;
  final _isLoading = true.obs;
  final _maxWeek = 0.obs;
  final _currentWeek = 0.obs;
  final _currentPage = 0.obs;
  final _height = 55.0.obs;

  List<List<CourseModel>> get allCourses => _allCourses.toList();
  bool get isLoading => _isLoading.value;
  int get maxWeek => _maxWeek.value;
  int get currentWeek => _currentWeek.value;
  int get currentPage => _currentPage.value;
  double get height => _height.value;

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
    } catch (e) {
      // 错误处理
      print('初始化课表数据出错: $e');
    }
  }

  /// 处理周数据
  void _handleWeekData(Map<String, dynamic> weekData) {
    _currentWeek.value = weekData['week']!;
    _maxWeek.value = weekData['maxWeek']!;
    _currentPage.value = _currentWeek.value <= 0 ? 0 : _currentWeek.value;
  }

  /// 加载课程数据
  Future<void> _loadCourses() async {
    final courses = await DataService.getAllCourse();
    _allCourses.value = List.generate(_maxWeek.value + 1, (i) {
      return i == 0
          ? courses
          : courses
              .where((course) => course.weekIndexes.contains(i))
              .toList();
    });
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
}