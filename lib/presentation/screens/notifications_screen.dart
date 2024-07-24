import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Notifications',
          style: TextStyle(fontSize: 32.0),
        ),
      ),
    );
  }
}
