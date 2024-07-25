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
    QuerySnapshot querySnapshot =
    await _firestore.collection('custom_users/$uid/enrolledCourses').get();
    return querySnapshot.docs.map((doc) => Course.fromDocument(doc)).toList();
  }

  Future<List<Course>> getAvailableCourses() async {
    QuerySnapshot querySnapshot = await _firestore.collection('courses').get();
    return querySnapshot.docs.map((doc) => Course.fromDocument(doc)).toList();
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
}
