import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../application/services/CourseService.dart';
import '../../domain/models/CalendarEvent.dart';
import '../../domain/models/Course.dart';
import '../../domain/models/Professor.dart';
import '../../domain/models/Room.dart';
import '../../domain/models/Seat.dart';

class AddEventDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(CalendarEvent event) onAddEvent;

  const AddEventDialog({
    Key? key,
    required this.selectedDate,
    required this.onAddEvent,
  }) : super(key: key);

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController durationController = TextEditingController(text: '2');
  Course? selectedCourse;
  Room? selectedRoom;
  List<Course> courses = [];
  List<Room> rooms = [];

  @override
  void initState() {
    super.initState();
    dateController.text = formatDate(widget.selectedDate);
    timeController.text = formatTime(widget.selectedDate);
    _fetchAvailableCourses();
    _fetchAvailableRooms();
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchAvailableCourses() async {
    final courseService = CourseService();
    courses = await courseService.getAvailableCourses();
    setState(() {});
  }

  Future<void> _fetchAvailableRooms() async {
    final firestore = FirebaseFirestore.instance;
    final roomCollection = firestore.collection('rooms');
    final snapshot = await roomCollection.get();

    rooms = snapshot.docs.map((doc) {
      final data = doc.data();
      return Room.fromMap(data);
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Event', style: TextStyle(color: Colors.blue)),
      content: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Enter event title',
                ),
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                enabled: true,
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: 'Time (HH:MM)'),
                enabled: true,
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: durationController,
                decoration: InputDecoration(labelText: 'Duration (hours)'),
              ),
              SizedBox(height: 15.0),
              DropdownButtonFormField<Course>(
                hint: Text('Select a Course', style: GoogleFonts.poppins()),
                value: selectedCourse,
                items: courses.map<DropdownMenuItem<Course>>((Course course) {
                  return DropdownMenuItem<Course>(
                    value: course,
                    child: Text(course.courseName, style: GoogleFonts.poppins()),
                  );
                }).toList(),
                onChanged: (Course? newValue) {
                  setState(() {
                    selectedCourse = newValue;
                  });
                },
              ),
              SizedBox(height: 15.0),
              DropdownButtonFormField<Room>(
                hint: Text('Select a Room', style: GoogleFonts.poppins()),
                value: selectedRoom,
                items: rooms.map<DropdownMenuItem<Room>>((Room room) {
                  return DropdownMenuItem<Room>(
                    value: room,
                    child: Text(room.name, style: GoogleFonts.poppins()),
                  );
                }).toList(),
                onChanged: (Room? newValue) {
                  setState(() {
                    selectedRoom = newValue;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (selectedCourse != null && selectedRoom != null) {
              DateTime eventDateTime = DateTime.parse(
                  '${dateController.text} ${timeController.text}');

              CalendarEvent event = CalendarEvent.autogenerated(
                title: titleController.text,
                description: '',
                professor: Professor(
                  id: '1',
                  firstName: 'John',
                  lastName: 'Doe',
                  email: 'john.doe@example.com',
                ),
                room: selectedRoom!,
                course: selectedCourse!,
                startTime: eventDateTime,
                endTime: eventDateTime.add(
                    Duration(hours: int.parse(durationController.text))),
              );

              widget.onAddEvent(event);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select both a course and a room for the event'),
                ),
              );
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
