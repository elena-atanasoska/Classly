import 'package:classly/application/services/CourseService.dart';
import 'package:flutter/material.dart';
import '../../application/services/UserService.dart';
import '../../domain/models/Course.dart';
import 'course_details_screen.dart'; // Import the course details screen

class CourseManagementScreen extends StatefulWidget {
  final CourseService courseService;

  CourseManagementScreen({required this.courseService});

  @override
  _CourseManagementScreenState createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  List<Course> _courses = [];
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseFullNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  void _fetchCourses() async {
    try {
      List<Course> courses = await widget.courseService.getAvailableCourses();
      setState(() {
        _courses = courses;
      });
    } catch (error) {
      print('Error fetching courses: $error');
    }
  }

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Course', style: TextStyle(color: Colors.blue),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _courseNameController,
                decoration: InputDecoration(labelText: 'Course Name'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _courseFullNameController,
                decoration: InputDecoration(labelText: 'Course Full Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                try {
                  String courseName = _courseNameController.text;
                  String courseFullName = _courseFullNameController.text;
                  await widget.courseService.addCourse(courseName, courseFullName);
                  _courseNameController.clear();
                  _courseFullNameController.clear();
                  Navigator.of(context).pop();
                  _fetchCourses();
                } catch (error) {
                  print('Error adding course: $error');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Management'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showAddCourseDialog,
            child: Text('Add New Course', style: TextStyle(color: Colors.blue),),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                Course course = _courses[index];
                return ListTile(
                  title: Text(course.courseFullName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsScreen(course: course),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
