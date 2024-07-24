import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/CustomUser.dart';
import '../../domain/models/Course.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CustomUser?> getUser(String uid) async {
    DocumentSnapshot document = await _firestore.collection('custom_users').doc(uid).get();
    if (document.exists) {
      return CustomUser.fromDocument(document);
    }
    return null;
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
}
