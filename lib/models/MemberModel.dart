import 'dart:convert';

class MemberModel {
  String userName;
  String userId;
  String phoneNum;
  String academy;
  String politicalLandscape;
  String gender;
  String className;
  String joinTime;
  String identity;

  MemberModel(
      {required this.userName,
      required this.userId,
      required this.phoneNum,
      required this.academy,
      required this.politicalLandscape,
      required this.gender,
      required this.className,
      required this.joinTime,
      required this.identity});

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      userName: json['UserName'],
      userId: json['UserId'],
      phoneNum: json['PhoneNum'],
      academy: json['Academy'],
      politicalLandscape: json['PoliticalLandscape'],
      gender: json['Gender'],
      className: json['ClassName'],
      joinTime: json['JoinTime'],
      identity: json['Identity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userId': userId,
      'phoneNum': phoneNum,
      'academy': academy,
      'politicalLandscape': politicalLandscape,
      'gender': gender,
      'className': className,
      'joinTime': joinTime,
      'identity': identity,
    };
  }

  static Iterable<MemberModel> fromJsonList(String s) {
    final List<dynamic> jsonList = jsonDecode(s);
    return jsonList.map((json) => MemberModel.fromJson(json));
  }
}

class MemberData {
  int totalCount;
  int totalPages;
  List<MemberModel> data;

  MemberData(
      {required this.totalCount, required this.totalPages, required this.data});

  factory MemberData.fromJson(Map<String, dynamic> json) {
    return MemberData(
      totalCount: json['TotalCount'],
      totalPages: json['TotalPages'],
      data: (json['Data'] as List<dynamic>)
          .map((json) => MemberModel.fromJson(json))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TotalCount': totalCount,
      'TotalPages': totalPages,
      'Data': data.map((member) => member.toJson()).toList(),
    };
  }
}
