import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/stores/course_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CourseStore', () {
    late CourseStore courseStore;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      courseStore = CourseStore();
    });

    test('should initialize with empty lists', () {
      expect(courseStore.courses, isEmpty);
      expect(courseStore.ignoreCourses, isEmpty);
    });

    test('should add ignore courses to the store', () async {
      courseStore.setIgnoreCourses(['数学', '英语']);
      
      expect(courseStore.ignoreCourses, hasLength(2));
      expect(courseStore.ignoreCourses, contains('数学'));
      expect(courseStore.ignoreCourses, contains('英语'));
    });

    test('should add single ignore course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.addIgnoreCourse('英语');
      
      expect(courseStore.ignoreCourses, hasLength(2));
      expect(courseStore.ignoreCourses, contains('数学'));
      expect(courseStore.ignoreCourses, contains('英语'));
    });

    test('should not add duplicate ignore course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.addIgnoreCourse('数学'); // 添加重复项
      
      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('数学'));
    });

    test('should remove ignore course', () async {
      courseStore.setIgnoreCourses(['数学', '英语']);
      await courseStore.removeIgnoreCourse('数学');
      
      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('英语'));
    });

    test('should not remove non-existent ignore course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.removeIgnoreCourse('英语'); // 移除不存在的项
      
      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('数学'));
    });
  });
}