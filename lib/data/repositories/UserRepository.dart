import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enum/UserRole.dart';
import '../../domain/models/CustomUser.dart';
import '../../domain/models/Course.dart';

class UserRepository {
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

  Future<List<Course>> getEnrolledCourses(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('custom_users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return [];
      }

      List<String> enrolledCourseIds = List<String>.from(userDoc.get('enrolledCourses') ?? []);

      List<Course> enrolledCourses = [];

      for (String courseId in enrolledCourseIds) {
        DocumentSnapshot courseDoc = await _firestore.collection('courses').doc(courseId).get();
        if (courseDoc.exists) {
          enrolledCourses.add(Course.fromDocument(courseDoc));
        }
      }

      return enrolledCourses;
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      return [];
    }
  }


  Future<void> updateCourses(String uid, List<Map<String, String>> coursesToEnroll,
      List<Map<String, String>> coursesToDisenroll) async {
    DocumentReference userReference = _firestore.collection('custom_users').doc(uid);

    await userReference.update({
      'enrolledCourses': FieldValue.arrayUnion(coursesToEnroll),
    });

    await userReference.update({
      'enrolledCourses': FieldValue.arrayRemove(coursesToDisenroll),
    });
  }

  Future<List<CustomUser>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('custom_users').get();
      return snapshot.docs.map((doc) => CustomUser.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to load users');
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

  Future<void> addUserToFirestore(
      String uid, String email, String firstName, String lastName) async {
    await _firestore.collection('custom_users').doc(uid).set({
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': UserRole.STUDENT.toString(),
    });
  }

  Future<void> updateUserRole(String uid, UserRole newRole) async {
    try {
      await _firestore.collection('custom_users').doc(uid).update({
        'role': newRole.toString(),
      });
    } catch (e) {
      print('Error updating user role: $e');
      throw Exception('Failed to update user role');
    }
  }

  Future<void> enrollInCourse(String userId, Course course) async {
    DocumentReference userRef = _firestore.collection('custom_users').doc(userId);
    await userRef.update({
      'enrolledCourses': FieldValue.arrayUnion([course.courseId]),
    });
  }

  Future<void> disenrollFromCourse(String userId, Course course) async {
    DocumentReference userRef = _firestore.collection('custom_users').doc(userId);
    await userRef.update({
      'enrolledCourses': FieldValue.arrayRemove([course.courseId]),
    });
  }

  Future<List<CustomUser>> getUsersEnrolledInCourse(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('custom_users')
          .where('enrolledCourses', arrayContains: courseId)
          .get();

      List<CustomUser> enrolledUsers = snapshot.docs
          .map((doc) => CustomUser.fromDocument(doc))
          .toList();

      return enrolledUsers;
    } catch (e) {
      print('Error fetching users enrolled in course: $e');
      return [];
    }
  }
}
