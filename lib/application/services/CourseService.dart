import 'package:classly/data/repositories/CourseRepository.dart';

import '../../domain/models/Course.dart';

class CourseService {
  final CourseRepository _repository = CourseRepository();


  Future<List<Course>> getAvailableCourses() async {
    return await _repository.fetchAvailableCourses();
  }
}
