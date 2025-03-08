class ExamDataRaw {
  final String name;

  final String examTime;

  final String room;

  final String seatNo;

  ExamDataRaw({
    this.name = '',
    this.examTime = '',
    this.room = '',
    this.seatNo = '',
  });

  factory ExamDataRaw.fromJson(Map<String, dynamic> json){
    return ExamDataRaw(
      name: json['name'] ?? '',
      examTime: json['time'] ?? '',
      room: json['location'] ?? '',
      seatNo: json['seat'] ?? '',
    );
  }
}