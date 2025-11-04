class CourseModel {
  List<int> weekIndexes = [];
  List<String> teachers = [];
  String room = '';
  String courseName = '';
  String courseCode = '';
  int weekday = 0;
  int startUnit = 0;
  int endUnit = 0;
  String credits = '';
  String lessonId = '';
  String campus = '';

  CourseModel({
    List<int>? weekIndexes,
    List<String>? teachers,
    String? room,
    String? courseName,
    String? courseCode,
    int? weekday,
    int? startUnit,
    int? endUnit,
    String? credits,
    String? lessonId,
    String? campus,
  }) {
    this.weekIndexes = weekIndexes ?? [];
    this.teachers = teachers ?? [];
    this.room = room ?? '';
    this.courseName = courseName ?? '';
    this.courseCode = courseCode ?? '';
    this.weekday = weekday ?? 0;
    this.startUnit = startUnit ?? 0;
    this.endUnit = endUnit ?? 0;
    this.credits = credits ?? '';
    this.lessonId = lessonId ?? '';
    this.campus = campus ?? '';
  }

  // 如果需要从 JSON 创建对象
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      weekIndexes: List<int>.from(json['weekIndexes'] ?? []),
      teachers: List<String>.from(json['teachers'] ?? []),
      room: json['room'] ?? '',
      courseName: json['courseName'] ?? '',
      courseCode: json['courseCode'] ?? '',
      weekday: json['weekday'] ?? 0,
      startUnit: json['startUnit'] ?? 0,
      endUnit: json['endUnit'] ?? 0,
      credits: json['credits'] ?? '',
      lessonId: json['lessonId'] ?? '',
      campus: json['campus'] ?? '',
    );
  }

  static String formatWeekRanges(List<int> weeks) {
    if (weeks.isEmpty) return '';
    if (weeks.length == 1) return weeks.first.toString();

    List<String> ranges = [];
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        // 连续的周数
        end = weeks[i];
      } else {
        // 不连续，保存当前段
        if (start == end) {
          ranges.add(start.toString());
        } else {
          ranges.add('$start-$end');
        }
        // 开始新的段
        start = weeks[i];
        end = weeks[i];
      }
    }

    // 添加最后一段
    if (start == end) {
      ranges.add(start.toString());
    } else {
      ranges.add('$start-$end');
    }

    return ranges.join(',');
  }
}
