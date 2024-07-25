import 'package:flutter/material.dart';
import '../../domain/models/Course.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;

  CourseDetailsScreen({required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.courseFullName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Name: ${course.courseName}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Course Full Name: ${course.courseFullName}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
