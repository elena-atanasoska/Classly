import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String courseId;
  final String courseName;
  final String courseFullName;

  Course({
    required this.courseId,
    required this.courseName,
    required this.courseFullName,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      courseFullName: map['courseFullName'] ?? '',
    );
  }

  factory Course.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course.fromMap(data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Course &&
              runtimeType == other.runtimeType &&
              courseId == other.courseId &&
              courseName == other.courseName &&
              courseFullName == other.courseFullName;

  @override
  int get hashCode => courseId.hashCode ^ courseName.hashCode ^ courseFullName.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'courseFullName': courseFullName,
    };
  }
}
