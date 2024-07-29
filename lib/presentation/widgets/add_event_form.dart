import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/CalendarEvent.dart';
import '../../domain/models/Course.dart';
import '../../domain/models/CustomUser.dart';
import '../../domain/models/Professor.dart';
import '../../domain/models/Room.dart';

class AddEventForm extends StatefulWidget {
  final DateTime selectedDate;
  final Function(CalendarEvent event) onAddEvent;
  final List<Course> enrolledCourses; // Add this line
  final CustomUser? currentUser; // Add this line

  const AddEventForm({
    Key? key,
    required this.selectedDate,
    required this.onAddEvent,
    required this.enrolledCourses,
    required this.currentUser, // Add this line
  }) : super(key: key);

  @override
  State<AddEventForm> createState() => _AddEventFormState();
}

class _AddEventFormState extends State<AddEventForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController durationController = TextEditingController(text: '2');
  TextEditingController occurrenceController = TextEditingController();
  Course? selectedCourse;
  Room? selectedRoom;
  List<Room> rooms = [];


  @override
  void initState() {
    super.initState();
    dateController.text = formatDate(widget.selectedDate);
    timeController.text = formatTime(widget.selectedDate);
    _fetchAvailableRooms();
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

  List<CalendarEvent> _generateRecurringAppointments(CalendarEvent event, String rrule) {
    List<CalendarEvent> allAppointments = [];

    allAppointments.add(event);

      final count = int.parse(
          RegExp(r'COUNT=(\d+)').firstMatch(rrule)!.group(1)!);

      if (rrule.contains('FREQ=DAILY')) {
        for (int i = 1; i < count; i++) {
          allAppointments.add(CalendarEvent(
            id: Uuid().v4(),
            title: event.title,
            description: event.description,
            professor: event.professor,
            room: event.room,
            course: event.course,
            startTime: event.startTime.add(Duration(days: i)),
            endTime: event.endTime.add(Duration(days: i)),
          ));
        }
      } else if (rrule.contains('FREQ=WEEKLY')) {
        for (int i = 1; i < count; i++) {
          allAppointments.add(CalendarEvent(
            id: Uuid().v4(),
            title: event.title,
            description: event.description,
            professor: event.professor,
            room: event.room,
            course: event.course,
            startTime: event.startTime.add(Duration(days: 7 * i)),
            endTime: event.endTime.add(Duration(days: 7 * i)),
          ));
        }
      } else if (rrule.contains('FREQ=MONTHLY')) {
        for (int i = 1; i < count; i++) {
          allAppointments.add(CalendarEvent(
            id: Uuid().v4(),
            title: event.title,
            description: event.description,
            professor: event.professor,
            room: event.room,
            course: event.course,
            startTime: DateTime(
              event.startTime.year,
              event.startTime.month + i,
              event.startTime.day,
              event.startTime.hour,
              event.startTime.minute,
            ),
            endTime: DateTime(
              event.endTime.year,
              event.endTime.month + i,
              event.endTime.day,
              event.endTime.hour,
              event.endTime.minute,
            ),
          ));
        }
      }

    return allAppointments;
  }

  String getByDay(DateTime dateTime) {
    const days = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
    return days[dateTime.weekday % 7];
  }

  bool isRecurring = false;
  String? recurrenceFrequency;
  int recurrenceCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event', style: TextStyle(color: Color(0xFF0D47A1))),
      ),
      body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Enter event title',
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    TextField(
                      controller: dateController,
                      decoration:
                          InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                      style: GoogleFonts.poppins(),
                      enabled: false, // Disable date editing
                    ),
                    SizedBox(height: 15.0),
                    TextField(
                      controller: timeController,
                      decoration: InputDecoration(labelText: 'Time (HH:MM)'),
                      style: GoogleFonts.poppins(),
                      enabled: false, // Disable time editing
                    ),
                    SizedBox(height: 15.0),
                    SwitchListTile(
                      title: Text(
                        'Recurring Event',
                        style: GoogleFonts.poppins(),
                      ),
                      value: isRecurring,
                      onChanged: (bool value) {
                        setState(() {
                          isRecurring = value;
                        });
                      },
                    ),
                    if (isRecurring) ...[
                      DropdownButtonFormField<String>(
                        value: recurrenceFrequency,
                        items: ['Daily', 'Weekly', 'Monthly']
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(),
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            recurrenceFrequency = newValue!;
                          });
                        },
                        decoration:
                            InputDecoration(labelText: 'Recurrence Frequency'),
                      ),
                      SizedBox(height: 15.0),
                      TextFormField(
                        controller: occurrenceController,
                        decoration:
                            InputDecoration(labelText: 'Number of Occurrences'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          recurrenceCount = int.tryParse(value) ?? 1;
                        },
                      ),
                    ],
                    SizedBox(height: 15.0),
                    TextFormField(
                      controller: durationController,
                      decoration:
                          InputDecoration(labelText: 'Duration (hours)'),
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Please enter a valid duration';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    DropdownButtonFormField<Course>(
                      hint:
                          Text('Select a Course', style: GoogleFonts.poppins()),
                      value: selectedCourse,
                      items: widget.enrolledCourses
                          .map<DropdownMenuItem<Course>>((Course course) {
                        return DropdownMenuItem<Course>(
                          value: course,
                          child: Text(course.courseName,
                              style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                      onChanged: (Course? newValue) {
                        setState(() {
                          selectedCourse = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a course';
                        }
                        return null;
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
                    SizedBox(height: 15.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (selectedCourse != null) {
                            DateTime eventDateTime = DateTime.parse(
                                '${dateController.text} ${timeController.text}');
                            if (!isRecurring) {
                              CalendarEvent event = CalendarEvent.autogenerated(
                                title: titleController.text,
                                description: '',
                                professor: Professor(
                                  id: widget.currentUser!.uid, // Use currentUser's ID
                                  firstName: widget.currentUser!.firstName, // Use currentUser's first name
                                  lastName: widget.currentUser!.lastName, // Use currentUser's last name
                                  email: widget.currentUser!.email, // Use currentUser's email
                                ),
                                room: selectedRoom!,
                                course: selectedCourse!,
                                startTime: eventDateTime,
                                endTime: eventDateTime.add(Duration(
                                    hours: int.parse(durationController.text))),
                              );
                              widget.onAddEvent(event);
                            } else {
                              String rule = '';
                              switch (recurrenceFrequency) {
                                case 'Daily':
                                  rule = 'FREQ=DAILY;COUNT=$recurrenceCount';
                                  break;
                                case 'Weekly':
                                  String byDay = getByDay(eventDateTime);
                                  rule = 'FREQ=WEEKLY;BYDAY=$byDay;COUNT=$recurrenceCount';
                                  break;
                                case 'Monthly':
                                  int dayOfMonth = eventDateTime.day;
                                  rule = 'FREQ=MONTHLY;BYMONTHDAY=$dayOfMonth;COUNT=$recurrenceCount';
                                  break;
                              }
                              CalendarEvent event = CalendarEvent(
                                  id: Uuid().v4(),
                                  title: titleController.text,
                                  description: "",
                                  professor: Professor(
                                    id: widget.currentUser!.uid, // Use currentUser's ID
                                    firstName: widget.currentUser!.firstName, // Use currentUser's first name
                                    lastName: widget.currentUser!.lastName, // Use currentUser's last name
                                    email: widget.currentUser!.email, // Use currentUser's email
                                  ),
                                  room: selectedRoom!,
                                  course: selectedCourse!,
                                  startTime: eventDateTime,
                                  endTime: eventDateTime.add(Duration(
                                      hours:
                                          int.parse(durationController.text))));
                              List<CalendarEvent> eventsToAdd =
                                  _generateRecurringAppointments(event, rule);
                              for (var ev in eventsToAdd) {
                                widget.onAddEvent(ev);
                              }
                            }

                            Navigator.pop(context);
                          }
                        }
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              ),
            )
    );
  }
}
