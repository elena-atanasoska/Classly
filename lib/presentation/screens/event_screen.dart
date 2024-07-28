import 'package:classly/presentation/screens/reserve_seat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../application/services/ReservationService.dart';
import '../../domain/models/CalendarEvent.dart';
import '../../domain/models/Seat.dart';

class EventScreen extends StatefulWidget {
  final CalendarEvent event;

  EventScreen({required this.event});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  Seat? reservedSeat;
  bool isLoading = true;
  final ReservationService _reservationService = ReservationService();

  @override
  void initState() {
    super.initState();
    _checkReservation();
  }

  Future<void> _checkReservation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      reservedSeat =
          await _reservationService.getReservedSeat(user.uid, widget.event.id);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _cancelReservation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _reservationService.cancelReservation(user.uid, widget.event.id);
      setState(() {
        reservedSeat = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation canceled successfully!'),
        ),
      );
    }
  }

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
                    widget.event.course.courseFullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Class details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            const Text('Professor:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/professor.png'),
                ),
                title: Text(widget.event.professor.getFullName()),
              ),
            ),
            const SizedBox(height: 15),
            const Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              DateFormat('d MMMM yyyy').format(widget.event.startTime),
            ),
            const SizedBox(height: 15),
            const Text('Time:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${DateFormat('HH:mm').format(widget.event.startTime)} - ${DateFormat('HH:mm').format(widget.event.endTime)}',
            ),
            const SizedBox(height: 15),
            const Text('Room:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.event.room.name),
            if (reservedSeat != null) ...[
              const SizedBox(height: 15),
              const Text('Your Reserved Seat:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  'Row: ${reservedSeat!.row + 1}, Column: ${String.fromCharCode(65 + reservedSeat!.column)}'),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : reservedSeat != null
                      ? () async {
                          bool? confirmCancel = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Cancel Reservation',
                                style: TextStyle(color: Colors.black),
                              ),
                              content: const Text(
                                'Are you sure you want to cancel your reservation?',
                                style: TextStyle(color: Colors.black),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
                          if (confirmCancel == true) {
                            _cancelReservation();
                          }
                        }
                      : () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReserveSeatScreen(event: widget.event),
                            ),
                          );
                          if (result == true) {
                            _checkReservation();
                          }
                        },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(reservedSeat != null
                      ? 'Cancel Reservation'
                      : 'Reserve your seat'),
            ),
          ],
        ),
      ),
    );
  }
}
