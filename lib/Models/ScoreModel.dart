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

  double get totalCredit {
    double credit = 0;
    for (var item in list) {
      final a = double.parse(item.gpa);
      if(a == 0) {
        continue;
      }
      credit += double.parse(item.credit);
    }
    return credit;
  }

  double get totalGpa {
    double total = 0;
    double credit = 0;
    for (var item in list) {
      total += double.parse(item.credit);
      credit += double.parse(item.credit) * double.parse(item.gpa);
    }
    return credit / total;
  }

  int get totalCourse {
    return list.where((x) {
      final a = double.parse(x.gpa);
      return a != 0;
    }).length;
  }

  static double getTotalGpa(List<ScoreList> scoreList) {
    double total = 0;
    for (var item in scoreList) {
      total += item.totalGpa;
    }
    return total / scoreList.length;
  }

  static double getTotalCredit(List<ScoreList> scoreList) {
    double total = 0;
    for (var item in scoreList) {
      total += item.totalCredit;
    }
    return total;
  }

  static int getTotalCourse(List<ScoreList> scoreList) {
    int total = 0;
    for (var item in scoreList) {
      total += item.totalCourse;
    }
    return total;
  }
}
