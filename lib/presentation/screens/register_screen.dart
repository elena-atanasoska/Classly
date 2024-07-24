import 'package:classly/service/AuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final AuthService firebaseService;

  RegistrationScreen(this.firebaseService);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final AuthService _firebaseService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                registerUser(
                  _firstNameController.text,
                  _lastNameController.text,
                  _emailController.text,
                  _passwordController.text,
                  context,
                );
              },
              child: Text('Register'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(_firebaseService)),
                );
              },
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerUser(
      String firstName,
      String lastName,
      String email,
      String password,
      BuildContext context,
      ) async {
    try {
      UserCredential authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = authResult.user;

      await user?.updateDisplayName('$firstName $lastName');

      await _firestore.collection('custom_users').doc(user?.uid).set({
        'uid': user?.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigation()),
      );
    } catch (e) {
      print('Registration failed: $e');
    }
  }
}
