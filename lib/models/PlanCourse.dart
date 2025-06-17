import 'dart:convert';

class PlanCourse {
  String name;
  String lessonType;
  String examMode;
  String courseTypeName;
  double credits;
  String termStr;

  PlanCourse({
    this.name = "",
    this.lessonType = "",
    this.examMode = "",
    this.courseTypeName = "",
    this.credits = 0.0,
    this.termStr = "",
  });

  // 将对象转换为Map以便JSON编码
  Map<String, dynamic> toJson() => {
    'Name': name,
    'LessonType': lessonType,
    'ExamMode': examMode,
    'CourseTypeName': courseTypeName,
    'Credits': credits,
    'TermStr': termStr,
  };

  // 从Map创建PlanCourse对象
  factory PlanCourse.fromJson(Map<String, dynamic> json) {
    return PlanCourse(
      name: json['name'] as String? ?? "",
      lessonType: json['lessonType'] as String? ?? "",
      examMode: json['examMode'] as String? ?? "",
      courseTypeName: json['courseTypeName'] as String? ?? "",
      credits: (json['credits'] as num?)?.toDouble() ?? 0.0,
      termStr: json['termStr'] as String? ?? "",
    );
  }

  // 将对象序列化为JSON字符串
  String toJsonString() => json.encode(toJson());

  // 从JSON字符串创建PlanCourse对象
  factory PlanCourse.fromJsonString(String jsonString) =>
      PlanCourse.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}

class PlanCourseList {
  List<PlanCourse> courses;
  String term;

  PlanCourseList({
    this.courses = const [],
    this.term = "",
  });

  // 将对象转换为Map以便JSON编码
  Map<String, dynamic> toJson() => {
    term: courses.map((course) => course.toJson()).toList(),
  };

  // 从Map创建PlanCourseList对象
  factory PlanCourseList.fromJson(Map<String, dynamic> json) {
    return PlanCourseList(
      courses: (json.values as List<dynamic>?)
          ?.map((courseJson) => PlanCourse.fromJson(courseJson))
          .toList() ??
          [],
    );
  }

  factory PlanCourseList.fromMap(term, courses) => PlanCourseList(
    term: term,
    courses: courses.map<PlanCourse>((e) => PlanCourse.fromJson(e)).toList(),
  );
}