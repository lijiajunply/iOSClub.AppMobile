class UserData {
  final String studentId;
  final String cookie;

  UserData({required this.studentId, required this.cookie});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      studentId: json['studentId'],
      cookie: json['cookie'],
    );
  }
}