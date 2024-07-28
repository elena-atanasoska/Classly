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

  Future<void> updateCourse(String courseId, String courseName, String courseFullName) async {
    try {
      await _repository.updateCourse(courseId, courseName, courseFullName);
    } catch (error) {
      print('Error updating course: $error');
      throw Exception('Failed to update course');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _repository.deleteCourse(courseId);
    } catch (error) {
      print('Error deleting course: $error');
      throw Exception('Failed to delete course');
    }
  }
}
