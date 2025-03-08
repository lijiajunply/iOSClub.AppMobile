class ExamItem {
  final String name;

  final String examTime;

  final String room;

  final String seatNo;

  ExamItem({
    this.name = '',
    this.examTime = '',
    this.room = '',
    this.seatNo = '',
  });

  factory ExamItem.fromJson(Map<String, dynamic> json){
    return ExamItem(
      name: json['name'] ?? '',
      examTime: json['time'] ?? '',
      room: json['location'] ?? '',
      seatNo: json['seat'] ?? '',
    );
  }
}