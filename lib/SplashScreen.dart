import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:lottie/lottie.dart';

import 'App.dart';
import 'PageModels/ScheduleItem.dart';
import 'Services/DataService.dart';
import 'Services/EduService.dart';
import 'Services/TimeService.dart';
import 'Services/WidgetService.dart';

Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'updatetimetable') {

    final value = await DataService.getCourse();

    List<ScheduleItem> courses = [];
    courses.clear();
    courses.addAll((value.map((course) {
      var startTime = "";
      var endTime = "";
      if (course.room.substring(0, 2) == "草堂") {
        startTime = TimeService.CanTangTime[course.startUnit];
        endTime = TimeService.CanTangTime[course.endUnit];
      } else {
        final now = DateTime.now();
        if (now.month >= 5 && now.month <= 10) {
          startTime = TimeService.YanTaXia[course.startUnit];
          endTime = TimeService.YanTaXia[course.endUnit];
        } else {
          startTime = TimeService.YanTaDong[course.startUnit];
          endTime = TimeService.YanTaDong[course.endUnit];
        }
      }
      return ScheduleItem(
        title: course.courseName,
        time:
        '第${course.startUnit}节 ~ 第${course.endUnit}节 | $startTime~$endTime',
        location: course.room,
      );
    })));

    await WidgetService.updateTodayCourses(courses);
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: (5)),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/lottie.json',
            controller: _controller,
            height: MediaQuery.of(context).size.height * 1,
            animate: true,
            onLoaded: (composition) async {
              _controller
                ..duration = composition.duration
                ..repeat();

              // // 获取并存储数据
              // final dataFuture = EduService.getAllData();
              // HomeWidget.setAppGroupId('com.example.ios_club_app');
              // HomeWidget.registerInteractivityCallback(backgroundCallback);
              //
              // await Future.wait([
              //   dataFuture,
              // ]);

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApp(),
                  ));
            },
          ),
        ));
  }
}