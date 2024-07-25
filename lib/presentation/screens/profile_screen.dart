import 'dart:io';
import 'dart:typed_data';

import 'package:classly/presentation/screens/user_management_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../application/services/AuthService.dart';
import '../../application/services/UserService.dart';
import '../../domain/models/Course.dart';
import '../../domain/models/CustomUser.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  CustomUser? _user;
  List<Course> _enrolledCourses = [];
  List<Course> _availableCourses = [];
  List<Course> _selectedCourses = [];
  Uint8List? _profileImage;
  List<CustomUser> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _updateUser();
    _fetchEnrolledCourses();
    _fetchAvailableCourses();
    _fetchAllUsers();
    _auth.authStateChanges().listen((User? user) {});
  }

  void _updateUser() async {
    User? currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      _user = CustomUser.fromFirebaseUser(currentUser);

      try {
        CustomUser? userFromService = await _userService.getUser(_user!.uid);
        if (userFromService != null) {
          _user = userFromService;
          String? profileImageUrl = userFromService.photoURL;

          if (profileImageUrl != null) {
            http.Response response = await http.get(Uri.parse(profileImageUrl));
            setState(() {
              _profileImage = Uint8List.fromList(response.bodyBytes);
            });
          }
        }
      } catch (error) {
        print('Error loading profile image: $error');
      }
    }
  }

  void _fetchEnrolledCourses() async {
    if (_user != null) {
      try {
        List<Course> enrolledCourses = await _userService.getEnrolledCourses(_user!.uid);
        setState(() {
          _enrolledCourses = enrolledCourses;
        });
        print('Enrolled courses: $_enrolledCourses');
      } catch (error) {
        print('Error fetching enrolled courses: $error');
      }
    }
  }

  void _fetchAvailableCourses() async {
    try {
      List<Course> courses = await _userService.getAvailableCourses();
      setState(() {
        _availableCourses = courses;
      });
    } catch (error) {
      print('Error fetching courses: $error');
    }
  }

  void _fetchAllUsers() async {
    try {
      List<CustomUser> users = await _userService.getAllUsers();
      setState(() {
        _allUsers = users;
      });
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserManagementScreen(
          users: _allUsers,
          userService: _userService,
        ),
      ),
    );
  }

  void _updateUserRole(String userId, String newRole) async {
    try {
      await _userService.updateUserRole(userId, newRole);
      _fetchAllUsers();
    } catch (error) {
      print('Error updating user role: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _showImageSourceOptions,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _profileImage != null
                    ? MemoryImage(_profileImage!)
                    : NetworkImage('https://icons.iconarchive.com/icons/papirus-team/papirus-status/512/avatar-default-icon.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Name:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              _user?.getFullName() ?? 'No name available',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            const Text(
              'Email:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              _user?.email ?? 'No email available',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Enrolled Courses:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 8),
            ..._enrolledCourses.map((course) => Text(
              course.courseFullName,
              style: TextStyle(fontSize: 20, color: Colors.black),
            )),
            SizedBox(height: 16),
            if (_user?.isProfessor == true) ...[
              ElevatedButton(
                onPressed: _showUserManagement,
                child: Text('Manage Users'),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEnrollmentDialog(context);
        },
        tooltip: 'Enroll in Course',
        child: Icon(Icons.add),
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile != null) {
        await _uploadProfileImageAndSetUser(File(pickedFile.path));
      }
    } catch (error) {
      print('Error picking image from camera: $error');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        await _uploadProfileImageAndSetUser(File(pickedFile.path));
      }
    } catch (error) {
      print('Error picking image from gallery: $error');
    }
  }

  Future<void> _uploadProfileImageAndSetUser(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/${_user!.uid}');
      final uploadTask = storageRef.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _profileImage = Uint8List.fromList(imageFile.readAsBytesSync());
      });

      await _userService.updateUserProfileImage(_user!.uid, downloadUrl);
    } catch (error) {
      print('Error uploading profile image: $error');
    }
  }

  void _showEnrollmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enroll in Courses'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._availableCourses.map((course) => CheckboxListTile(
                title: Text(course.courseFullName),
                value: _selectedCourses.contains(course),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected != null) {
                      if (selected) {
                        _selectedCourses.add(course);
                      } else {
                        _selectedCourses.remove(course);
                      }
                    }
                  });
                },
              )),
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
              child: Text('Enroll'),
              onPressed: () async {
                try {
                  await _userService.enrollInCourses(
                      _user!.uid, _selectedCourses);
                  Navigator.of(context).pop();
                  _fetchEnrolledCourses();
                } catch (error) {
                  print('Error enrolling in courses: $error');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
