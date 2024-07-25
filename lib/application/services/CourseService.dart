import 'package:classly/data/repositories/CourseRepository.dart';

import '../../domain/models/Course.dart';

class CourseService {
  final CourseRepository _repository = CourseRepository();


  Future<List<Course>> getAvailableCourses() async {
    return await _repository.fetchAvailableCourses();
  }

  Future<void> addCourse(String courseName, String courseFullName) async {
    try {
      await _repository.addCourse(courseName, courseFullName);
    } catch (error) {
      print('Error adding course: $error');
      throw Exception('Failed to add course');
    }
  }

}
