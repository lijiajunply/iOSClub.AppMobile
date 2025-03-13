class CourseTime {
  final DateTime startTime;
  final String courseName;
  final DateTime endTime;

  CourseTime({required this.startTime, required this.courseName,required this.endTime});

  difference(DateTime now) {
    return startTime.difference(now);
  }

}