import 'package:ios_club_app/Models/SemesterModel.dart';

class ScoreModel {
  String name;
  String lessonCode;
  String lessonName;
  String grade;
  String gpa;
  String gradeDetail;
  String credit;
  bool isMinor;

  ScoreModel({
    this.name = '',
    this.lessonCode = '',
    this.lessonName = '',
    this.grade = '',
    this.gpa = '',
    this.gradeDetail = '',
    this.credit = '',
    this.isMinor = false,
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
      isMinor: json['isMinor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lessonCode': lessonCode,
      'lessonName': lessonName,
      'grade': grade,
      'gpa': gpa,
      'gradeDetail': gradeDetail,
      'credit': credit,
      'isMinor': isMinor,
    };
  }
}

class ScoreList {
  List<ScoreModel> list;
  SemesterModel semester;

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((x) => x.toJson()).toList(),
      'semester': semester.toJson(),
    };
  }

  ScoreList.fromJson(Map<String, dynamic> json)
      : list =
            (json['list'] as List).map((x) => ScoreModel.fromJson(x)).toList(),
        semester = SemesterModel.fromJson(json['semester']);

  ScoreList({required this.semester, required this.list});

  /// 总学分
  double get totalCredit {
    double credit = 0;
    for (var item in list) {
      if (item.gpa == '' || item.credit == '0') continue;
      final a = double.parse(item.gpa);
      if (a == 0) {
        continue;
      }
      credit += double.parse(item.credit);
    }
    return credit;
  }

  /// 总绩点
  double get totalGpa {
    double total = 0;
    double credit = 0;
    for (var item in list) {
      if (item.gpa == '' || item.credit == '0' || item.isMinor) continue;
      total += double.parse(item.credit);
      credit += double.parse(item.credit) * double.parse(item.gpa);
    }
    return credit / total;
  }

  /// 总课程数
  int get totalCourse {
    return list.where((x) {
      if (x.gpa == '' || x.credit == '0') return false;
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
