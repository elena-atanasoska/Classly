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

  Future<void> addCourse(String courseName, String courseFullName) async {
    try {
      DocumentReference docRef = await _firestore.collection('courses').add({
        'courseName': courseName,
        'courseFullName': courseFullName,
      });

      await docRef.update({
        'courseId': docRef.id,
      });
    } catch (error) {
      print('Error adding course to repository: $error');
      throw Exception('Failed to add course to repository');
    }
  }

  Future<void> updateCourse(String courseId, String courseName, String courseFullName) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'courseName': courseName,
        'courseFullName': courseFullName,
      });
    } catch (error) {
      print('Error updating course: $error');
      throw Exception('Failed to update course');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
    } catch (error) {
      print('Error deleting course: $error');
      throw Exception('Failed to delete course');
    }
  }
}
