import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../enum/UserRole.dart';

class CustomUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  late final String photoURL;
  List<String> enrolledCourses;
  UserRole role;

  CustomUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.photoURL,
    List<String>? enrolledCourses,
    required this.role,
  }) : enrolledCourses = enrolledCourses ?? [];

  factory CustomUser.fromFirebaseUser(User user) {
    return CustomUser(
      uid: user.uid,
      email: user.email ?? '',
      firstName: user.displayName?.split(' ')[0] ?? '',
      lastName: user.displayName?.split(' ')[1] ?? '',
      photoURL: user.photoURL ?? '',
      role: UserRole.STUDENT,
    );
  }

  factory CustomUser.fromDocument(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    final enrolledCoursesData = data['enrolledCourses'] as List<dynamic>?;

    final roleString = data['role'] as String;
    UserRole role;

    switch (roleString) {
      case 'UserRole.PROFESSOR':
        role = UserRole.PROFESSOR;
        break;
      case 'UserRole.STUDENT':
      default:
        role = UserRole.STUDENT;
        break;
    }

    return CustomUser(
      uid: document.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      enrolledCourses: enrolledCoursesData != null
          ? List<String>.from(enrolledCoursesData) // Ensure it's a List<String>
          : [],
      role: role,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoURL': photoURL,
      'enrolledCourses': enrolledCourses,
      'role': role,
    };
  }

  String getFullName() {
    return '$firstName $lastName';
  }

  void enrollInCourse(String courseId) {
    enrolledCourses.add(courseId);
  }

  bool isEnrolledInCourse(String courseId) {
    return enrolledCourses.contains(courseId);
  }

  Future<void> updateProfileImage(String newImageUrl) async {
    this.photoURL = newImageUrl;

    await FirebaseFirestore.instance.collection('custom_users').doc(this.uid).update({
      'photoURL': newImageUrl,
    });
  }

  bool get isProfessor => role == UserRole.PROFESSOR;
}
