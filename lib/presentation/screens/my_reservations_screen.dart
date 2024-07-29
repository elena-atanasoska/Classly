import 'package:classly/application/services/EventService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/services/ReservationService.dart';
import '../../domain/models/CalendarEvent.dart';
import 'event_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  final String userId;

  MyReservationsScreen({required this.userId});

  @override
  _MyReservationsScreenState createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  final EventService _eventService = EventService();
  List<Map<String, dynamic>> _reservations = [];
  List<CalendarEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    try {
      final reservationsSnapshot = await _reservationService.getReservationsForUser(widget.userId);
      List<Map<String, dynamic>> reservationsList = [];
      List<CalendarEvent> eventsList = [];

      for (var reservation in reservationsSnapshot) {
        final eventId = reservation['eventId'];
        final event = await _eventService.getEventById(eventId);
        reservationsList.add({
          'eventId': eventId,
          'seat': reservation['seat'],
          'event': event
        });
        eventsList.add(event);
      }

      setState(() {
        _reservations = reservationsList;
        _events = eventsList;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching reservations: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEventScreen(String eventId) async {
    CalendarEvent event = await _fetchEventById(eventId);
    if (event != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventScreen(event: event),
        ),
      );
    }
  }

  Future<CalendarEvent> _fetchEventById(String eventId) async {

    return _eventService.getEventById(eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Reservations'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          final event = reservation['event'] as CalendarEvent;
          final seat = reservation['seat'] as Map<String, dynamic>;
          return ListTile(
            title: Text('Event: ${event.title}', style: GoogleFonts.poppins(),),
            subtitle: Text('Seat: Row ${(seat['row'] as int) + 1}, Column ${String.fromCharCode(65 + (seat['column'] as int))}'),
            onTap: () => _navigateToEventScreen(reservation['eventId']),
          );
        },
      ),
    );
  }
}
