import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/Course.dart';

class CourseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Course>> fetchAvailableCourses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('courses').get();

      return querySnapshot.docs.map((DocumentSnapshot document) {
        return Course(
          courseId: document.id,
          courseName: document['courseName'] ?? '',
          courseFullName: document['courseFullName'] ?? '',
        );
      }).toList();
    } catch (error) {
      print('Error fetching courses: $error');
      throw error;
    }
  }
}
