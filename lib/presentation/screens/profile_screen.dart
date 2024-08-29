import 'dart:typed_data';

import 'package:classly/application/services/CourseService.dart';
import 'package:classly/application/services/RoomService.dart';
import 'package:classly/presentation/screens/room_management_screen.dart';
import 'package:classly/presentation/screens/user_management_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../application/services/AuthService.dart';
import '../../application/services/UserService.dart';
import '../../domain/models/Course.dart';
import '../../domain/models/CustomUser.dart';
import 'course_management_screen.dart';
import 'login_screen.dart';
import 'my_reservations_screen.dart'; // Import the new screen

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final CourseService _courseService = CourseService();
  final RoomService _roomService = RoomService();
  final ImagePicker _imagePicker = ImagePicker();

  CustomUser? _user;
  List<Course> _enrolledCourses = [];
  Uint8List? _profileImage;
  List<CustomUser> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _updateUser();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchEnrolledCourses(user.uid);
      }
    });
  }

  void _updateUser() async {
    User? currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      CustomUser? userFromService = await _userService.getUser(currentUser.uid);
      setState(() {
        _user = userFromService;
      });

      if (_user != null) {
        _fetchProfileImage(_user!.photoURL);
        _fetchEnrolledCourses(_user!.uid);
      }
    }
  }

  Future<void> _fetchProfileImage(String? profileImageUrl) async {
    if (profileImageUrl != null) {
      try {
        http.Response response = await http.get(Uri.parse(profileImageUrl));
        setState(() {
          _profileImage = Uint8List.fromList(response.bodyBytes);
        });
      } catch (error) {
        print('Error loading profile image: $error');
      }
    }
  }

  Future<void> _fetchEnrolledCourses(String userId) async {
    try {
      List<Course> enrolledCourses =
          await _userService.getEnrolledCourses(userId);
      setState(() {
        _enrolledCourses = enrolledCourses;
      });
    } catch (error) {
      print('Error fetching enrolled courses: $error');
    }
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showMyReservations() {
    if (_user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyReservationsScreen(userId: _user!.uid),
        ),
      );
    }
  }

  void _showUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserManagementScreen(
          userService: _userService,
        ),
      ),
    );
  }

  void _showCourseManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CourseManagementScreen(courseService: _courseService),
      ),
    );
  }

  void _showRoomManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomManagementScreen(roomService: _roomService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showImageSourceOptions,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: _profileImage != null
                        ? MemoryImage(_profileImage!)
                        : const NetworkImage(
                                'https://icons.iconarchive.com/icons/papirus-team/papirus-status/512/avatar-default-icon.png')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Name:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 8),
                Text(
                  _user?.getFullName() ?? 'No name available',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Role:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 8),
                Text(
                  _user?.role.name ?? 'No name available',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Email:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 8),
                Text(
                  _user?.email ?? 'No email available',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Enrolled Courses:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1)),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: _enrolledCourses.map((course) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              course.courseFullName,
                              style: const TextStyle(fontSize: 20, color: Colors.black),
                              textAlign: TextAlign.center, // Center the text
                              overflow: TextOverflow.visible, // Allow text to wrap
                              softWrap: true, // Enable wrapping
                            ),
                          ),
                        ],
                      )).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_user?.isProfessor == false) ...[
                  ElevatedButton(
                    onPressed: _showMyReservations,
                    child: const Text('My Reservations'),
                  ),
                ],
                if (_user?.isProfessor == true) ...[
                  ElevatedButton(
                    onPressed: _showUserManagement,
                    child: const Text('Manage Users'),
                  ),
                  const SizedBox(height: 15.0),
                  ElevatedButton(
                    onPressed: _showCourseManagement,
                    child: const Text('Manage Courses'),
                  ),
                  const SizedBox(height: 15.0),
                  ElevatedButton(
                    onPressed: _showRoomManagement,
                    child: const Text('Manage Rooms'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          actions: [
            TextButton(
              child: const Text('Camera'),
              onPressed: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Gallery'),
              onPressed: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImage = imageBytes;
      });
    }
  }
}
