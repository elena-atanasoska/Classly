import 'package:flutter/material.dart';
import '../../domain/models/Course.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classly/application/services/CourseService.dart';
import 'edit_course_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;

  CourseDetailsScreen({required this.course});

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Course course;
  final CourseService _courseService = CourseService();

  @override
  void initState() {
    super.initState();
    course = widget.course;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.courseName),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedCourse = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCourseScreen(course: course),
                ),
              );
              if (updatedCourse != null) {
                setState(() {
                  course = updatedCourse;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseInfo('Course Name', course.courseName),
            SizedBox(height: 12),
            _buildCourseInfo('Course Full Name', course.courseFullName),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseInfo(String title, String content) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Course', style: TextStyle(color: Color(0xFF0D47A1))),
          content: Text('Are you sure you want to delete this course?', style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _courseService.deleteCourse(course.courseId);
                  Navigator.pop(context, true); // Notify that deletion happened
                  Navigator.pop(context, true);
                } catch (error) {
                  print('Error deleting course: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete course.')),
                  );
                }
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }
}
