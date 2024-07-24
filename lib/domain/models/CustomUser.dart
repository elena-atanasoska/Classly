import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Course.dart';

class CustomUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  late final String photoURL;
  List<Course> enrolledCourses;

  CustomUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.photoURL,
    List<Course>? enrolledCourses,
  }) : enrolledCourses = enrolledCourses ?? [];

  factory CustomUser.fromFirebaseUser(User user) {
    return CustomUser(
      uid: user.uid,
      email: user.email ?? '',
      firstName: user.displayName?.split(' ')[0] ?? '',
      lastName: user.displayName?.split(' ')[1] ?? '',
      photoURL: user.photoURL ?? '',
    );
  }

  factory CustomUser.fromDocument(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final enrolledCoursesData = data['enrolledCourses'] as List<dynamic>?;

    return CustomUser(
      uid: document.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      enrolledCourses: enrolledCoursesData != null
          ? enrolledCoursesData.map((courseData) => Course.fromMap(courseData as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoURL': photoURL,
      'enrolledCourses': enrolledCourses.map((course) => course.toMap()).toList(),
    };
  }

  String getFullName() {
    return '$firstName $lastName';
  }

  void enrollInCourse(Course course) {
    enrolledCourses.add(course);
  }

  bool isEnrolledInCourse(Course course) {
    return enrolledCourses.contains(course);
  }

  Future<void> updateProfileImage(String newImageUrl) async {
    this.photoURL = newImageUrl;

    await FirebaseFirestore.instance.collection('custom_users').doc(this.uid).update({
      'photoURL': newImageUrl,
    });
  }
}
