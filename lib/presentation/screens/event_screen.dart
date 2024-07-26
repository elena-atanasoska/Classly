import 'package:classly/presentation/screens/reserve_seat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/CalendarEvent.dart';

class EventScreen extends StatelessWidget {
  final CalendarEvent event;

  EventScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120.0,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.course.courseFullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(
                  //   'Lecture',
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 16,
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Class details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            const Text('Professor:', style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/professor.png'),
                ),
                title: Text(event.professor.getFullName()),
              ),
            ),
            const SizedBox(height: 15),
            const Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              DateFormat('d MMMM yyyy').format(event.startTime)
            ),
            const SizedBox(height: 15),
            const Text('Time:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
            ),
            const SizedBox(height: 15),
            const Text('Room:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(event.room.name),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReserveSeatScreen(event: event),
                  ),
                );
              },
              child: const Text('Reserve your seat'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
