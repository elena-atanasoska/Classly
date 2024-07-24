import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  final AuthService _firebaseService = AuthService();
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  late CustomUser? _user;
  List<Course> _enrolledCourses = [];
  List<Course> _availableCourses = [];
  List<Course> _selectedCourses = [];
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    _updateUser();
    _fetchEnrolledCourses();
    _fetchAvailableCourses();
    _auth.authStateChanges().listen((User? user) {});
  }

  void _updateUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _user = CustomUser.fromFirebaseUser(currentUser);

      try {
        CustomUser? userFromService = await _userService.getUser(_user!.uid);
        if (userFromService != null) {
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

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(_firebaseService)),
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
            for (Course course in _enrolledCourses)
              Text(
                course.courseFullName,
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            SizedBox(height: 16),
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
      if (_user != null) {
        String imageUrl = await _uploadProfileImageToStorage(imageFile);

        if (imageUrl.isNotEmpty) {
          await _userService.updateUserProfileImage(_user!.uid, imageUrl);

          setState(() {
            _user!.photoURL = imageUrl;
            _profileImage = MemoryImage(imageFile.readAsBytesSync()) as Uint8List?;
          });

          print('Profile image uploaded and user profile updated');
        } else {
          print('Image URL is empty after upload');
        }
      } else {
        print('User object is null in _uploadProfileImageAndSetUser');
      }
    } catch (error) {
      print('Error uploading profile image: $error');
    }
  }

  Future<String> _uploadProfileImageToStorage(File imageFile) async {
    try {
      String fileName = 'profile_images/${_user!.uid}.png';
      print('Storage Path: $fileName');

      Reference storageReference =
      FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => print('Profile image uploaded'));

      return await storageReference.getDownloadURL();
    } catch (error) {
      print('Error uploading profile image to storage: $error');
      return '';
    }
  }

  Future<void> _showEnrollmentDialog(BuildContext context) async {
    List<Course> availableCoursesCopy = List.from(_availableCourses);
    _fetchEnrolledCourses();
    for (Course enrolledCourse in _enrolledCourses) {
      int index = availableCoursesCopy.indexWhere(
            (course) => course.courseId == enrolledCourse.courseId,
      );
      print('Index: $index');
      if (index != -1) {
        _selectedCourses.add(enrolledCourse);
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Available Courses'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: availableCoursesCopy.map((Course course) {
                    return CheckboxListTile(
                      title: Text(course.courseName),
                      value: _selectedCourses.contains(course),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            _selectedCourses.add(course);
                          } else {
                            _selectedCourses.remove(course);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
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
