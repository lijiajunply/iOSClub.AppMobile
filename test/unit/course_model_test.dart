import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/models/course_model.dart';

void main() {
  group('CourseModel', () {
    test('should create instance with default values', () {
      final course = CourseModel();
      
      expect(course.weekIndexes, isEmpty);
      expect(course.teachers, isEmpty);
      expect(course.room, isEmpty);
      expect(course.courseName, isEmpty);
      expect(course.courseCode, isEmpty);
      expect(course.weekday, 0);
      expect(course.startUnit, 0);
      expect(course.endUnit, 0);
      expect(course.credits, isEmpty);
      expect(course.lessonId, isEmpty);
    });

    test('should create instance with provided values', () {
      final course = CourseModel(
        weekIndexes: [1, 2, 3],
        teachers: ['Teacher A', 'Teacher B'],
        room: 'Room 101',
        courseName: 'Mathematics',
        courseCode: 'MATH101',
        weekday: 1,
        startUnit: 2,
        endUnit: 4,
        credits: '3.0',
        lessonId: 'lesson_123',
      );

      expect(course.weekIndexes, [1, 2, 3]);
      expect(course.teachers, ['Teacher A', 'Teacher B']);
      expect(course.room, 'Room 101');
      expect(course.courseName, 'Mathematics');
      expect(course.courseCode, 'MATH101');
      expect(course.weekday, 1);
      expect(course.startUnit, 2);
      expect(course.endUnit, 4);
      expect(course.credits, '3.0');
      expect(course.lessonId, 'lesson_123');
    });

    test('should create instance from JSON', () {
      final json = {
        'weekIndexes': [1, 3, 5],
        'teachers': ['Prof. Smith', 'Dr. Jones'],
        'room': 'A201',
        'courseName': 'Physics',
        'courseCode': 'PHYS101',
        'weekday': 3,
        'startUnit': 1,
        'endUnit': 3,
        'credits': '4.0',
        'lessonId': 'phys101_001',
      };

      final course = CourseModel.fromJson(json);

      expect(course.weekIndexes, [1, 3, 5]);
      expect(course.teachers, ['Prof. Smith', 'Dr. Jones']);
      expect(course.room, 'A201');
      expect(course.courseName, 'Physics');
      expect(course.courseCode, 'PHYS101');
      expect(course.weekday, 3);
      expect(course.startUnit, 1);
      expect(course.endUnit, 3);
      expect(course.credits, '4.0');
      expect(course.lessonId, 'phys101_001');
    });

    test('should handle missing JSON fields gracefully', () {
      final json = <String, dynamic>{};
      final course = CourseModel.fromJson(json);

      expect(course.weekIndexes, isEmpty);
      expect(course.teachers, isEmpty);
      expect(course.room, isEmpty);
      expect(course.courseName, isEmpty);
      expect(course.courseCode, isEmpty);
      expect(course.weekday, 0);
      expect(course.startUnit, 0);
      expect(course.endUnit, 0);
      expect(course.credits, isEmpty);
      expect(course.lessonId, isEmpty);
    });
  });
}