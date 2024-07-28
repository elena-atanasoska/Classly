import 'dart:io';
import 'dart:typed_data';

import 'package:classly/application/services/CourseService.dart';
import 'package:classly/presentation/screens/user_management_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../application/services/AuthService.dart';
import '../../application/services/UserService.dart';
import '../../domain/models/Course.dart';
import '../../domain/models/CustomUser.dart';
import 'course_management_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final CourseService _courseService = CourseService();
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
      List<Course> enrolledCourses = await _userService.getEnrolledCourses(userId);
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
        builder: (context) => CourseManagementScreen(courseService: _courseService),
      ),
    );
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
            SizedBox(height: 8),
            Text(
              _user?.getFullName() ?? 'No name available',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            const Text(
              'Email:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
            SizedBox(height: 8),
            Text(
              _user?.email ?? 'No email available',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            if (_user?.isProfessor != true) ...[
              Text(
                'Enrolled Courses:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
              SizedBox(height: 8),
              ..._enrolledCourses.map((course) => Text(
                course.courseFullName,
                style: TextStyle(fontSize: 20, color: Colors.black),
              )),
            ] else
              SizedBox(height: 16),
            if (_user?.isProfessor == true) ...[
              ElevatedButton(
                onPressed: _showUserManagement,
                child: Text('Manage Users'),
              ),
              SizedBox(height: 15.0),
              ElevatedButton(
                onPressed: _showCourseManagement,
                child: Text('Manage Courses'),
              ),
            ],
          ],
        ),
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
}
