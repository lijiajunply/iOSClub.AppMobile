import 'package:ios_club_app/Models/SemesterModel.dart';

class ScoreModel {
  String name;
  String lessonCode;
  String lessonName;
  String grade;
  String gpa;
  String gradeDetail;
  String credit;

  ScoreModel({
    this.name = '',
    this.lessonCode = '',
    this.lessonName = '',
    this.grade = '',
    this.gpa = '',
    this.gradeDetail = '',
    this.credit = '',
  });

  // 如果需要从 JSON 创建对象
  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      name: json['name'] ?? '',
      lessonCode: json['lessonCode'] ?? '',
      lessonName: json['lessonName'] ?? '',
      grade: json['grade'] ?? '',
      gpa: json['gpa'] ?? '',
      gradeDetail: json['gradeDetail'] ?? 0,
      credit: json['credit'] ?? 0,
    );
  }
}

class ScoreList {
  List<ScoreModel> list;
  SemesterModel semester;

  ScoreList({required this.semester, required this.list});
}
