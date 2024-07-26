import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/Course.dart';
import 'package:classly/application/services/CourseService.dart';

class EditCourseScreen extends StatefulWidget {
  final Course course;

  EditCourseScreen({required this.course});

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _courseName;
  late String _courseFullName;
  final CourseService _courseService = CourseService();

  @override
  void initState() {
    super.initState();
    _courseName = widget.course.courseName;
    _courseFullName = widget.course.courseFullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _courseName,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(labelText: 'Course Name'),
                onSaved: (value) => _courseName = value!,
                validator: (value) => value!.isEmpty ? 'Please enter course name' : null,
              ),
              TextFormField(
                initialValue: _courseFullName,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(labelText: 'Course Full Name'),
                onSaved: (value) => _courseFullName = value!,
                validator: (value) => value!.isEmpty ? 'Please enter course full name' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _courseService.updateCourse(
          widget.course.courseId,
          _courseName,
          _courseFullName,
        );
        Navigator.pop(context, Course(
          courseId: widget.course.courseId,
          courseName: _courseName,
          courseFullName: _courseFullName,
        ));
      } catch (error) {
        print('Error saving course changes: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save course changes.')),
        );
      }
    }
  }
}
