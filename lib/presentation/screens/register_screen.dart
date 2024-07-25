import 'package:classly/application/services/UserService.dart';
import 'package:flutter/material.dart';
import '../../application/services/AuthService.dart';
import '../../domain/models/CustomUser.dart';
import 'bottom_navigation.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  final AuthService authService = AuthService();
  final UserService userService = UserService();

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
                  MaterialPageRoute(builder: (context) => LoginScreen()),
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
      CustomUser user = await authService.register(email, password, firstName, lastName) as CustomUser;
      await userService.addUserToFirestore(user.uid, email, firstName, lastName);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigation()),
      );
    } catch (e) {
      String errorMessage = 'Registration failed';
      final match = RegExp(r'\[(.*?)\]').firstMatch(e.toString());
      if (match != null && match.group(1) != null) {
        errorMessage = match.group(1)!;
      }
      print('Registration failed: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
