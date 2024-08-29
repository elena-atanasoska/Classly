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
          crossAxisAlignment: CrossAxisAlignment.start, // Left-align contents
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
            Center(
              child: Text(
                professor.getFullName(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
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
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () => _launchEmail(professor.email),
                child: Text('Email Professor'),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Consultation Hours:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Mondays 10:00 - 12:00\nWednesdays 14:00 - 16:00',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Inquiry&body=Hi Professor ${professor.lastName},',
    );

    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      // Handle error if the mail app cannot be opened
      throw 'Could not launch $emailUri';
    }
  }
}
