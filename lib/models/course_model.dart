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
    );
  }
}