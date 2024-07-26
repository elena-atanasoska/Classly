import 'package:classly/application/services/CourseService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/Course.dart';
import 'course_details_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  final CourseService courseService;

  const CourseManagementScreen({super.key, required this.courseService});

  @override
  _CourseManagementScreenState createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseFullNameController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _searchController.addListener(_filterCourses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchCourses() async {
    try {
      List<Course> courses = await widget.courseService.getAvailableCourses();
      setState(() {
        _courses = courses;
        _filteredCourses = courses;
      });
    } catch (error) {
      print('Error fetching courses: $error');
    }
  }

  void _filterCourses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _courses.where((course) {
        return course.courseName.toLowerCase().contains(query) ||
            course.courseFullName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Course', style: TextStyle(color: Color(0xFF0D47A1))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _courseNameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _courseFullNameController,
                decoration: const InputDecoration(labelText: 'Course Full Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                try {
                  String courseName = _courseNameController.text;
                  String courseFullName = _courseFullNameController.text;
                  await widget.courseService
                      .addCourse(courseName, courseFullName);
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
        title: const Text('Course Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(50.0), // Make search field rounder
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  // Round the border on focus
                  borderSide:
                      BorderSide.none, // Remove border side for rounded corners
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _showAddCourseDialog,
            child: const Text('Add New Course', style: TextStyle(color: Color(0xFF0D47A1))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCourses.length,
              itemBuilder: (context, index) {
                Course course = _filteredCourses[index];
                return ListTile(
                  title: Text(course.courseFullName, style: GoogleFonts.poppins(),),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailsScreen(course: course),
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
