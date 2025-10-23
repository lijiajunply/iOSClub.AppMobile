import 'package:ios_club_app/models/course_model.dart';

/// 单数为课程开始时间，双数为课程结束时间，草堂的第一个数据是早自习的
class TimeService {
  /// 草堂的时间表
  static List<String> CanTangTime = [
    "8:00",
    "8:30",
    "10:05",
    "10:25",
    "12:00",
    "12:10",
    "13:45",
    "14:00",
    "15:35",
    "15:45",
    "17:20",
    "19:30",
    "21:05"
  ];

  /// 雁塔冬季的时间表
  static List<String> YanTaDong = [
    "",
    "8:00",
    "9:50",
    "10:10",
    "12:00",
    "",
    "",
    "14:00",
    "15:50",
    "16:00",
    "17:50",
    "19:30",
    "21:20"
  ];

  /// 雁塔夏季的时间表
  static List<String> YanTaXia = [
    "",
    "8:00",
    "9:50",
    "10:10",
    "12:00",
    "",
    "",
    "14:30",
    "16:20",
    "16:30",
    "18:20",
    "20:00",
    "21:50"
  ];

  static StartAndEnd getStartAndEnd(CourseModel course) {
    var startTime = "";
    var endTime = "";

    final isCaoTang = course.campus == "草堂校区" ||
        (course.room.length >= 2 && course.room.startsWith("草堂"));
    if (isCaoTang) {
      startTime = TimeService.CanTangTime[course.startUnit];
      endTime = TimeService.CanTangTime[course.endUnit];
    } else {
      final now = DateTime.now();
      if (now.month >= 5 && now.month < 10) {
        startTime = TimeService.YanTaXia[course.startUnit];
        endTime = TimeService.YanTaXia[course.endUnit];
      } else {
        startTime = TimeService.YanTaDong[course.startUnit];
        endTime = TimeService.YanTaDong[course.endUnit];
      }
    }

    return StartAndEnd(
      start: startTime,
      end: endTime,
    );
  }
}

class StartAndEnd {
  final String start;
  final String end;

  StartAndEnd({
    required this.start,
    required this.end,
  });
}
