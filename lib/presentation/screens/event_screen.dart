import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Calendar',
          style: TextStyle(fontSize: 32.0),
        ),
      ),
    );
  }
}