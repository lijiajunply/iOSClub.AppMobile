class CourseTime {
  final DateTime startTime;
  final String courseName;

  CourseTime({required this.startTime, required this.courseName});

  difference(DateTime now) {
    return startTime.difference(now);
  }

}