import 'package:ios_club_app/models/course_model.dart';

/// 单数为课程开始时间，双数为课程结束时间，草堂的第一个数据是早自习的
class TimeService {
  /// 草堂的时间表
  static List<String> CanTangTimeStart = [
    "8:00",
    "8:30",
    "9:20",
    "10:25",
    "11:15",
    "12:10",
    "13:00",
    "14:00",
    "14:50",
    "15:45",
    "16:35",
    "19:30",
    "20:20"
  ];

  static List<String> CanTangTimeEnd = [
    "8:20",
    "9:15",
    "10:05",
    "11:10",
    "12:00",
    "12:55",
    "13:45",
    "14:45",
    "15:35",
    "16:30",
    "17:20",
    "20:15",
    "21:05"
  ];

  /// 雁塔冬季的时间表
  static List<String> YanTaDongStart = [
    "",
    "8:00",
    "9:00",
    "10:10",
    "11:10",
    "",
    "",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
    "19:30",
    "20:30"
  ];

  static List<String> YanTaDongEnd = [
    "",
    "8:50",
    "9:50",
    "11:00",
    "12:00",
    "",
    "",
    "14:50",
    "15:50",
    "16:50",
    "17:50",
    "20:20",
    "21:20"
  ];

  /// 雁塔夏季的时间表
  static List<String> YanTaXiaStart = [
    "",
    "8:00",
    "9:00",
    "10:10",
    "11:10",
    "",
    "",
    "14:30",
    "15:30",
    "16:30",
    "17:30",
    "20:00",
    "21:00"
  ];

  static List<String> YanTaXiaEnd = [
    "",
    "8:50",
    "9:50",
    "11:00",
    "12:00",
    "",
    "",
    "15:20",
    "16:20",
    "17:30",
    "18:20",
    "20:50",
    "21:50"
  ];

  static StartAndEnd getStartAndEnd(CourseModel course) {
    var startTime = "";
    var endTime = "";

    final isCaoTang = course.campus == "草堂校区" ||
        (course.room.length >= 2 && course.room.startsWith("草堂"));
    if (isCaoTang) {
      startTime = TimeService.CanTangTimeStart[course.startUnit];
      endTime = TimeService.CanTangTimeEnd[course.endUnit];
    } else {
      final now = DateTime.now();
      if (now.month >= 5 && now.month < 10) {
        startTime = TimeService.YanTaXiaStart[course.startUnit];
        endTime = TimeService.YanTaXiaEnd[course.endUnit];
      } else {
        startTime = TimeService.YanTaDongStart[course.startUnit];
        endTime = TimeService.YanTaDongEnd[course.endUnit];
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
