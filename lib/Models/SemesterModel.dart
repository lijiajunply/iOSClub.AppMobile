class SemesterModel {
  final String semester;
  final String name;

  SemesterModel({required this.semester, required this.name});

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      semester: json['value'],
      name: json['text'],
    );
  }

  toJson() {
    return {
      'value': semester,
      'text': name,
    };
  }
}