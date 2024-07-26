import 'package:classly/application/services/CourseService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/CustomUser.dart';
import '../../domain/models/Course.dart';
import '../../application/services/UserService.dart';

class UserDetailsScreen extends StatefulWidget {
  final CustomUser user;
  final UserService userService;

  UserDetailsScreen({required this.user, required this.userService});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final CourseService courseService = CourseService();
  List<Course> enrolledCourses = [];
  List<Course> availableCourses = [];
  List<Course> selectedCourses = [];
  String? currentRole;
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      List<Course> courses = await widget.userService.getEnrolledCourses(widget.user.uid);
      List<Course> allCourses = await courseService.getAvailableCourses();
      String? role = (await widget.userService.getUser(widget.user.uid))?.role.name;
      setState(() {
        enrolledCourses = courses;
        availableCourses = allCourses;
        currentRole = role!;
      });
    } catch (error) {
      print('Error loading user details: $error');
    }
  }

  void _updateUserRole(String newRole) async {
    try {
      await widget.userService.updateUserRole(widget.user.uid, newRole);
      setState(() {
        currentRole = newRole.toUpperCase();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role updated successfully.')));
      await _loadUserDetails();
    } catch (error) {
      print('Error updating user role: $error');
    }
  }

  void _toggleCourseEnrollment(Course course) {
    setState(() {
      if (enrolledCourses.contains(course)) {
        if (selectedCourses.contains(course)) {
          selectedCourses.remove(course);
        } else {
          selectedCourses.add(course);
        }
      } else {
        if (selectedCourses.contains(course)) {
          selectedCourses.remove(course);
        } else {
          selectedCourses.add(course);
        }
      }
    });
  }

  void _saveCourseChanges() async {
    try {
      List<Course> coursesToEnroll = selectedCourses
          .where((course) => !enrolledCourses.contains(course))
          .toList();

      List<Course> coursesToDisenroll = selectedCourses
          .where((course) => enrolledCourses.contains(course))
          .toList();

      for (var course in coursesToEnroll) {
        await widget.userService.enrollInCourse(widget.user.uid, course);
      }

      for (var course in coursesToDisenroll) {
        await widget.userService.disenrollFromCourse(widget.user.uid, course);
      }

      await _loadUserDetails();

      setState(() {
        selectedCourses.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course changes saved successfully.')),
      );
    } catch (error) {
      print('Error saving course changes: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save course changes.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.getFullName() ?? 'No name available',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('${widget.user.email}, $currentRole'),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Update User Role: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _updateUserRole(newValue);
                      setState(() {
                        selectedRole = newValue;
                      });
                    }
                  },
                  items: <String>['Student', 'Professor']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Available Courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: availableCourses.length,
                itemBuilder: (context, index) {
                  Course course = availableCourses[index];
                  bool isSelected = selectedCourses.contains(course);
                  return CheckboxListTile(
                    title: Text(course.courseFullName, style: GoogleFonts.poppins()),
                    value: isSelected,
                    onChanged: (_) => _toggleCourseEnrollment(course),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Enrolled Courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: enrolledCourses.length,
                itemBuilder: (context, index) {
                  Course course = enrolledCourses[index];
                  bool isSelected = selectedCourses.contains(course);
                  return CheckboxListTile(
                    title: Text(course.courseFullName, style: GoogleFonts.poppins()),
                    value: isSelected,
                    onChanged: (_) => _toggleCourseEnrollment(course),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            if (selectedCourses.isNotEmpty)
              ElevatedButton(
                onPressed: _saveCourseChanges,
                child: Text(enrolledCourses.any((course) => selectedCourses.contains(course)) ? 'Disenroll' : 'Enroll'),
              ),
          ],
        ),
      ),
    );
  }
}
