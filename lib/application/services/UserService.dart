import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/Course.dart';
import '../../domain/models/CustomUser.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CustomUser?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('custom_users').doc(uid).get();
      if (doc.exists) {
        return CustomUser.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<void> updateUserProfileImage(String uid, String imageUrl) async {
    try {
      await _firestore.collection('custom_users').doc(uid).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      print('Error updating user profile image: $e');
      throw e;
    }
  }

  Future<List<Course>> getEnrolledCourses(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('custom_users').doc(uid).get();
      if (userDoc.exists) {
        List<dynamic>? enrolledCourseIds = userDoc['enrolledCourses'];
        if (enrolledCourseIds != null) {
          QuerySnapshot coursesSnapshot = await _firestore.collection('courses').get();
          List<Course> enrolledCourses = [];

          for (var courseDoc in coursesSnapshot.docs) {
            final courseData = courseDoc.data() as Map<String, dynamic>;
            final courseId = courseData['courseId'];

            if (enrolledCourseIds.contains(courseId)) {
              enrolledCourses.add(Course.fromDocument(courseDoc));
            }
          }

          return enrolledCourses;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      return [];
    }
  }

  Future<List<Course>> getAvailableCourses() async {
    try {
      QuerySnapshot query = await _firestore.collection('courses').get();
      return query.docs.map((doc) => Course.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching available courses: $e');
      return [];
    }
  }

  Future<void> enrollInCourses(String userId, List<Course> courses) async {
    try {
      List<String> courseIds = courses.map((course) => course.courseId).toList();

      DocumentReference userDoc = _firestore.collection('custom_users').doc(userId);

      await userDoc.update({
        'enrolledCourses': FieldValue.arrayUnion(courseIds),
      });

      print('User $userId enrolled in courses: $courseIds');
    } catch (error) {
      print('Error enrolling in courses: $error');
      throw Exception('Error enrolling in courses: $error');
    }
  }
}
