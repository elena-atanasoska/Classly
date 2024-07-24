import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../application/services/AuthService.dart';
import 'bottom_navigation.dart';
import 'login_screen.dart';
class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final AuthService _firebaseService = AuthService();


  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
          () async {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigation()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen(_firebaseService)),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Classly",
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 36.0,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
            fontFamily: "Zen Kaku Gothic New",
          ),
        ),
      ),
    );
  }
}
