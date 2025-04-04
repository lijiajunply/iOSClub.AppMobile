/// 单数为课程开始时间，双数为课程结束时间，草堂的第一个数据是早自习的
class TimeService {
  /// 草堂的时间表
  static List<String> CanTangTime =[
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
}