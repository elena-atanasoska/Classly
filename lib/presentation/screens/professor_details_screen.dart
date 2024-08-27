import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/Professor.dart';

class ProfessorDetailsScreen extends StatelessWidget {
  final Professor professor;

  ProfessorDetailsScreen({required this.professor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professor Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://icons.iconarchive.com/icons/papirus-team/papirus-status/512/avatar-default-icon.png',
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              professor.getFullName(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Email:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => _launchEmail(professor.email),
              child: Text(
                professor.email,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 24),
            // Add more professor details here
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final url = 'mailto:$email?subject=Inquiry&body=Hi Professor ${professor.lastName},';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error if the mail app cannot be opened
      throw 'Could not launch $url';
    }
  }
}
