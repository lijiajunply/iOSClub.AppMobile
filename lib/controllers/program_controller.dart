import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/models/plan_course.dart';
import 'package:ios_club_app/net/edu_service.dart';
import 'package:flutter/material.dart';

class ProgramController extends GetxController {
  TabController? _tabController;
  late PageController pageController;
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

  // Observable variables
  var programs = <PlanCourseList>[].obs;
  var isLoading = true.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      isLoading(true);
      isError(false);
      final result = await EduService.getPrograms();
      programs.assignAll(result);
      
      // Initialize TabController after data is loaded
      if (_tabController == null || _tabController!.length != programs.length) {
        _tabController?.dispose();
        // 使用 RootBundle 的 TickerProvider
        _tabController = TabController(
          length: programs.length, 
          vsync: const _FakeTickerProvider()
        );
      }
    } catch (e) {
      isError(true);
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  TabController? get tabController => _tabController;

  void onPageChanged(int index) {
    if (_tabController != null && _tabController!.index != index) {
      _tabController!.animateTo(index);
    }
  }

  void onTabChanged() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      pageController.animateToPage(
        _tabController!.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  void onClose() {
    _tabController?.dispose();
    pageController.dispose();
    super.onClose();
  }

  void clean() {
    programs.clear();
  }
}

// 创建一个简单的 TickerProvider 实现
class _FakeTickerProvider implements TickerProvider {
  const _FakeTickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}